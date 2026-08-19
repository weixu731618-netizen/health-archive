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
import time

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse

from models.ocr_response import OcrResponse, WordItem
from models.structured_report import normalize_metric
from services.baidu_ocr_service import BaiduOcrError, recognize_image
from services.deepseek_report_parser import DeepSeekParseError, parse_ocr_result

logger = logging.getLogger("uvicorn.error")
app = FastAPI(title="HealthArchive Report Backend", version="0.4c")

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


@app.post("/api/report/ocr", response_model=OcrResponse)
async def report_ocr(file: UploadFile = File(...)):
    """只做 OCR：返回带位置的行级文字（统一 JSON）。"""
    mime = file.content_type or ""
    image_bytes = await file.read()
    _validate_image(mime, file.filename or "", len(image_bytes))

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
async def report_recognize(file: UploadFile = File(...)):
    """OCR + DeepSeek 结构化：图片 -> 百度 OCR -> DeepSeek -> 统一 JSON。"""
    mime = file.content_type or ""
    image_bytes = await file.read()
    _validate_image(mime, file.filename or "", len(image_bytes))

    begin = time.time()
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
    duration_ms = int((time.time() - begin) * 1000)
    # 只记录计数与耗时，不记录健康内容
    logger.info("OCR+LLM success | OCR lines: %d | metrics: %d | duration: %d ms",
                len(words), len(metrics), duration_ms)

    return JSONResponse(
        status_code=200,
        content={
            "success": True,
            "hospitalName": structured.get("hospitalName"),
            "reportDate": structured.get("reportDate"),
            "reportType": structured.get("reportType"),
            "patientName": structured.get("patientName"),
            "metrics": metrics,
        },
    )
