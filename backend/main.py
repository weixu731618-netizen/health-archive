"""V0.4C-1：健康档案识别后端。

本阶段接口：
  POST /api/report/ocr           （新）只做 OCR：图片 -> 带位置的行级文字（统一 JSON）
  POST /api/report/recognize     （保留）OCR + DeepSeek 结构化（DeepSeek 需配置，本期未接仍可调 OCR 逻辑）

调用链：
  Flutter App --上传图片--> 本服务 --百度 OCR(accurate)--> 回到 Flutter

隐私与安全（必读）：
  * 所有 Key / Secret 只来自 .env / 环境变量，绝不写入代码库 / Flutter 客户端。
  * 不打印 Key / Secret / 完整报告内容 / 患者姓名 / 原始图。
  * 只允许记录类似：OCR success / wordsCount / duration ms。
"""
import logging
import os
import time
from contextlib import asynccontextmanager

from dotenv import load_dotenv

load_dotenv()

from fastapi import Depends, FastAPI, File, HTTPException, Request, UploadFile
from fastapi.responses import JSONResponse

from models.medical_report_map import map_medical_report
from models.ocr_response import OcrResponse, WordItem
from models.structured_report import normalize_metric
from services.baidu_medical_report_service import recognize_lab_report
from services.baidu_ocr_service import BaiduOcrError, recognize_image
from services.deepseek_report_parser import DeepSeekParseError, parse_ocr_result

# V0.5：云备份 / 认证——v1 精简版默认不启用（见下方 ENABLE_CLOUD_BACKUP）。
# 只做 import，不代表一定会挂载路由/建表/查库。
from app.api_auth import router as auth_router
from app.api_backup import router as backup_router
from app.api_push import router as push_router
from app.auth import optional_user
from app.db import init_db
from app.models import User
from app.push_db import init_push_db

logger = logging.getLogger("uvicorn.error")

# v1 上线目标是"服务器不存任何用户健康数据"：只保留 OCR/识别两个接口，
# 不挂载匿名账号 + 云备份那套（涉及用户表、备份表、对象存储）。
# 默认关闭；以后要重新启用云备份，把环境变量 ENABLE_CLOUD_BACKUP=true 打开即可，
# 不需要改代码/另开分支。
_ENABLE_CLOUD_BACKUP = os.getenv("ENABLE_CLOUD_BACKUP", "false").strip().lower() == "true"


async def _no_auth() -> User | None:
    """v1 精简版：OCR 接口完全不鉴权、不查库（云备份关闭时，根本不存在可校验的账号）。"""
    return None


# 云备份关闭时 OCR 接口用 _no_auth，不触碰数据库；开启后才走真正的可选鉴权
# （optional_user 会查用户表）。两个 OCR 接口目前都不读 `user` 参数，只是为
# 以后（云备份开启、要按账号做配额之类）预留位置。
_ocr_user_dependency = optional_user if _ENABLE_CLOUD_BACKUP else _no_auth


@asynccontextmanager
async def lifespan(_app: FastAPI):
    if _ENABLE_CLOUD_BACKUP:
        init_db()
    # B2：推送用独立的小库（只有 device_tokens 一张表），与云备份开关无关，
    # 即使 PUSH_ENABLED=false 也建表——只是不真正发 APNs（走 mock）。
    init_push_db()
    yield


app = FastAPI(title="HealthArchive Report Backend", version="0.5", lifespan=lifespan)

if _ENABLE_CLOUD_BACKUP:
    app.include_router(auth_router)
    app.include_router(backup_router)

# B2：推送 token 管理 + 测试接口——始终挂载（未配置 APNs 时测试发送走 mock）。
app.include_router(push_router)

# 单张图片上限：约 8 MB
MAX_IMAGE_BYTES = 8 * 1024 * 1024
# 只接受 JPG / PNG（按任务限定）
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png"}
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def _validate_image(mime: str | None, filename: str, size: int):
    ext = ""
    if filename:
        dot = filename.rfind(".")
        if dot >= 0:
            ext = filename[dot:].lower()
    if mime not in ALLOWED_CONTENT_TYPES or ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(400, detail="仅支持 JPG / JPEG / PNG 图片")
    if size <= 0:
        raise HTTPException(400, detail="未收到图片")
    if size > MAX_IMAGE_BYTES:
        raise HTTPException(400, detail="图片过大（上限 8MB）")


def _validate_image_bytes(mime: str | None, image_bytes: bytes) -> None:
    """校验图片魔数，避免仅靠客户端 MIME / 扩展名判断。"""
    if mime == "image/png" and image_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return
    if mime == "image/jpeg" and image_bytes.startswith(b"\xff\xd8\xff"):
        return
    raise HTTPException(400, detail="图片格式与文件类型不一致")


# OCR / 识别接口限流：两个接口可匿名调用且各自代理一次付费的百度 OCR（/report/recognize
# 还会再代理一次 DeepSeek），不加限制的话任何人都能刷爆调用方的第三方账单。
# 三层限流，从小到大：
#   1) 按客户端 IP 分桶，限制单一来源的高频调用；
#   2) 每分钟全局阈值，防止攻击者轮换大量来源 IP 分摊请求、绕过单 IP 限流
#      （做法与 app/auth.py 的恢复码限流一致）；
#   3) 每日全局预算（OCR_DAILY_BUDGET 环境变量可调），这是真正兜底控制第三方
#      API 账单上限的一层——前两层只防"短时间刷"，防不住"一整天持续、不算频繁
#      的正常流量"把每日调用量堆到预算之外。超出后当天直接拒绝新请求，避免
#      服务被动欠下一笔无法预估的百度/DeepSeek 账单。
# 三层各用独立的 key，避免用同一份时间戳列表时，短窗口的过滤会把长窗口
# （每日）还需要的历史记录提前裁掉。
# 限流状态存于进程内存，多进程部署（如 uvicorn --workers N）下各进程互不可见，
# 生产环境建议换成 Redis 等共享存储实现。
_OCR_WINDOW_SECONDS = 60
_OCR_MAX_PER_IP = 10
_OCR_GLOBAL_MINUTE_WINDOW_SECONDS = 60
_OCR_GLOBAL_MINUTE_MAX_ATTEMPTS = 100
_OCR_GLOBAL_MINUTE_KEY = "__global_minute__"
_OCR_DAILY_WINDOW_SECONDS = 24 * 60 * 60
_OCR_DAILY_MAX_ATTEMPTS = int(os.getenv("OCR_DAILY_BUDGET", "300"))
_OCR_DAILY_KEY = "__global_daily__"
_ocr_attempts: dict[str, list[float]] = {}


def _ocr_rate_limit_ok(key: str, window_seconds: int, max_attempts: int) -> bool:
    now = time.time()
    attempts = [t for t in _ocr_attempts.get(key, []) if now - t < window_seconds]
    _ocr_attempts[key] = attempts
    return len(attempts) < max_attempts


def _record_ocr_attempt(key: str) -> None:
    _ocr_attempts.setdefault(key, []).append(time.time())


def _check_ocr_rate_limit(request: Request) -> None:
    client_key = request.client.host if request.client else "unknown"
    if not _ocr_rate_limit_ok(client_key, _OCR_WINDOW_SECONDS, _OCR_MAX_PER_IP):
        raise HTTPException(status_code=429, detail="请求过于频繁，请稍后再试")
    if not _ocr_rate_limit_ok(_OCR_GLOBAL_MINUTE_KEY, _OCR_GLOBAL_MINUTE_WINDOW_SECONDS, _OCR_GLOBAL_MINUTE_MAX_ATTEMPTS):
        raise HTTPException(status_code=429, detail="服务繁忙，请稍后再试")
    if not _ocr_rate_limit_ok(_OCR_DAILY_KEY, _OCR_DAILY_WINDOW_SECONDS, _OCR_DAILY_MAX_ATTEMPTS):
        logger.warning("OCR daily budget exhausted | limit: %d", _OCR_DAILY_MAX_ATTEMPTS)
        raise HTTPException(status_code=429, detail="今日识别次数已达上限，请明天再试")
    _record_ocr_attempt(client_key)
    _record_ocr_attempt(_OCR_GLOBAL_MINUTE_KEY)
    _record_ocr_attempt(_OCR_DAILY_KEY)


@app.post("/api/report/ocr", response_model=OcrResponse)
async def report_ocr(
    request: Request,
    file: UploadFile = File(...),
    user: User | None = Depends(_ocr_user_dependency),
):
    """只做 OCR：返回带位置的行级文字（统一 JSON）。

    登录后 App 会携带 Bearer token（可选鉴权：有 token 则校验，本地调试可不带）。
    """
    _check_ocr_rate_limit(request)
    mime = file.content_type or ""
    image_bytes = await file.read()
    _validate_image(mime, file.filename or "", len(image_bytes))
    _validate_image_bytes(mime, image_bytes)

    begin = time.time()
    try:
        words = recognize_image(image_bytes)
    except BaiduOcrError as e:
        raise HTTPException(502, detail=e.message)

    if not words:
        raise HTTPException(422, detail="未识别到文字，请确认图片是否清晰")

    duration_ms = int((time.time() - begin) * 1000)
    # 只记录计数与耗时，不记录健康数据
    logger.info("OCR success | wordsCount: %d | duration: %d ms", len(words), duration_ms)

    return OcrResponse(
        success=True,
        wordsCount=len(words),
        words=[WordItem(**w) for w in words],
    )


@app.post("/api/report/recognize")
async def report_recognize(
    request: Request,
    file: UploadFile = File(...),
    user: User | None = Depends(_ocr_user_dependency),
):
    """化验单 -> 百度「医疗检验报告单识别」直出结构化；识别不出（非化验单）
    -> 回退百度通用 OCR + DeepSeek。可选鉴权同 OCR 接口。"""
    _check_ocr_rate_limit(request)
    mime = file.content_type or ""
    image_bytes = await file.read()
    _validate_image(mime, file.filename or "", len(image_bytes))
    _validate_image_bytes(mime, image_bytes)

    begin = time.time()

    # —— 第一优先：百度「医疗检验报告单识别」，是化验单就直接结构化，跳过 DeepSeek ——
    try:
        med = recognize_lab_report(image_bytes)
    except BaiduOcrError as e:
        raise HTTPException(502, detail=e.message)
    if med is not None:
        mapped = map_medical_report(med)
        mapped_metrics = [
            m for m in mapped["metrics"]
            if m.get("rawName")
            and (m.get("numericValue") is not None or m.get("textValue"))
        ]
        if mapped_metrics:
            duration_ms = int((time.time() - begin) * 1000)
            logger.info(
                "MedicalReportOCR success | items: %d | duration: %d ms",
                len(mapped_metrics), duration_ms,
            )
            return JSONResponse(
                status_code=200,
                content={
                    "success": True,
                    "hospitalName": mapped["hospitalName"],
                    "reportDate": mapped["reportDate"],
                    "reportType": mapped["reportType"],
                    "patientName": mapped["patientName"],
                    "patientGender": mapped["patientGender"],
                    "patientBirthDate": mapped["patientBirthDate"],
                    "isMedical": True,
                    "imagingType": None,
                    "rawText": mapped["rawText"],
                    "metrics": mapped_metrics,
                },
            )
        # 专用模型认出是「检验报告」但没抠出可用项 -> 继续走通用 OCR 回退。

    # —— 回退：百度通用 OCR + DeepSeek ——
    try:
        words = recognize_image(image_bytes)
    except BaiduOcrError as e:
        raise HTTPException(502, detail=e.message)

    if not words:
        raise HTTPException(422, detail="未识别到文字，请确认图片是否清晰")

    # 交给 DeepSeek 结构化（只发文字+坐标，不把图片字节发给模型）
    try:
        structured = parse_ocr_result(words)
    except DeepSeekParseError as e:
        raise HTTPException(502, detail=e.message)

    metrics = [normalize_metric(m) for m in structured.get("metrics", [])]
    metrics = [
        m for m in metrics
        if m.get("rawName") and (m.get("numericValue") is not None or m.get("textValue"))
    ]
    # 0 指标不是错误。客户端按下面的字段分流：
    #   metrics 非空        -> 报告单（核对页）
    #   imagingType 有值    -> 影像（图文报告页）
    #   isMedical=False     -> 无法读取（不存）
    #   否则               -> 人工确认页（存未关联记录 / 手动 / 丢弃）
    raw_text = "\n".join(
        str(w.get("text", "")).strip()
        for w in words
        if str(w.get("text", "")).strip()
    )

    duration_ms = int((time.time() - begin) * 1000)
    # 只记录计数与耗时，不记录健康内容（rawText 不进日志）
    logger.info(
        "OCR+LLM success | OCR lines: %d | metrics: %d | imagingType: %s | isMedical: %s | %d ms",
        len(words), len(metrics), structured.get("imagingType"),
        structured.get("isMedical"), duration_ms,
    )

    return JSONResponse(
        status_code=200,
        content={
            "success": True,
            "hospitalName": structured.get("hospitalName"),
            "reportDate": structured.get("reportDate"),
            "reportType": structured.get("reportType"),
            "patientName": structured.get("patientName"),
            "patientGender": structured.get("patientGender"),
            "patientBirthDate": structured.get("patientBirthDate"),
            "isMedical": bool(structured.get("isMedical")),
            "imagingType": structured.get("imagingType"),
            "rawText": raw_text,
            "metrics": metrics,
        },
    )
