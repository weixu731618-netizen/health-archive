"""对象存储抽象：报告原图与备份快照。

- 生产：Cloudflare R2（S3 兼容 API，私有桶，不生成永久公开 URL）。
- 本地/测试：Mock 本地目录（STORAGE_BACKEND=local，默认）。

更换对象存储供应商只需新增一个 Provider，不影响业务代码。
"""
import os
import time
import uuid

STORAGE_BACKEND = os.getenv("STORAGE_BACKEND", "local").lower()
LOCAL_STORAGE_DIR = os.getenv("LOCAL_STORAGE_DIR", "./storage_local")
_R2_BUCKET = os.getenv("R2_BUCKET", "")
_R2_ACCOUNT_ID = os.getenv("R2_ACCOUNT_ID", "")
_R2_ACCESS_KEY = os.getenv("R2_ACCESS_KEY", "")
_R2_SECRET_KEY = os.getenv("R2_SECRET_KEY", "")


class ObjectStorage:
    def put(self, key: str, data: bytes, content_type: str) -> None:
        raise NotImplementedError

    def get(self, key: str) -> bytes:
        raise NotImplementedError

    def delete(self, key: str) -> None:
        raise NotImplementedError

    def signed_url(self, key: str, expires_seconds: int = 600) -> str | None:
        """短时有效下载 URL；不支持则返回 None（由后端鉴权下载）。"""
        return None


class LocalObjectStorage(ObjectStorage):
    """开发/测试用：文件写入本地目录。"""

    def __init__(self, base_dir: str = LOCAL_STORAGE_DIR) -> None:
        self.base_dir = base_dir
        os.makedirs(base_dir, exist_ok=True)

    def _path(self, key: str) -> str:
        # 防止路径穿越：只允许落在 base_dir 内的相对 key
        safe = key.replace("\\", "/").lstrip("/")
        base = os.path.abspath(self.base_dir)
        path = os.path.abspath(os.path.join(base, safe))
        if os.path.commonpath([base, path]) != base:
            raise ValueError("invalid storage key")
        return path

    def put(self, key: str, data: bytes, content_type: str) -> None:
        path = self._path(key)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as f:
            f.write(data)

    def get(self, key: str) -> bytes:
        with open(self._path(key), "rb") as f:
            return f.read()

    def delete(self, key: str) -> None:
        path = self._path(key)
        if os.path.exists(path):
            os.remove(path)

    def signed_url(self, key: str, expires_seconds: int = 600) -> str | None:
        # 本地模式无公网 URL，返回 None（由后端读取字节返回）
        return None


class R2ObjectStorage(ObjectStorage):
    """Cloudflare R2（S3 兼容）。密钥只从环境变量读取。"""

    def __init__(self) -> None:
        try:
            import boto3
            from botocore.config import Config as BotoConfig
        except ImportError as exc:  # pragma: no cover
            raise RuntimeError("未安装 boto3，请 pip install boto3") from exc

        if not (_R2_ACCOUNT_ID and _R2_ACCESS_KEY and _R2_SECRET_KEY and _R2_BUCKET):
            raise RuntimeError("缺少 R2 环境变量（R2_ACCOUNT_ID/R2_ACCESS_KEY/R2_SECRET_KEY/R2_BUCKET）")

        self.bucket = _R2_BUCKET
        self.client = boto3.client(
            "s3",
            endpoint_url=f"https://{_R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
            aws_access_key_id=_R2_ACCESS_KEY,
            aws_secret_access_key=_R2_SECRET_KEY,
            config=BotoConfig(signature_version="s3v4", region_name="auto"),
        )

    def put(self, key: str, data: bytes, content_type: str) -> None:
        self.client.put_object(Bucket=self.bucket, Key=key, Body=data, ContentType=content_type)

    def get(self, key: str) -> bytes:
        resp = self.client.get_object(Bucket=self.bucket, Key=key)
        return resp["Body"].read()

    def delete(self, key: str) -> None:
        self.client.delete_object(Bucket=self.bucket, Key=key)

    def signed_url(self, key: str, expires_seconds: int = 600) -> str:
        # 私有桶短时签名 URL（默认 10 分钟），不生成永久公开 URL
        return self.client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket, "Key": key},
            ExpiresIn=expires_seconds,
        )


def build_storage() -> ObjectStorage:
    if STORAGE_BACKEND == "r2":
        return R2ObjectStorage()
    return LocalObjectStorage()


def new_object_key(user_id: str, kind: str, ext: str) -> str:
    """生成不信任用户文件名的对象 key。"""
    safe_ext = (ext or "bin").lower().strip(".")
    return f"users/{user_id}/{kind}/{uuid.uuid4().hex}.{safe_ext}"
