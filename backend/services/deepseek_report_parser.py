"""DeepSeek 结构化 Service。

职责：把 OCR 识别出的行级文字（含位置）交给 DeepSeek，返回统一 StructuredMedicalReport。

边界：
- DeepSeek 只做「文字 -> 结构」，不做诊断 / 用药 / 治疗建议。
- 报告里没有的信息必须返回 null，禁止用医学知识补全（单位/参考范围/日期等）。
- 严格只输出 JSON；非 JSON 或空结果 ⇒ 抛 DeepSeekParseError，交上层返回「报告结构化失败」。

隐私：本模块不打印 OCR 全文、患者姓名、报告内容；只允许记录结构化成功/数量/耗时。
"""
import json
import logging
import os
import time

import requests

from models.structured_report import (
    StructuredMedicalReportModel,
    normalize_metric,
)

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")
DEEPSEEK_BASE = os.getenv("DEEPSEEK_BASE", "https://api.deepseek.com")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")
DEEPSEEK_TIMEOUT_SEC = float(os.getenv("DEEPSEEK_TIMEOUT_SEC", "120"))
logger = logging.getLogger("uvicorn.error")

# 系统 Prompt 与业务代码分离，方便后续调整。
SYSTEM_PROMPT = '''你是医疗检验报告结构化工具，不是医生。
你的任务仅是根据 OCR 内容提取报告中明确存在的信息。
禁止使用医学知识补全报告没有的信息。
看不清或无法确定的字段必须返回 null。
必须严格按照 JSON Schema 输出，只输出 JSON，不要 Markdown，不要任何解释文字。
不要诊断疾病；不要给治疗、用药建议；不要解释检查结果。
JSON Schema（metric 的 value 用 numericValue/textValue/qualifier 组合表达，不要拼成字符串）：
{"hospitalName":"string"|null,"reportDate":"YYYY-MM-DD"|null,
"reportType":"血常规|生化|肝功能|肾功能|血脂|血糖|尿常规|甲状腺功能|凝血|免疫|其他检验",
"patientName":"string"|null,
"metrics":[{"rawName":"string","canonicalName":"string"|null,"matchedMetricId":"string"|null,
"numericValue":number|null,"textValue":"string"|null,"qualifier":"string"|null,
"unit":"string"|null,"referenceMin":number|null,"referenceMax":number|null,
"referenceText":"string"|null,"originalStatus":"string"|null,"bodySystem":"string"|null,
"confidence":number}]}
规则：数值型结果放 numericValue（并把 qualifier 填 <、>、<=、>= 等，无则 null）；
阴性/阳性等文本放 textValue；报告没有的参考范围/单位必须返回 null，不得猜。
只提取明确呈现为“检查项目 + 结果”的行；不要把姓名、年龄、日期、科室、条码、提示语、标题当作指标。
如果 OCR 内容不是医学检验/体检报告，或文字过少/过乱导致不能确认项目与结果，请返回 metrics: []。
不要根据常识生成报告中没有出现的指标。'''



class DeepSeekParseError(Exception):
    """DeepSeek 结构化失败或校验失败。message 为可展示的安全文案。"""

    def __init__(self, message: str = "报告结构化失败"):
        super().__init__(message)
        self.message = message


def _clean_json(content: str) -> str:
    """去掉模型可能附带的 ```json 代码块围护。"""
    s = content.strip()
    if s.startswith("```"):
        s = s.split("\n", 1)[-1]
    if s.endswith("```"):
        s = s[:-3]
    return s.strip()


def _call_deepseek(payload: dict) -> str:
    if not DEEPSEEK_API_KEY:
        raise DeepSeekParseError("AI 未配置：缺少 DEEPSEEK_API_KEY")
    headers = {
        "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        "Content-Type": "application/json",
    }
    try:
        resp = requests.post(
            f"{DEEPSEEK_BASE}/chat/completions",
            headers=headers,
            json=payload,
            timeout=DEEPSEEK_TIMEOUT_SEC,
        )
    except requests.RequestException:
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")
    if resp.status_code != 200:
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")
    body = resp.json()
    try:
        return body["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError):
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")


def parse_ocr_result(ocr_lines: list[dict]) -> dict:
    """把 OCR 行级文字（含位置）交给 DeepSeek，返回统一 structured dict。

    ocr_lines: [{"text":..,"left":..,"top":..,"width":..,"height":..}, ...]
    返回：StructuredMedicalReport 兼容 dict（metrics 已 normalize_metric）。
    """
    # 不把整张图片发给 DeepSeek；只发文字 + 坐标
    lines_input = [
        {
            "text": ln.get("text", ""),
            "left": ln.get("left", 0),
            "top": ln.get("top", 0),
            "width": ln.get("width", 0),
            "height": ln.get("height", 0),
        }
        for ln in ocr_lines
        if isinstance(ln, dict) and str(ln.get("text", "")).strip()
    ]
    if not lines_input:
        raise DeepSeekParseError("未识别到文字，请确认图片是否清晰")

    begin = time.time()
    user_payload = {
        "model": DEEPSEEK_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": json.dumps({"lines": lines_input}, ensure_ascii=False),
            },
        ],
        "temperature": 0.0,
        "response_format": {"type": "json_object"},
    }

    content = _call_deepseek(user_payload)
    duration_ms = int((time.time() - begin) * 1000)

    try:
        data = json.loads(_clean_json(content))
    except (json.JSONDecodeError, TypeError):
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")
    if not isinstance(data, dict):
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")

    # 用 Pydantic 模型兜底校验并规范化
    try:
        model = StructuredMedicalReportModel(
            hospitalName=data.get("hospitalName"),
            reportDate=data.get("reportDate"),
            reportType=data.get("reportType"),
            patientName=data.get("patientName"),
            metrics=[],
        )
    except Exception:
        raise DeepSeekParseError("报告结构化失败，请重新识别或使用手工录入")

    raw_metrics = data.get("metrics") if isinstance(data.get("metrics"), list) else []
    metrics = [normalize_metric(m) for m in raw_metrics]
    metrics = [m for m in metrics if m.get("rawName")]

    # 只记录计数与耗时，不记录健康内容
    logger.info(
        "LLM parse success | metrics extracted: %d | duration: %d ms",
        len(metrics),
        duration_ms,
    )

    return {
        "hospitalName": model.hospitalName,
        "reportDate": model.reportDate,
        "reportType": model.reportType,
        "patientName": model.patientName,
        "metrics": metrics,
    }
