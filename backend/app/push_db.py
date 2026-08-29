"""B2 推送模块专用的数据库连接（与 V0.5 云备份的 DATABASE_URL 相互独立）。

推送要在 v1 精简模式（ENABLE_CLOUD_BACKUP=false）下也能用，所以不复用 app/db.py 的
Base（那会连带建出 users / backups 等一整套云备份表）。这里只建 device_tokens 一张表。

配置：环境变量 PUSH_DATABASE_URL，默认本地 SQLite（sqlite:///./push_dev.db）。
"""
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

PUSH_DATABASE_URL = os.getenv("PUSH_DATABASE_URL", "sqlite:///./push_dev.db")


class PushBase(DeclarativeBase):
    """推送模块 ORM 基类。"""


_connect_args = (
    {"check_same_thread": False} if PUSH_DATABASE_URL.startswith("sqlite") else {}
)
push_engine = create_engine(
    PUSH_DATABASE_URL, connect_args=_connect_args, pool_pre_ping=True
)
PushSessionLocal = sessionmaker(bind=push_engine, autoflush=False, autocommit=False)


def get_push_db():
    """FastAPI 依赖：提供一个推送库会话。"""
    db = PushSessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_push_db() -> None:
    """建表（幂等）。"""
    from app import models_push  # noqa: F401

    PushBase.metadata.create_all(bind=push_engine)
