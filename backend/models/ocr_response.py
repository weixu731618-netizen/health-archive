"""OCR 接口的统一响应模型（Pydantic）。"""
from pydantic import BaseModel


class WordItem(BaseModel):
    """一行 OCR 文字（含位置 bounding box）。"""
    text: str
    left: int = 0
    top: int = 0
    width: int = 0
    height: int = 0


class OcrResponse(BaseModel):
    """POST /api/report/ocr 的统一返回体。"""
    success: bool
    wordsCount: int
    words: list[WordItem]
