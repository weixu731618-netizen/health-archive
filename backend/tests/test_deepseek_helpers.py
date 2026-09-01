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
