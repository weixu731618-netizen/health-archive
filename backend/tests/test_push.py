"""B2 推送后端测试：device token 增删改、mock 发送、配置解析。

不需要任何 Apple / APNs 凭证——PUSH_ENABLED 未开时全部走 mock。
运行：python -m pytest tests/test_push.py -v
"""
import os
import tempfile

# 必须在导入 app 前设置环境
_tmp_push_db = tempfile.mktemp(suffix=".db")
os.environ["PUSH_DATABASE_URL"] = f"sqlite:///{_tmp_push_db}"
os.environ.pop("PUSH_ENABLED", None)  # 明确按「未启用」跑

from fastapi.testclient import TestClient  # noqa: E402

from app.push_db import init_push_db  # noqa: E402
from main import app  # noqa: E402
from services.apns_service import (  # noqa: E402
    ApnsConfig,
    MockApnsClient,
    get_apns_client,
    send_push_to_installation,
)

init_push_db()
client = TestClient(app)

INSTALL = "inst_test_0001"


def test_upsert_and_update_device_token():
    r = client.post(
        "/api/push/device-tokens",
        json={"installation_id": INSTALL, "token": "a" * 64, "platform": "ios"},
    )
    assert r.status_code == 200, r.text
    assert r.json()["ok"] is True

    # 同一 installation_id 再传 → 更新，不新增
    r = client.post(
        "/api/push/device-tokens",
        json={"installation_id": INSTALL, "token": "b" * 64, "platform": "ios"},
    )
    assert r.status_code == 200

    from app.models_push import DeviceToken
    from app.push_db import PushSessionLocal

    db = PushSessionLocal()
    rows = db.query(DeviceToken).filter(DeviceToken.installation_id == INSTALL).all()
    db.close()
    assert len(rows) == 1
    assert rows[0].token == "b" * 64


def test_delete_device_token_is_idempotent():
    client.post(
        "/api/push/device-tokens",
        json={"installation_id": "inst_del", "token": "c" * 64},
    )
    r = client.request(
        "DELETE", "/api/push/device-tokens", json={"installation_id": "inst_del"}
    )
    assert r.status_code == 200
    assert r.json()["deleted"] == 1
    # 再删一次仍 ok
    r = client.request(
        "DELETE", "/api/push/device-tokens", json={"installation_id": "inst_del"}
    )
    assert r.status_code == 200
    assert r.json()["deleted"] == 0


def test_status_and_test_push_use_mock_when_unconfigured():
    r = client.get("/api/push/status")
    assert r.status_code == 200
    assert r.json()["channel"] == "mock"

    client.post(
        "/api/push/device-tokens",
        json={"installation_id": "inst_send", "token": "d" * 64},
    )
    r = client.post(
        "/api/push/test",
        json={"installation_id": "inst_send", "title": "标题", "body": "正文"},
    )
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["ok"] is True
    assert body["channel"] == "mock"


def test_test_push_unknown_installation_returns_404():
    r = client.post("/api/push/test", json={"installation_id": "inst_nope"})
    assert r.status_code == 404


def test_apns_config_incomplete_falls_back_to_mock(monkeypatch):
    # PUSH_ENABLED=true 但缺 key → 仍然 mock，并列出缺失项
    monkeypatch.setenv("PUSH_ENABLED", "true")
    monkeypatch.setenv("APNS_KEY_ID", "ABC123")
    monkeypatch.delenv("APNS_TEAM_ID", raising=False)
    monkeypatch.delenv("APNS_PRIVATE_KEY", raising=False)
    monkeypatch.delenv("APNS_PRIVATE_KEY_PATH", raising=False)

    cfg = ApnsConfig.from_env()
    assert cfg.enabled is True
    assert cfg.is_complete is False
    assert "APNS_TEAM_ID" in cfg.missing_fields()

    client_obj = get_apns_client(force_reload=True)
    assert isinstance(client_obj, MockApnsClient)


def test_send_push_to_installation_missing_token():
    from app.push_db import PushSessionLocal

    db = PushSessionLocal()
    try:
        res = send_push_to_installation(db, "inst_missing", "t", "b")
    finally:
        db.close()
    assert res.ok is False
    assert res.channel == "none"
