"""匿名身份 API：注册、恢复、当前用户信息。"""
from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.auth import get_current_user, recover_identity, register_anonymous
from app.db import get_db
from app.models import User

router = APIRouter(tags=["anonymous"])


class RecoverRequest(BaseModel):
    recoveryCode: str


@router.post("/api/anonymous/register")
def anonymous_register(db: Session = Depends(get_db)):
    """首次启动自动创建匿名用户。返回 userId + authToken + recoveryCode。"""
    return register_anonymous(db)


@router.post("/api/anonymous/recover")
def anonymous_recover(req: RecoverRequest, request: Request, db: Session = Depends(get_db)):
    """用恢复码找回原账号并重新签发 token。限流按客户端 IP 分桶。"""
    client_key = request.client.host if request.client else "unknown"
    return recover_identity(req.recoveryCode, db, client_key=client_key)


@router.get("/api/auth/me")
def me(user: User = Depends(get_current_user)):
    return {"userId": user.id, "accountType": user.account_type}
