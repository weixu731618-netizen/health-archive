"""备份 / 恢复 / 删除云端数据 / 注销账号 API。

安全约定：
- 所有接口必须登录（get_current_user），权限以 token 解析的 user_id 为准。
- 报告原图二进制只进对象存储（私有），PostgreSQL 只存元数据。
- 服务端不信任客户端文件名：对象 key 由服务端生成。
"""
import json
import os
import re
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.db import get_db
from app.models import (
    Backup, DailyHealthRecord, Disease, HealthMetric, Medication, Report,
    ReportFile, ReportMetric, User, UserProfile,
)
from app.storage import build_storage, new_object_key
from app.auth import get_current_user

router = APIRouter(prefix="/api/backup", tags=["backup"])

_ALLOWED_MIME = {"image/jpeg", "image/png"}
_MAX_FILE_BYTES = 20 * 1024 * 1024  # 20MB
_FILE_ID_PATTERN = re.compile(r"^[A-Za-z0-9_-]{1,64}$")


def _require_user(user: User) -> str:
    return user.id


def _valid_image_bytes(mime: str | None, body: bytes) -> bool:
    if mime == "image/png":
        return body.startswith(b"\x89PNG\r\n\x1a\n")
    if mime == "image/jpeg":
        return body.startswith(b"\xff\xd8\xff")
    return False


@router.post("")
def create_backup(
    data: str = Form(...),
    files: list[UploadFile] = File(default=[]),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """整体备份：data 为 JSON 快照，files 为报告原图（文件名=fileId）。

    data.reportFiles 中每一项需声明 {fileId, localReportId, mime, size}，
    上传文件按该列表顺序对应，filename 必须为 fileId + 扩展名。
    """
    user_id = _require_user(user)
    storage = build_storage()

    try:
        snapshot = json.loads(data)
    except (json.JSONDecodeError, TypeError):
        raise HTTPException(status_code=422, detail="备份数据不是有效 JSON")

    snapshot.setdefault("schemaVersion", 5)
    snapshot.setdefault("appVersion", "1.0.0")
    snapshot.setdefault("createdAt", datetime.now(timezone.utc).isoformat())

    report_files = snapshot.get("reportFiles", [])
    if not isinstance(report_files, list) or any(not isinstance(f, dict) for f in report_files):
        raise HTTPException(status_code=422, detail="reportFiles 格式不正确")
    declared = {f.get("fileId") for f in report_files}

    for upload in files:
        file_id = os.path.splitext(os.path.basename(upload.filename or ""))[0]
        if not _FILE_ID_PATTERN.fullmatch(file_id):
            raise HTTPException(status_code=422, detail="上传文件 id 格式不正确")
        if file_id not in declared:
            raise HTTPException(status_code=422, detail=f"上传文件 {file_id} 未在 reportFiles 中声明")
        if upload.content_type not in _ALLOWED_MIME:
            raise HTTPException(status_code=422, detail="仅支持 JPG/PNG 图片")
        body = upload.file.read()
        if not _valid_image_bytes(upload.content_type, body):
            raise HTTPException(status_code=422, detail="图片格式与文件类型不一致")
        if len(body) > _MAX_FILE_BYTES:
            raise HTTPException(status_code=422, detail="图片超过大小限制（20MB）")

        meta = next((f for f in report_files if f.get("fileId") == file_id), None)
        if meta is None:
            raise HTTPException(status_code=422, detail=f"缺少 {file_id} 的元数据")
        declared_size = meta.get("size")
        if isinstance(declared_size, int) and declared_size != len(body):
            raise HTTPException(status_code=422, detail="图片大小与声明不一致")
        # 不信任用户文件名，服务端生成对象 key
        ext = os.path.splitext(upload.filename or "")[1] or ".jpg"
        key = new_object_key(user_id, "reports", ext.lstrip("."))
        storage.put(key, body, upload.content_type or "image/jpeg")

        db.add(ReportFile(
            file_id=file_id,
            user_id=user_id,
            report_id=int(meta.get("localReportId", 0)) or 0,
            object_key=key,
            mime_type=upload.content_type or "image/jpeg",
            size_bytes=len(body),
        ))

    backup_id = _snapshot_id()
    snapshot_key = f"users/{user_id}/backups/{backup_id}.json"
    storage.put(snapshot_key, json.dumps(snapshot, ensure_ascii=False).encode("utf-8"), "application/json")
    db.add(Backup(
        user_id=user_id,
        backup_id=backup_id,
        snapshot_key=snapshot_key,
        app_version=str(snapshot.get("appVersion", "")),
        schema_version=int(snapshot.get("schemaVersion", 5)),
    ))
    db.commit()
    return {"success": True, "backupId": backup_id, "backedFiles": len(files)}


@router.get("/latest")
def latest_backup(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """返回该用户最新备份的完整快照 JSON（含报告文件元数据）。"""
    user_id = _require_user(user)
    backup = (
        db.query(Backup)
        .filter(Backup.user_id == user_id)
        .order_by(Backup.created_at.desc())
        .first()
    )
    if backup is None:
        return {"hasBackup": False, "snapshot": None}

    storage = build_storage()
    try:
        raw = storage.get(backup.snapshot_key)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="备份文件不存在")
    snapshot = json.loads(raw.decode("utf-8"))
    snapshot["backupId"] = backup.backup_id
    snapshot["backupCreatedAt"] = backup.created_at.isoformat() if backup.created_at else None
    return {"hasBackup": True, "snapshot": snapshot}


@router.get("/files/{file_id}")
def download_file(
    file_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """鉴权下载报告原图（私有；不生成公开 URL）。"""
    user_id = _require_user(user)
    record = (
        db.query(ReportFile)
        .filter(ReportFile.file_id == file_id, ReportFile.user_id == user_id)
        # 同一 fileId 可能因多次备份产生多条记录，取最新一次上传的对象。
        .order_by(ReportFile.created_at.desc())
        .first()
    )
    if record is None:
        raise HTTPException(status_code=404, detail="文件不存在")
    storage = build_storage()
    try:
        body = storage.get(record.object_key)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="文件不存在")
    from fastapi.responses import Response
    return Response(
        content=body,
        media_type=record.mime_type,
        headers={"X-Content-Type-Options": "nosniff"},
    )


@router.delete("/data")
def delete_cloud_data(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """删除云端健康数据（保留登录账号）。"""
    user_id = _require_user(user)
    storage = build_storage()

    files = db.query(ReportFile).filter(ReportFile.user_id == user_id).all()
    for f in files:
        try:
            storage.delete(f.object_key)
        except FileNotFoundError:
            pass
    backups = db.query(Backup).filter(Backup.user_id == user_id).all()
    for b in backups:
        try:
            storage.delete(b.snapshot_key)
        except FileNotFoundError:
            pass

    for model in (UserProfile, HealthMetric, DailyHealthRecord, Report,
                  ReportMetric, ReportFile, Backup, Disease, Medication):
        db.query(model).filter(model.user_id == user_id).delete(synchronize_session=False)
    db.commit()
    return {"success": True}


@router.delete("/account")
def delete_account(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """注销账号：删除云端健康数据 + 报告文件 + 账号。"""
    user_id = _require_user(user)
    delete_cloud_data(db=db, user=user)
    db.query(User).filter(User.id == user_id).delete()
    db.commit()
    return {"success": True}


def _snapshot_id() -> str:
    import uuid
    return uuid.uuid4().hex
