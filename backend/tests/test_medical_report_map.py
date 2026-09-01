"""medical_report_map：按百度「医疗检验报告单识别」真实返回结构做映射测试。"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from models.medical_report_map import _parse_ref, map_medical_report  # noqa: E402
from services.baidu_medical_report_service import _pairs_to_dict  # noqa: E402

# 真实结构：words_result.Item 是「行的列表」，每行是 [{word_name, word}, ...]
_REAL_ITEM_ROWS = [
    [
        {"word_name": "仪器类型", "word": ""},
        {"word_name": "单位", "word": "*10^9/L"},
        {"word_name": "参考区间", "word": "4-11"},
        {"word_name": "测试方法", "word": ""},
        {"word_name": "结果", "word": "4.92"},
        {"word_name": "结果提示", "word": ""},
        {"word_name": "项目代号", "word": "WBC"},
        {"word_name": "项目名称", "word": "白细胞计数"},
    ],
    [
        {"word_name": "单位", "word": "%"},
        {"word_name": "参考区间", "word": "40-70"},
        {"word_name": "结果", "word": "85.30"},
        {"word_name": "结果提示", "word": "↑"},
        {"word_name": "项目名称", "word": "中性粒细胞百分比"},
    ],
    [
        {"word_name": "单位", "word": ""},
        {"word_name": "参考区间", "word": "阴性"},
        {"word_name": "结果", "word": "阴性"},
        {"word_name": "项目名称", "word": "尿隐血"},
    ],
]

_REAL_COMMON = [
    {"word_name": "医院", "word": "宝安区福永人民医院"},
    {"word_name": "时间", "word": "20260302"},
    {"word_name": "姓名", "word": "徐威"},
    {"word_name": "年龄", "word": "36岁"},
    {"word_name": "性别", "word": "男"},
    {"word_name": "报告单名称", "word": "血常规"},
]


def _build():
    common = _pairs_to_dict(_REAL_COMMON)
    items = [_pairs_to_dict(r) for r in _REAL_ITEM_ROWS]
    return map_medical_report({"common": common, "items": items})


def test_common_fields():
    r = _build()
    assert r["hospitalName"] == "宝安区福永人民医院"
    assert r["patientName"] == "徐威"
    assert r["patientGender"] == "男"
    assert r["reportType"] == "血常规"
    assert r["reportDate"] == "2026-03-02"  # 无分隔符 8 位也要解析出来
    assert r["patientBirthDate"] is None    # 只有年龄，不反推


def test_numeric_item():
    r = _build()
    wbc = next(m for m in r["metrics"] if m["rawName"] == "白细胞计数")
    assert wbc["numericValue"] == 4.92
    assert wbc["unit"] == "*10^9/L"
    assert wbc["referenceMin"] == 4.0
    assert wbc["referenceMax"] == 11.0
    assert wbc["textValue"] is None
    assert wbc["confidence"] == 0.99


def test_flag_and_range():
    r = _build()
    ne = next(m for m in r["metrics"] if m["rawName"] == "中性粒细胞百分比")
    assert ne["numericValue"] == 85.30
    assert ne["originalStatus"] == "↑"
    assert (ne["referenceMin"], ne["referenceMax"]) == (40.0, 70.0)


def test_textual_item():
    r = _build()
    bld = next(m for m in r["metrics"] if m["rawName"] == "尿隐血")
    assert bld["numericValue"] is None
    assert bld["textValue"] == "阴性"
    assert bld["referenceText"] == "阴性"


def test_parse_ref_double_dash():
    # OCR 常把区间连字符读成两个，旧写法会把上限读成负数 → 每项都判「偏高」
    assert _parse_ref("3.5--9.5")[:2] == (3.5, 9.5)
    assert _parse_ref("130--175")[:2] == (130.0, 175.0)
    assert _parse_ref("3.5-9.5")[:2] == (3.5, 9.5)
    assert _parse_ref("40－70")[:2] == (40.0, 70.0)
    assert _parse_ref("<9.5")[:2] == (None, 9.5)
    assert _parse_ref(">3.5")[:2] == (3.5, None)
    assert _parse_ref("阴性") == (None, None, "阴性")
