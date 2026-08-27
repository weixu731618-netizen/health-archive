"""数据库连接层：生产用 PostgreSQL，本地/测试可用 SQLite。

通过环境变量 DATABASE_URL 切换，例如：
  export DATABASE_URL=postgresql+psycopg://user:pass@localhost/healtharchive
本地默认 SQLite（无需安装数据库即可开发/测试）。
"""
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./backend_dev.db")


class Base(DeclarativeBase):
    """所有 ORM 模型的基类。"""


_connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, connect_args=_connect_args, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db():
    """FastAPI 依赖：提供一个数据库会话。"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """建表（幂等）。"""
    # 延迟导入，避免循环依赖
    from app import models  # noqa: F401
    Base.metadata.create_all(bind=engine)
