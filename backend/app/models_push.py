"""B2 推送模块 ORM：只有一张 device_tokens 表。

用匿名 installation_id 作为设备身份（不依赖账号）。同一台设备重装 / 换 token
时按 installation_id upsert。
"""
from datetime import datetime

from sqlalchemy import DateTime, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.push_db import PushBase


class DeviceToken(PushBase):
    __tablename__ = "device_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    # 客户端生成的匿名安装标识（每次全新安装换一个）
    installation_id: Mapped[str] = mapped_column(
        String(64), unique=True, index=True, nullable=False
    )
    # APNs device token（十六进制字符串）
    token: Mapped[str] = mapped_column(String(200), nullable=False)
    platform: Mapped[str] = mapped_column(String(16), default="ios")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now()
    )
