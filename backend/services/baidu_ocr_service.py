"""百度智能云 OCR 服务封装。

调用：通用文字识别（高精度含位置版）—— REST API `accurate`。
- 先拿 API Key + Secret 换取 access_token（全局缓存，避免每张图都申请）。
- 再把图片 base64 传给 OCR 接口拿到带文字与位置的结果。

隐私与异常约定：
- 本模块不打印 Key / Secret / 报告全文 / 患者姓名。
- 导出统一数据结构 {text, left, top, width, height}，供上层转成统一 JSON。
- 任何失败抛出 BaiduOcrError（含安全的上层提示文案）。
"""
import base64
import os
import threading
import time

import requests

# 环境变量名（按 V0.4C-1 约定）
BAIDU_OCR_API_KEY = os.getenv("BAIDU_OCR_API_KEY", "")
BAIDU_OCR_SECRET_KEY = os.getenv("BAIDU_OCR_SECRET_KEY", "")

# 通用文字识别（高精度含位置版）
BAIDU_ACCURATE_URL = "https://aip.baidubce.com/rest/2.0/ocr/v1/accurate"

BAIDU_TIMEOUT_SEC = 30

# access_token 缓存（模块级单例）
_token_lock = threading.Lock()
_cached_token: str | None = None
_token_expire_at: float = 0.0


class BaiduOcrError(Exception):
    """百度 OCR 调用失败的轻量异常；message 为可直接展示给用户的安全文案。"""

    def __init__(self, message: str):
        super().__init__(message)
        self.message = message


def _obtain_access_token() -> str:
    """用 API Key + Secret 换取 access_token（带全局缓存）。"""
    global _cached_token, _token_expire_at
    with _token_lock:
        # 提前 5 分钟刷新，避免令牌刚过期
        if _cached_token and time.time() < _token_expire_at - 300:
            return _cached_token

        if not BAIDU_OCR_API_KEY or not BAIDU_OCR_SECRET_KEY:
            raise BaiduOcrError("OCR 未配置：缺少 BAIDU_OCR_API_KEY / BAIDU_OCR_SECRET_KEY")

        url = "https://aip.baidubce.com/oauth/2.0/token"
        params = {
            "grant_type": "client_credentials",
            "client_id": BAIDU_OCR_API_KEY,
            "client_secret": BAIDU_OCR_SECRET_KEY,
        }
        try:
            resp = requests.post(url, params=params, timeout=BAIDU_TIMEOUT_SEC)
        except requests.RequestException:
            raise BaiduOcrError("网络连接失败，请稍后重试")
        if resp.status_code != 200:
            raise BaiduOcrError("OCR 认证失败（无法获取访问令牌）")
        data = resp.json()
        token = data.get("access_token")
        if not token:
            raise BaiduOcrError("OCR API Key 或 Secret Key 无效")
        # access_token 默认 30 天有效
        _cached_token = token
        _token_expire_at = time.time() + float(data.get("expires_in", 2592000))
        return token


def recognize_image(image_bytes: bytes) -> list[dict]:
    """调用通用文字识别（高精度含位置版），返回统一 [{text,left,top,width,height}]。

    - 图片为空或空结果会引发 BaiduOcrError。
    - 不打印任何报告内容。
    """
    if not image_bytes:
        raise BaiduOcrError("未收到图片")

    token = _obtain_access_token()
    b64 = base64.b64encode(image_bytes).decode("ascii")

    url = f"{BAIDU_ACCURATE_URL}?access_token={token}"
    try:
        resp = requests.post(
            url,
            params={"access_token": token},
            data={"image": b64},
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=BAIDU_TIMEOUT_SEC,
        )
    except requests.RequestException:
        raise BaiduOcrError("网络连接失败，请稍后重试")
    if resp.status_code != 200:
        raise BaiduOcrError("OCR 服务调用失败")

    body = resp.json()
    if isinstance(body, dict) and body.get("error_code"):
        raise BaiduOcrError("OCR 服务调用失败")  # 不把百度完整错误暴露给用户

    words_result = body.get("words_result") or []
    normalized = []
    for item in words_result:
        if not isinstance(item, dict):
            continue
        loc = item.get("location") or {}
        normalized.append(
            {
                "text": item.get("words", ""),
                "left": int(loc.get("left", 0)),
                "top": int(loc.get("top", 0)),
                "width": int(loc.get("width", 0)),
                "height": int(loc.get("height", 0)),
            }
        )
    # 过滤掉空文本行
    normalized = [w for w in normalized if w["text"].strip()]
    return normalized
