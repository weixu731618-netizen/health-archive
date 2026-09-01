"""百度智能云「医疗检验报告单识别」封装。

调用 REST API `medical_report_detection`：直接返回结构化的检验项目行
（项目名称 / 结果 / 单位 / 参考区间 / 结果提示…）和 15 个通用字段
（姓名 / 性别 / 年龄 / 医院 / 报告单名称 / 时间 …）。

用途：化验单走这条，省掉「通用 OCR + DeepSeek 猜结构」那条易歪的链路。
识别不出检验项目（不是化验单）时返回 None，调用方回退到通用 OCR。

隐私：不打印 Key / 报告全文 / 患者姓名。
复用 baidu_ocr_service 的 access_token 缓存（同一对 API Key / Secret）。
"""
import logging

import requests

from services.baidu_ocr_service import BaiduOcrError, _obtain_access_token

logger = logging.getLogger("uvicorn.error")

MEDICAL_REPORT_URL = (
    "https://aip.baidubce.com/rest/2.0/ocr/v1/medical_report_detection"
)
_TIMEOUT_SEC = 30


def _pairs_to_dict(seq) -> dict:
    """把 [{"word_name": k, "word": v}, ...] 转成 {k: v}。已是 dict 则原样返回。"""
    if isinstance(seq, dict):
        # 可能是 {字段名: {"word": v}} 或 {字段名: v}
        out = {}
        for k, v in seq.items():
            if isinstance(v, dict):
                out[str(k)] = str(v.get("word", "") or "")
            else:
                out[str(k)] = "" if v is None else str(v)
        return out
    out = {}
    if isinstance(seq, list):
        for it in seq:
            if isinstance(it, dict) and "word_name" in it:
                out[str(it.get("word_name"))] = str(it.get("word", "") or "")
    return out


def recognize_lab_report(image_bytes: bytes) -> dict | None:
    """化验单结构化识别。

    返回 {"common": {字段名: 值}, "items": [{字段名: 值}, ...]}；
    识别不到任何检验项目行（不是化验单）时返回 None。
    网络 / 鉴权失败抛 BaiduOcrError（与通用 OCR 一致，便于上层统一处理）。
    """
    if not image_bytes:
        raise BaiduOcrError("未收到图片")

    import base64

    token = _obtain_access_token()
    b64 = base64.b64encode(image_bytes).decode("ascii")
    try:
        resp = requests.post(
            MEDICAL_REPORT_URL,
            params={"access_token": token},
            data={"image": b64, "detect_direction": "true"},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=_TIMEOUT_SEC,
        )
    except requests.RequestException:
        raise BaiduOcrError("网络连接失败，请稍后重试")
    if resp.status_code != 200:
        raise BaiduOcrError("OCR 服务调用失败")

    body = resp.json()
    if isinstance(body, dict) and body.get("error_code"):
        code = body.get("error_code")
        # 6 = 无权限（接口未开通）；其余不把百度原始错误抛给用户
        if code in (6, 4, 17, 18, 19):
            logger.warning("medical_report_detection unavailable: error_code=%s", code)
            return None
        raise BaiduOcrError("OCR 服务调用失败")

    words_result = body.get("words_result") or {}
    common = _pairs_to_dict(words_result.get("CommonData"))

    raw_items = words_result.get("Item")
    items: list[dict] = []
    if isinstance(raw_items, list):
        for row in raw_items:
            d = _pairs_to_dict(row)
            if d:
                items.append(d)

    # 门槛：至少 2 个「有项目名 + 有结果」的行，才当它稳稳认出了检验报告单。
    # 否则（零星几行、误吐）返回 None，交上层走 高精OCR + DeepSeek 重新判。
    def _has_name_and_result(it: dict) -> bool:
        name = any(str(it.get(k, "")).strip() for k in ("项目名称", "名称", "检验项目", "项目"))
        result = any(str(it.get(k, "")).strip() for k in ("结果", "检查结果", "检验结果", "测定值"))
        return name and result

    solid = [it for it in items if _has_name_and_result(it)]
    if len(solid) < 2:
        return None
    return {"common": common, "items": items}
