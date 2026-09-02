"""把百度「医疗检验报告单识别」的结构化结果映射成本项目统一响应。

统一响应字段与 /api/report/recognize 保持一致：
  hospitalName / reportDate / reportType / patientName / patientGender /
  patientBirthDate / rawText / metrics[]

metrics[] 每项字段同 models.structured_report.normalize_metric 的输出形状，
Flutter 端再做本地字典匹配（matchedMetricId / bodySystem）。
"""
import re
from typing import Any, Optional

# CommonData / Item 里同一含义可能的键名（不同版本/报告单叫法不一，都兜住）。
_K_HOSPITAL = ["医院", "医院名称", "医疗机构"]
_K_REPORT_NAME = ["报告单名称", "报告名称", "检查项目"]
_K_NAME = ["姓名", "患者姓名"]
_K_GENDER = ["性别"]
_K_TIME = ["时间", "报告时间", "检验时间", "报告日期", "采样时间", "送检时间"]
_K_DIAGNOSIS = ["临床诊断", "诊断"]
_K_ADVICE = ["建议"]
_K_PURPOSE = ["检查目的", "送检目的"]
_K_DEPT = ["科室"]
_K_SYMPTOM = ["临床症状"]
_K_SPECIMEN = ["标本种类", "标本", "标本情况"]

_ITEM_NAME = ["项目名称", "名称", "检验项目", "项目"]
_ITEM_CODE = ["项目代号", "项目代码", "代号", "序代号", "序号"]
_ITEM_RESULT = ["结果", "检查结果", "检验结果", "测定值"]
_ITEM_UNIT = ["单位"]
_ITEM_REF = ["参考区间", "参考范围", "参考值"]
_ITEM_FLAG = ["结果提示", "结果指标", "提示", "异常提示", "结果标志"]
_ITEM_METHOD = ["测试方法", "检查方法", "方法"]
_ITEM_INSTRUMENT = ["仪器类型", "仪器型号", "仪器"]


def _pick(d: dict, keys: list[str]) -> str:
    for k in keys:
        v = d.get(k)
        if v is not None and str(v).strip():
            return str(v).strip()
    return ""


def _gender(raw: str) -> Optional[str]:
    v = raw.strip()
    if v.startswith("男") or v.lower() in ("m", "male"):
        return "男"
    if v.startswith("女") or v.lower() in ("f", "female"):
        return "女"
    return None


def _iso_date(raw: str) -> Optional[str]:
    s = (raw or "").strip()
    # 有分隔符：2026-03-02 / 2026/3/2 / 2026年3月2日
    m = re.search(r"(19|20)\d{2}\s*[-/.年]\s*\d{1,2}\s*[-/.月]\s*\d{1,2}", s)
    if m:
        nums = re.findall(r"\d+", m.group(0))
    else:
        # 无分隔符 8 位：20260302
        m = re.search(r"\b((?:19|20)\d{2})(\d{2})(\d{2})\b", s)
        nums = list(m.groups()) if m else None
    if not nums or len(nums) < 3:
        return None
    y, mo, da = int(nums[0]), int(nums[1]), int(nums[2])
    if not (1 <= mo <= 12 and 1 <= da <= 31):
        return None
    return f"{y:04d}-{mo:02d}-{da:02d}"


def _num(raw: str) -> Optional[float]:
    m = re.search(r"-?\d+(?:\.\d+)?", raw or "")
    if not m:
        return None
    try:
        return float(m.group(0))
    except ValueError:
        return None


def _qualifier(raw: str) -> Optional[str]:
    for q in ("<=", ">=", "≤", "≥", "<", ">"):
        if raw.strip().startswith(q):
            return {"≤": "<=", "≥": ">="}.get(q, q)
    return None


def _parse_ref(raw: str) -> tuple[Optional[float], Optional[float], Optional[str]]:
    """参考区间 → (min, max, 原文)。解析不出数值也保留原文（如「阴性」「未见异常」）。"""
    s = (raw or "").strip()
    if not s:
        return None, None, None
    # 分隔符用 + 吞掉整串连字符：OCR 常把区间里的连字符读成两个（"3.5--9.5"），
    # 旧写法会让下限后那个多出来的 "-" 被下一组当成负号，上限被读成 -9.5，
    # 于是本地 computeStatus 里 value > max 恒成立，任何指标都判「偏高」。
    m = re.search(r"(-?\d+(?:\.\d+)?)\s*[-~—－]+\s*(-?\d+(?:\.\d+)?)", s)
    if m:
        lo, hi = float(m.group(1)), float(m.group(2))
        # 上限比下限还小、取绝对值后就落回正常，视作连字符被误读成负号
        if hi < lo and abs(hi) >= lo:
            hi = abs(hi)
        if hi < lo:
            lo, hi = hi, lo
        return lo, hi, s
    m = re.search(r"[<≤]\s*(-?\d+(?:\.\d+)?)", s)
    if m:
        return None, float(m.group(1)), s
    m = re.search(r"[>≥]\s*(-?\d+(?:\.\d+)?)", s)
    if m:
        return float(m.group(1)), None, s
    return None, None, s


# 干净的项目代号：以字母开头，字母/数字/斜杠/连字符（AST、CA19-9、25-OHD…）。
_CLEAN_CODE_RE = re.compile(r"^[A-Za-z][A-Za-z0-9/\-]{0,11}$")

# 「行政区划 / 大城市名 + 至多两个大写字母」——报告里"深圳HR / 全国HR / 华南R"
# 这类**地区参考值列标**被读进项目名 / 代号列时长这样。地名是有限、稳定的集合，
# 不是穷举垃圾串；且这个形状不会误伤 γ-GT、25-OH-D、Ca2+ 这类真项目缩写。
_REGION_LABEL_RE = re.compile(
    r"^[（(]?("
    r"全国|华[东南西北中]|[东西][北南]|"
    r"北京|上海|天津|重庆|广州|深圳圳*|深*圳|杭州|南京|成都|武汉|"
    r"广东|浙江|江苏|四川|湖[北南]|福建|山东|河[北南]|辽宁|安徽"
    r")\s*[A-Z]{0,2}[）)]?$"
)


def _metric_from_item(it: dict) -> Optional[dict]:
    name = _pick(it, _ITEM_NAME)
    code = _pick(it, _ITEM_CODE)
    clean_code = code if _CLEAN_CODE_RE.match(code or "") else ""
    result = _pick(it, _ITEM_RESULT)
    if not result:
        return None
    # 结构性规则（不认具体串）：
    #  1. 项目代号是干净英文缩写时它比项目名可靠——始终作为客户端匹配候选
    #     （canonicalName），能救"润接胆红素/电配"这类 OCR 错字行。
    #  2. 项目名是"地区参考值列标"（深圳HR / 全国R…）→ 名字作废，改用代号；
    #     没有代号 → 整行丢掉（宁可少一项，别在核对页显示"深圳HR"）。
    name_is_region_label = bool(name) and bool(_REGION_LABEL_RE.match(name))
    if name and not name_is_region_label:
        raw_name = name
        alt_name = clean_code if (clean_code and clean_code != name) else None
    elif clean_code and not _REGION_LABEL_RE.match(clean_code):
        raw_name = clean_code
        alt_name = None
    else:
        return None
    ref_min, ref_max, ref_text = _parse_ref(_pick(it, _ITEM_REF))
    numeric = _num(result)
    is_textual = numeric is None or re.search(r"[阴阳未见正常异常阴阳]", result)
    return {
        "rawName": raw_name,
        "canonicalName": alt_name,
        "matchedMetricId": None,
        "numericValue": None if is_textual else numeric,
        "textValue": result if is_textual else None,
        "qualifier": _qualifier(result),
        "unit": _pick(it, _ITEM_UNIT) or None,
        "referenceMin": ref_min,
        "referenceMax": ref_max,
        "referenceText": ref_text,
        "originalStatus": _pick(it, _ITEM_FLAG) or None,
        "bodySystem": None,
        "confidence": 0.99,  # 百度专用模型直出，信任度高于 DeepSeek 猜
    }


def map_medical_report(med: dict[str, Any]) -> dict:
    common = med.get("common") or {}
    items = med.get("items") or []

    metrics = []
    for it in items:
        m = _metric_from_item(it)
        if m:
            metrics.append(m)

    # rawText：把通用字段里有内容的拼一段，供详情页 / 图文回退展示，也进不了日志。
    lines = []
    for label, keys in [
        ("医院", _K_HOSPITAL), ("报告单", _K_REPORT_NAME), ("科室", _K_DEPT),
        ("标本", _K_SPECIMEN), ("检查目的", _K_PURPOSE), ("临床症状", _K_SYMPTOM),
        ("临床诊断", _K_DIAGNOSIS), ("建议", _K_ADVICE), ("时间", _K_TIME),
    ]:
        v = _pick(common, keys)
        if v:
            lines.append(f"{label}：{v}")

    return {
        "hospitalName": _pick(common, _K_HOSPITAL) or None,
        "reportDate": _iso_date(_pick(common, _K_TIME)),
        "reportType": _pick(common, _K_REPORT_NAME) or "其他检验",
        "patientName": _pick(common, _K_NAME) or None,
        "patientGender": _gender(_pick(common, _K_GENDER)),
        "patientBirthDate": None,  # 报告单通常只有「年龄」，不反推出生日期
        "rawText": "\n".join(lines),
        "metrics": metrics,
    }
