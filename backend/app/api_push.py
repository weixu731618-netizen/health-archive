"""B2：推送 device token 管理 + 测试发送接口。

即使没有任何 Apple / APNs 凭证，这些接口也能正常工作：
  * token 的增删改只操作本地 device_tokens 表；
  * 测试发送在未配置时走 mock（只记日志），返回 channel="mock"。
"""
import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.models_push import DeviceToken
from app.push_db import get_push_db
from services.apns_service import get_apns_client, send_push_to_installation

logger = logging.getLogger("uvicorn.error")

router = APIRouter(prefix="/api/push", tags=["push"])


class DeviceTokenIn(BaseModel):
    installation_id: str = Field(min_length=4, max_length=64)
    token: str = Field(min_length=8, max_length=200)
    platform: str = Field(default="ios", max_length=16)


class InstallationIn(BaseModel):
    installation_id: str = Field(min_length=4, max_length=64)


class TestPushIn(BaseModel):
    installation_id: str = Field(min_length=4, max_length=64)
    title: str = Field(default="健康档案", max_length=100)
    body: str = Field(default="这是一条测试推送", max_length=200)


@router.post("/device-tokens")
def upsert_device_token(payload: DeviceTokenIn, db: Session = Depends(get_push_db)):
    """按 installation_id upsert device token（重装 / 换 token 都走这里）。"""
    row = (
        db.query(DeviceToken)
        .filter(DeviceToken.installation_id == payload.installation_id)
        .one_or_none()
    )
    if row is None:
        row = DeviceToken(
            installation_id=payload.installation_id,
            token=payload.token,
            platform=payload.platform or "ios",
        )
        db.add(row)
    else:
        row.token = payload.token
        row.platform = payload.platform or row.platform
    db.commit()
    logger.info("push token upserted | installation: %s…", payload.installation_id[:8])
    return {"ok": True}


@router.delete("/device-tokens")
def delete_device_token(payload: InstallationIn, db: Session = Depends(get_push_db)):
    """按 installation_id 注销推送 token（幂等：不存在也返回 ok）。"""
    deleted = (
        db.query(DeviceToken)
        .filter(DeviceToken.installation_id == payload.installation_id)
        .delete()
    )
    db.commit()
    return {"ok": True, "deleted": int(deleted)}


@router.get("/status")
def push_status():
    """当前推送配置状态（不泄露密钥内容）。"""
    client = get_apns_client(force_reload=True)
    return {"channel": getattr(client, "channel", "unknown")}


@router.post("/test")
def send_test_push(payload: TestPushIn, db: Session = Depends(get_push_db)):
    """给指定设备发一条测试推送。未配置 APNs 时走 mock。"""
    result = send_push_to_installation(
        db, payload.installation_id, payload.title, payload.body
    )
    if not result.ok and result.channel == "none":
        raise HTTPException(status_code=404, detail=result.detail or "设备未注册")
    return {
        "ok": result.ok,
        "channel": result.channel,
        "status_code": result.status_code,
        "detail": result.detail,
    }
