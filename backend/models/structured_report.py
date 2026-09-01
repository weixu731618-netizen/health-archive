"""DeepSeek 结构化输出的统一模型（Pydantic 校验）。

对应 V0.4D 第 9、10 节：StructuredMedicalReport + RecognizedMetric。
仅用于后端把 DeepSeek 输出「读进来并校验」，不承担诊断/用药职责。
特殊结果（阴性/阳性/<0.01 等）用 numericValue/textValue/qualifier 表达，见第 12 节。
"""
from typing import Any, Optional
from pydantic import BaseModel, Field


class RecognizedMetricModel(BaseModel):
    """每条被结构化出的检查指标。"""
    rawName: str = ""                # 原始指标名称（OCR/尽量按报告）
    canonicalName: Optional[str] = None  # 规范化名（模型尽量给，Flutter 端再本地匹配校正）
    matchedMetricId: Optional[str] = None  # 模型建议的 metricId（Flutter 端本地校验/覆盖）
    # 数值：普通数字用 numericValue；特殊文本用 textValue；qualifier 记录 < >= 等符号
    numericValue: Optional[float] = None
    textValue: Optional[str] = None
    qualifier: Optional[str] = None
    value: Optional[float] = None    # 兼容旧字段（与 numericValue 同义，后端转出时保留）
    unit: Optional[str] = None
    referenceMin: Optional[float] = None
    referenceMax: Optional[float] = None
    referenceText: Optional[str] = None
    originalStatus: Optional[str] = None  # H / L / ↑ / ↓ / 异常 等原报告标记（仅核对）
    bodySystem: Optional[str] = None
    confidence: float = Field(default=0.0, ge=0.0, le=1.0)


class StructuredMedicalReportModel(BaseModel):
    """结构化报告（后端发给 Flutter 的统一结构）。"""
    hospitalName: Optional[str] = None
    reportDate: Optional[str] = None     # ISO 日期或 YYYY-MM-DD；看不清为 null
    reportType: Optional[str] = None     # 血常规/生化/肝功能…，不确定为 其他检验
    patientName: Optional[str] = None    # 仅供核对，不作为身份
    patientGender: Optional[str] = None  # 男/女；报告没写为 null。仅供预填档案资料
    patientBirthDate: Optional[str] = None  # YYYY-MM-DD；只写年龄不反推，为 null
    isMedical: bool = False              # 这张图的文字整体是不是医疗相关
    imagingType: Optional[str] = None    # 受限 12 类之一（X光/CT/…/疫苗接种），判不准为 null
    rawOcrTextLength: int = 0            # 仅用于日志统计，不含内容
    metrics: list[Any] = Field(default_factory=list)  # 每项为 dict（见 _normalize_metric）


def normalize_metric(raw: Any) -> dict:
    """把 DeepSeek 给出的任意 metric 结构标准化为统一 dict。

    规则（第 12 / 13 节）：
    - value 允许 numericValue / textValue / qualifier 组合，强转失败不丢数据。
    - unit / reference 无法确定则为 null（禁止用医学知识猜）。
    """
    if not isinstance(raw, dict):
        return {}
    def num(k):
        v = raw.get(k)
        if isinstance(v, (int, float)) and not isinstance(v, bool):
            return float(v)
        return None
    numeric = num("numericValue")
    if numeric is None:
        numeric = num("value")
    return {
        "rawName": str(raw.get("rawName") or ""),
        "canonicalName": raw.get("canonicalName") or None,
        "matchedMetricId": raw.get("matchedMetricId") or None,
        "numericValue": numeric,
        "textValue": raw.get("textValue") or None,
        "qualifier": raw.get("qualifier") or None,
        "unit": raw.get("unit") or None,
        "referenceMin": num("referenceMin"),
        "referenceMax": num("referenceMax"),
        "referenceText": raw.get("referenceText") or None,
        "originalStatus": raw.get("originalStatus") or None,
        "bodySystem": raw.get("bodySystem") or None,
        "confidence": float(raw.get("confidence") or 0.0),
    }
