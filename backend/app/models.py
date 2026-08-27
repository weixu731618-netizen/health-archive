"""云端数据模型（V0.5）。

所有用户健康数据表都带 user_id；权限过滤一律以 token 解析出的 user_id 为准，
后端绝不信任前端传来的 user_id。
"""
import uuid
from datetime import date, datetime

from sqlalchemy import (
    Date, DateTime, Float, ForeignKey, Integer, String, Text, func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


def _uuid() -> str:
    return uuid.uuid4().hex


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=_uuid)  # user_id
    account_type: Mapped[str] = mapped_column(String(16), default="anonymous")
    # opaque auth_token 的 SHA-256 哈希（不存明文；可轮换）
    auth_token_hash: Mapped[str | None] = mapped_column(String(64), index=True)
    # 恢复码的 SHA-256 哈希（不存明文；用于换机恢复）
    recovery_code_hash: Mapped[str | None] = mapped_column(String(64))
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.now(), onupdate=func.now()
    )
    disabled_at: Mapped[datetime | None] = mapped_column(DateTime)


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    nickname: Mapped[str | None] = mapped_column(String(64))
    gender: Mapped[str | None] = mapped_column(String(8))
    birth_date: Mapped[date | None] = mapped_column(Date)
    height_cm: Mapped[float | None] = mapped_column(Float)
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class HealthMetric(Base):
    __tablename__ = "health_metrics"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    report_id: Mapped[int | None] = mapped_column(Integer, index=True)
    metric_id: Mapped[str] = mapped_column(String(32), index=True)
    metric_name: Mapped[str] = mapped_column(String(64))
    raw_name: Mapped[str | None] = mapped_column(String(64))
    value: Mapped[float] = mapped_column(Float)
    unit: Mapped[str] = mapped_column(String(32))
    reference_min: Mapped[float | None] = mapped_column(Float)
    reference_max: Mapped[float | None] = mapped_column(Float)
    status: Mapped[str] = mapped_column(String(16))
    body_system: Mapped[str] = mapped_column(String(32))
    match_type: Mapped[str] = mapped_column(String(16), default="manual")
    recognition_confidence: Mapped[float | None] = mapped_column(Float)
    measured_at: Mapped[date] = mapped_column(Date, index=True)
    source_type: Mapped[str] = mapped_column(String(16))
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class DailyHealthRecord(Base):
    __tablename__ = "daily_health_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    type: Mapped[str] = mapped_column(String(32))
    value1: Mapped[float] = mapped_column(Float)
    value2: Mapped[float | None] = mapped_column(Float)
    unit: Mapped[str] = mapped_column(String(32))
    context: Mapped[str | None] = mapped_column(String(64))
    measured_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class Report(Base):
    __tablename__ = "reports"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    hospital_name: Mapped[str | None] = mapped_column(String(128))
    report_date: Mapped[date | None] = mapped_column(Date)
    report_type: Mapped[str | None] = mapped_column(String(64))
    recognition_status: Mapped[str] = mapped_column(String(16), default="confirmed")
    raw_text: Mapped[str | None] = mapped_column(Text)  # 仅存后端需要；不打印
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class ReportMetric(Base):
    __tablename__ = "report_metrics"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    report_id: Mapped[int] = mapped_column(ForeignKey("reports.id"), index=True)
    raw_name: Mapped[str] = mapped_column(String(64))
    canonical_name: Mapped[str | None] = mapped_column(String(64))
    matched_metric_id: Mapped[str | None] = mapped_column(String(32))
    value: Mapped[float | None] = mapped_column(Float)
    text_value: Mapped[str | None] = mapped_column(String(64))
    unit: Mapped[str | None] = mapped_column(String(32))
    reference_text: Mapped[str | None] = mapped_column(String(64))
    status: Mapped[str] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class ReportFile(Base):
    __tablename__ = "report_files"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    # 上限 64 需与 api_backup.py 的 _FILE_ID_PATTERN 校验长度保持一致
    file_id: Mapped[str] = mapped_column(String(64), default=_uuid, index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    # 本字段保存客户端快照里的本地报告 id，用于恢复时重新关联图片；
    # 备份接口不把快照拆成服务端 reports 表，因此这里不能声明外键。
    report_id: Mapped[int] = mapped_column(Integer, index=True)
    object_key: Mapped[str] = mapped_column(String(256))  # 对象存储 key，DB 不存二进制
    mime_type: Mapped[str] = mapped_column(String(64))
    size_bytes: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class Backup(Base):
    __tablename__ = "backups"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    backup_id: Mapped[str] = mapped_column(String(32), default=_uuid, index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    app_version: Mapped[str] = mapped_column(String(16))
    schema_version: Mapped[int] = mapped_column(Integer, default=5)
    # 备份整体 JSON 快照在对象存储中的 key（私有）
    snapshot_key: Mapped[str] = mapped_column(String(256))


class Disease(Base):
    __tablename__ = "diseases"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    name: Mapped[str] = mapped_column(String(128))
    found_date: Mapped[date | None] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(16), default="当前存在")
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())


class Medication(Base):
    __tablename__ = "medications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    name: Mapped[str] = mapped_column(String(128))
    dosage: Mapped[str | None] = mapped_column(String(64))
    unit: Mapped[str | None] = mapped_column(String(32))
    times_per_day: Mapped[int | None] = mapped_column(Integer)
    start_date: Mapped[date | None] = mapped_column(Date)
    end_date: Mapped[date | None] = mapped_column(Date)
    status: Mapped[str] = mapped_column(String(16), default="当前使用")
    notes: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
