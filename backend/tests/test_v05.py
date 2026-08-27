"""V0.5 匿名方案后端测试：注册、token、恢复码、越权隔离、备份/恢复、删除。

运行前设置：
  export DATABASE_URL=sqlite:///./test_v05.db
  python -m pytest tests -v
"""
import json
import os
import tempfile

# 必须在导入 app 前设置环境
_tmp_db = tempfile.mktemp(suffix=".db")
os.environ["DATABASE_URL"] = f"sqlite:///{_tmp_db}"
os.environ["STORAGE_BACKEND"] = "local"
os.environ["LOCAL_STORAGE_DIR"] = tempfile.mkdtemp(prefix="v05_storage_")
# 本测试文件覆盖 v2 云备份全套接口（注册/token/恢复码/备份/越权隔离/OCR 可选鉴权），
# 需要显式开启 ENABLE_CLOUD_BACKUP，否则 main.py 默认按 v1 精简版跑：
# 不挂载 auth_router/backup_router、不建表、OCR 接口也不做真实鉴权校验，
# 会导致本文件里的鉴权类断言（如 401）失败。
os.environ["ENABLE_CLOUD_BACKUP"] = "true"

from fastapi.testclient import TestClient  # noqa: E402

from app.db import init_db  # noqa: E402
from main import app  # noqa: E402

init_db()  # 手动建表（TestClient 非 with 形式不触发 lifespan）

client = TestClient(app)


def _register() -> dict:
    resp = client.post("/api/anonymous/register")
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body.get("userId")
    assert body.get("authToken")
    assert body.get("recoveryCode")
    return body


def _auth(token: str):
    return {"Authorization": f"Bearer {token}"}


def _backup_payload(metrics=1):
    return {
        "schemaVersion": 5,
        "appVersion": "1.0.0",
        "metrics": [
            {
                "metricId": "HBA1C",
                "metricName": "糖化血红蛋白",
                "value": 6.8,
                "unit": "%",
                "status": "偏高",
                "bodySystem": "血糖代谢",
                "measuredAt": "2026-08-19",
                "sourceType": "manual",
            }
            for _ in range(metrics)
        ],
        "daily": [],
        "reports": [],
        "reportMetrics": [],
        "reportFiles": [],
        "diseases": [],
        "medications": [],
    }


def test_anonymous_register_and_me():
    ident = _register()
    me = client.get("/api/auth/me", headers=_auth(ident["authToken"]))
    assert me.status_code == 200
    body = me.json()
    assert body["userId"] == ident["userId"]
    assert body["accountType"] == "anonymous"


def test_recovery_code_recovers_account_and_rotates_token():
    ident = _register()
    # 用恢复码找回
    resp = client.post("/api/anonymous/recover", json={"recoveryCode": ident["recoveryCode"]})
    assert resp.status_code == 200, resp.text
    recovered = resp.json()
    assert recovered["userId"] == ident["userId"]
    assert recovered["authToken"] != ident["authToken"]  # 重新签发

    # 新 token 可用，旧 token 失效
    assert client.get("/api/auth/me", headers=_auth(recovered["authToken"])).status_code == 200
    assert client.get("/api/auth/me", headers=_auth(ident["authToken"])).status_code == 401


def test_recovery_with_bad_code_fails_generic():
    resp = client.post("/api/anonymous/recover", json={"recoveryCode": "INVALID-XXXX"})
    assert resp.status_code == 401
    assert "无效或已失效" in resp.json()["detail"]


def test_backup_requires_auth():
    resp = client.post("/api/backup", data={"data": "{}"})
    assert resp.status_code == 401


def test_backup_and_latest():
    ident = _register()
    resp = client.post(
        "/api/backup",
        data={"data": json.dumps(_backup_payload(metrics=2))},
        headers=_auth(ident["authToken"]),
    )
    assert resp.status_code == 200, resp.text
    backup_id = resp.json()["backupId"]

    latest = client.get("/api/backup/latest", headers=_auth(ident["authToken"]))
    assert latest.status_code == 200
    body = latest.json()
    assert body["hasBackup"] is True
    assert body["snapshot"]["backupId"] == backup_id
    assert len(body["snapshot"]["metrics"]) == 2


def test_user_isolation():
    """越权访问：用户 B 的 token 不能读取/下载用户 A 的数据。"""
    a = _register()
    b = _register()
    image = b"\xff\xd8\xff" * 40
    payload = _backup_payload(metrics=1)
    payload["reports"] = [{"localId": 1, "hospitalName": "深圳某医院"}]
    payload["reportFiles"] = [
        {"fileId": "report-001", "localReportId": 1, "mime": "image/jpeg", "size": len(image)}
    ]
    resp = client.post(
        "/api/backup",
        data={"data": json.dumps(payload)},
        files=[("files", ("report-001.jpg", image, "image/jpeg"))],
        headers=_auth(a["authToken"]),
    )
    assert resp.status_code == 200, resp.text

    # B 看不到 A 的备份
    latest_b = client.get("/api/backup/latest", headers=_auth(b["authToken"]))
    assert latest_b.status_code == 200
    assert latest_b.json()["hasBackup"] is False

    # B 不能下载 A 的文件
    dl = client.get("/api/backup/files/report-001", headers=_auth(b["authToken"]))
    assert dl.status_code == 404

    # A 本人能用声明的 fileId 正确下载回同一张图片（回归：file_id 曾被服务端随机
    # UUID 覆盖，导致本人也永远下载不到）
    dl_owner = client.get("/api/backup/files/report-001", headers=_auth(a["authToken"]))
    assert dl_owner.status_code == 200, dl_owner.text
    assert dl_owner.content == image


def test_backup_rejects_disguised_image_upload():
    ident = _register()
    payload = _backup_payload(metrics=1)
    payload["reportFiles"] = [
        {"fileId": "report-002", "localReportId": 1, "mime": "image/jpeg", "size": 12}
    ]
    resp = client.post(
        "/api/backup",
        data={"data": json.dumps(payload)},
        files=[("files", ("report-002.jpg", b"not an image", "image/jpeg"))],
        headers=_auth(ident["authToken"]),
    )
    assert resp.status_code == 422


def test_delete_cloud_data_keeps_account():
    ident = _register()
    client.post(
        "/api/backup",
        data={"data": json.dumps(_backup_payload())},
        headers=_auth(ident["authToken"]),
    )
    resp = client.delete("/api/backup/data", headers=_auth(ident["authToken"]))
    assert resp.status_code == 200
    # 账号与 token 仍有效
    assert client.get("/api/auth/me", headers=_auth(ident["authToken"])).status_code == 200
    # 备份已清空
    latest = client.get("/api/backup/latest", headers=_auth(ident["authToken"]))
    assert latest.json()["hasBackup"] is False


def test_delete_account_invalidates_token():
    ident = _register()
    resp = client.delete("/api/backup/account", headers=_auth(ident["authToken"]))
    assert resp.status_code == 200
    assert client.get("/api/auth/me", headers=_auth(ident["authToken"])).status_code == 401


def test_ocr_with_and_without_token():
    """OCR 接口可选鉴权：无 token 可用，带合法 token 也可用。"""
    import io
    tiny = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64
    r1 = client.post(
        "/api/report/ocr", files={"file": ("a.png", io.BytesIO(tiny), "image/png")}
    )
    assert r1.status_code != 401  # 无 token 不被拒（本地/小图会走 502 或 422）
    ident = _register()
    r2 = client.post(
        "/api/report/ocr",
        files={"file": ("a.png", io.BytesIO(tiny), "image/png")},
        headers=_auth(ident["authToken"]),
    )
    assert r2.status_code != 401


def test_ocr_rejects_invalid_bearer_token():
    """OCR 可匿名调试，但如果客户端显式带 token，就不能静默忽略坏凭证。"""
    import io
    tiny = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64
    resp = client.post(
        "/api/report/ocr",
        files={"file": ("a.png", io.BytesIO(tiny), "image/png")},
        headers=_auth("bad-token"),
    )
    assert resp.status_code == 401


def test_ocr_rate_limit_blocks_excessive_requests():
    """连续高频请求应触发 429，防止匿名调用方无限调用付费的 OCR/DeepSeek 接口。"""
    import io
    tiny = b"\x89PNG\r\n\x1a\n" + b"\x00" * 64
    statuses = []
    for _ in range(15):
        resp = client.post(
            "/api/report/ocr", files={"file": ("a.png", io.BytesIO(tiny), "image/png")}
        )
        statuses.append(resp.status_code)
    assert 429 in statuses
    assert statuses[-1] == 429
