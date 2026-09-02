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


from models.medical_report_map import _metric_from_item  # noqa: E402


def test_region_label_name_falls_back_to_code():
    # 项目名读成"深圳HR"这类地区参考值列标：有干净代号 → 用代号
    m = _metric_from_item({
        "项目名称": "深圳HR", "项目代号": "AST",
        "结果": "21", "单位": "U/L", "参考区间": "15-40",
    })
    assert m["rawName"] == "AST"

    # 没有代号 → 整行丢掉，不把"深圳HR"当项目名
    assert _metric_from_item({
        "项目名称": "深圳R", "项目代号": "",
        "结果": "18", "单位": "umol/L", "参考区间": "0-26",
    }) is None


def test_clean_code_kept_as_alt_candidate_for_ocr_typos():
    # 名字是 OCR 错字（润接胆红素），代号 IBIL 干净 → canonicalName=IBIL 兜底
    m = _metric_from_item({
        "项目名称": "润接胆红素", "项目代号": "IBIL",
        "结果": "12", "单位": "umol/L", "参考区间": "2-14",
    })
    assert m["rawName"] == "润接胆红素"
    assert m["canonicalName"] == "IBIL"


def test_region_check_does_not_touch_real_abbreviations():
    for name in ("γ-GT", "25-OH-D", "HbA1c", "Ca2+"):
        m = _metric_from_item({
            "项目名称": name, "项目代号": "",
            "结果": "1.0", "单位": "x", "参考区间": "0-2",
        })
        assert m is not None and m["rawName"] == name
