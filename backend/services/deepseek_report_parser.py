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
"patientName":"string"|null,"patientGender":"男|女"|null,"patientBirthDate":"YYYY-MM-DD"|null,
"isMedical":true|false,
"imagingType":"X光|CT|MRI|B超|彩超|心电图|病理|出院小结|手术记录|门诊病历|处方笺|疫苗接种"|null,
"metrics":[{"rawName":"string","canonicalName":"string"|null,"matchedMetricId":"string"|null,
"numericValue":number|null,"textValue":"string"|null,"qualifier":"string"|null,
"unit":"string"|null,"referenceMin":number|null,"referenceMax":number|null,
"referenceText":"string"|null,"originalStatus":"string"|null,"bodySystem":"string"|null,
"confidence":number}],
"examSummary":{"conclusion":"string"|null,"advice":["string",...],
"departments":[{"name":"string","finding":"string"}],
"general":{"heightCm":number|null,"weightKg":number|null,"bmi":number|null,
"waistCm":number|null,"systolic":number|null,"diastolic":number|null,"pulse":number|null}}|null}
examSummary：这份内容属于**健康体检报告**（哪怕只是其中一页）时就填——判断标准是
出现下列任意一类：① 一般项目（身高 / 体重 / BMI / 腰围 / 血压 / 脉搏）；
② 一个或多个科室的查体所见（内科 / 外科 / 眼科 / 耳鼻喉 / 口腔 / 妇科 / 外科等）；
③ 总检 / 主检结论或健康建议。都没有则填 null。
conclusion = 总检 / 主检结论那段话原文（没有就 null）；advice = 医生分条建议的每一条；
departments = 各科室检查所见，name 用科室名、finding 用**报告上实际印出来的原文**；
**空白 / 没填写的栏目不要补写“正常”“未见异常”**——只有报告确实写了才收，否则该科室
不出现。整张是空白 / 未填写的体检表模板 → examSummary 返回 null。
general = 一般项目里的数值，报告没有的填 null。
**化验室的检验项目仍然放进 metrics，不要重复放进 examSummary。**
patientGender 只在报告明确写了性别时填 男/女，否则 null；
patientBirthDate 只在报告明确写了出生日期时填 YYYY-MM-DD，只写了“年龄”不要反推，返回 null。
isMedical：这张图上的文字整体是不是医疗相关（检验单/影像报告/病历/出院小结/处方/体检/疫苗本
等 = true；海报/说明书/聊天截图/收据/随手拍/与医疗无关 = false）。文字太少太乱无法判断也填 false。
imagingType：**只有当这张确实是该类报告本身时**才填对应值；判不准、或它其实是检验单、或
只是体检套餐清单里列到该项目名，一律填 null。宁可 null 也不要猜。
规则：数值型结果放 numericValue（并把 qualifier 填 <、>、<=、>= 等，无则 null）；
阴性/阳性等文本放 textValue；报告没有的参考范围/单位必须返回 null，不得猜。
只提取明确呈现为“检查项目 + 结果”的行；不要把姓名、年龄、日期、科室、条码、提示语、标题当作指标。
如果 OCR 内容不是医学检验/体检报告，或文字过少/过乱导致不能确认项目与结果，请返回 metrics: []。
超声(B超/彩超)、CT、MRI、X光、心电图、病理等影像/描述性报告，即使含有器官尺寸、血流速度、
房室内径等测量数字，也一律返回 metrics: []——这些是描述性测量，不是可追踪的检验指标；
此类报告把 imagingType 填成对应检查类型，诊断结论保留在原始文字里即可。
不要根据常识生成报告中没有出现的指标。'''



IMAGING_TYPES = {
    "X光", "CT", "MRI", "B超", "彩超", "心电图", "病理",
    "出院小结", "手术记录", "门诊病历", "处方笺", "疫苗接种",
}


def _clean_imaging_type(v) -> str | None:
    """只接受受限的 12 类之一，其余（含 '其他'、模型自由发挥的值）一律 None。"""
    if not isinstance(v, str):
        return None
    s = v.strip()
    return s if s in IMAGING_TYPES else None


def _num_or_none(v):
    try:
        f = float(v)
    except (TypeError, ValueError):
        return None
    return f if f == f else None  # 排除 nan


def _clean_exam_summary(v) -> dict | None:
    """体检报告的结构化附加块。非体检报告 / 结构不对 → None。"""
    if not isinstance(v, dict):
        return None
    conclusion = v.get("conclusion")
    conclusion = conclusion.strip() if isinstance(conclusion, str) and conclusion.strip() else None

    advice = [
        s.strip() for s in (v.get("advice") or [])
        if isinstance(s, str) and s.strip()
    ]

    departments = []
    for d in (v.get("departments") or []):
        if not isinstance(d, dict):
            continue
        name = (d.get("name") or "").strip() if isinstance(d.get("name"), str) else ""
        finding = (d.get("finding") or "").strip() if isinstance(d.get("finding"), str) else ""
        if name and finding:
            departments.append({"name": name, "finding": finding})

    g = v.get("general") if isinstance(v.get("general"), dict) else {}
    general = {
        k: _num_or_none(g.get(k))
        for k in ("heightCm", "weightKg", "bmi", "waistCm",
                  "systolic", "diastolic", "pulse")
    }
    general = {k: val for k, val in general.items() if val is not None}

    if not (conclusion or advice or departments or general):
        return None
    return {
        "conclusion": conclusion,
        "advice": advice,
        "departments": departments,
        "general": general,
    }


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
            patientGender=data.get("patientGender"),
            patientBirthDate=data.get("patientBirthDate"),
            isMedical=bool(data.get("isMedical")),
            imagingType=_clean_imaging_type(data.get("imagingType")),
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
        "patientGender": model.patientGender,
        "patientBirthDate": model.patientBirthDate,
        "isMedical": model.isMedical,
        "imagingType": model.imagingType,
        "metrics": metrics,
        "examSummary": _clean_exam_summary(data.get("examSummary")),
    }


_CANON_SYSTEM_PROMPT = '''你把检验报告里的项目名映射到给定的「标准指标清单」。
规则：
- 只在名字明确指同一项时才给 id；拿不准一律返回 null。
- 百分比 / 比率 与 绝对值 / 计数 是不同的项，不要互相映射
  （如「中性粒细胞百分比」不等于「中性粒细胞绝对值」）。
- id 只能用清单里出现过的；清单里没有对应项就返回 null。
- 不做任何医学判断。
只输出 JSON：{"results":[{"raw":"原始名","id":"标准id或null","confidence":0到1的小数}]}'''


def canonicalize_metric_names(
    raw_names: list[str], candidates: list[dict]
) -> list[dict]:
    """把一批未匹配的项目名归一化到 candidates（[{id,name,unit?}]）里的标准 id。

    返回 [{"rawName":..,"canonicalId":..,"confidence":..}]，只含给出了 id 的项。
    任何失败（未配 key / 网络 / 非 JSON）都返回 []，绝不抛给上层。
    """
    names = [str(n).strip() for n in (raw_names or []) if str(n).strip()]
    cands = [
        {"id": str(c.get("id")), "name": str(c.get("name"))}
        for c in (candidates or [])
        if c.get("id") and c.get("name")
    ]
    if not names or not cands:
        return []
    payload = {
        "model": DEEPSEEK_MODEL,
        "messages": [
            {"role": "system", "content": _CANON_SYSTEM_PROMPT},
            {
                "role": "user",
                "content": json.dumps(
                    {"candidates": cands, "names": names}, ensure_ascii=False
                ),
            },
        ],
        "temperature": 0.0,
        "response_format": {"type": "json_object"},
    }
    try:
        content = _call_deepseek(payload)
        data = json.loads(_clean_json(content))
    except (DeepSeekParseError, json.JSONDecodeError, TypeError, KeyError):
        return []
    valid_ids = {c["id"] for c in cands}
    out: list[dict] = []
    for r in (data.get("results") or []) if isinstance(data, dict) else []:
        if not isinstance(r, dict):
            continue
        raw = str(r.get("raw", "")).strip()
        cid = r.get("id")
        if not raw or not cid or str(cid) not in valid_ids:
            continue
        try:
            conf = float(r.get("confidence", 0))
        except (TypeError, ValueError):
            conf = 0.0
        out.append(
            {"rawName": raw, "canonicalId": str(cid), "confidence": conf}
        )
    return out
