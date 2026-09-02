import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from services.deepseek_report_parser import _clean_imaging_type  # noqa: E402


def test_clean_imaging_type_accepts_12():
    for t in ("X光", "CT", "MRI", "B超", "彩超", "心电图", "病理",
              "出院小结", "手术记录", "门诊病历", "处方笺", "疫苗接种"):
        assert _clean_imaging_type(t) == t
    assert _clean_imaging_type("  CT ") == "CT"


def test_clean_imaging_type_rejects_others():
    for v in ("其他", "超声", "胸片", "体检报告", "", None, 123, "报告单"):
        assert _clean_imaging_type(v) is None


from services.deepseek_report_parser import canonicalize_metric_names  # noqa: E402
from main import _apply_canonicalization  # noqa: E402


def test_canonicalize_no_key_or_empty_returns_empty():
    # 测试环境没有 DEEPSEEK_API_KEY → 优雅退化成 []
    assert canonicalize_metric_names(["白细胞数目"], [{"id": "WBC", "name": "白细胞计数"}]) == []
    assert canonicalize_metric_names([], [{"id": "WBC", "name": "白细胞计数"}]) == []
    assert canonicalize_metric_names(["白细胞"], []) == []


def test_apply_canonicalization_is_noop_without_dictionary_or_pending():
    metrics = [{"rawName": "白细胞计数", "matchedMetricId": "WBC", "numericValue": 5}]
    assert _apply_canonicalization(metrics, None) == (0, 0)
    assert _apply_canonicalization(metrics, "not json") == (0, 0)
    # 有字典但所有项已匹配 → 无待处理
    assert _apply_canonicalization(metrics, '[{"id":"WBC","name":"白细胞计数"}]') == (0, 0)
    # 待处理项存在但模型不可用 → 不改动、不抛
    pending = [{"rawName": "某个怪名字", "numericValue": 1}]
    hit, _ms = _apply_canonicalization(pending, '[{"id":"WBC","name":"白细胞计数"}]')
    assert hit == 0
    assert "matchedMetricId" not in pending[0]


from services.deepseek_report_parser import _clean_exam_summary  # noqa: E402


def test_clean_exam_summary_valid():
    r = _clean_exam_summary({
        "conclusion": "  血脂偏高  ",
        "advice": ["低脂饮食", "  ", 3],
        "departments": [
            {"name": "内科", "finding": "心律齐"},
            {"name": "", "finding": "x"},
            {"name": "外科", "finding": ""},
        ],
        "general": {"systolic": 130, "diastolic": "85", "bmi": None, "pulse": 76},
    })
    assert r["conclusion"] == "血脂偏高"
    assert r["advice"] == ["低脂饮食"]
    assert r["departments"] == [{"name": "内科", "finding": "心律齐"}]
    assert r["general"] == {"systolic": 130.0, "diastolic": 85.0, "pulse": 76.0}


def test_clean_exam_summary_empty_or_bad():
    assert _clean_exam_summary(None) is None
    assert _clean_exam_summary("nope") is None
    assert _clean_exam_summary({}) is None
    assert _clean_exam_summary({"advice": [], "departments": [], "general": {}}) is None
