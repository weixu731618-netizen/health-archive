"""匿名身份认证（V0.5）。

- 首次启动自动创建匿名用户：服务端生成 user_id + opaque auth_token + recovery_code。
- auth_token：App 调用 API 的身份凭证（服务端只存 SHA-256 哈希，可轮换）。
- recovery_code：换机/重装时恢复身份（服务端只存 SHA-256 哈希，找回后重新签发 token）。
- 三者分离：user_id 只是内部标识，不能单独作为凭证。
- 权限规则：所有健康数据接口以 token 解析出的 user_id 为准，绝不信任前端传的 user_id。
"""
import hashlib
import secrets
import time

from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session

from app.db import get_db
from app.models import User

# 恢复码字符集（去除易混淆的 0/O/1/I/L）
_RECOVERY_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
_RECOVERY_GROUPS = 3
_RECOVERY_GROUP_LEN = 4
# 恢复失败限流：15 分钟内最多失败 5 次（按来源 IP 分桶）
_RECOVER_WINDOW_SECONDS = 900
_RECOVER_MAX_ATTEMPTS = 5
# 全局节流：1 分钟内全站最多失败 20 次，防止攻击者轮换大量来源 IP
# 绕过单 IP 限流、对不同恢复码做分布式穷举（单 IP 限流本身无法防御这种攻击）。
_GLOBAL_WINDOW_SECONDS = 60
_GLOBAL_MAX_ATTEMPTS = 20
_GLOBAL_KEY = "__global__"
_recover_attempts: dict[str, list[float]] = {}


def _hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def generate_recovery_code() -> str:
    """生成易保存的恢复码，例如 AB7K-29PX-4MQL。"""
    chars = "".join(secrets.choice(_RECOVERY_ALPHABET) for _ in range(_RECOVERY_GROUPS * _RECOVERY_GROUP_LEN))
    return "-".join(chars[i:i + _RECOVERY_GROUP_LEN] for i in range(0, len(chars), _RECOVERY_GROUP_LEN))


def _new_token() -> tuple[str, str]:
    """生成 opaque token：(明文, 哈希)。明文只返回一次给客户端。"""
    plain = secrets.token_urlsafe(32)
    return plain, _hash(plain)


def register_anonymous(db: Session) -> dict:
    """创建匿名用户，返回身份信息。"""
    recovery_code = generate_recovery_code()
    token_plain, token_hash = _new_token()

    user = User(
        account_type="anonymous",
        recovery_code_hash=_hash(recovery_code),
        auth_token_hash=token_hash,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "userId": user.id,
        "authToken": token_plain,
        "recoveryCode": recovery_code,
    }


def _rate_limit_ok(key: str, window_seconds: int, max_attempts: int) -> bool:
    now = time.time()
    attempts = [t for t in _recover_attempts.get(key, []) if now - t < window_seconds]
    _recover_attempts[key] = attempts
    return len(attempts) < max_attempts


def _record_failure(key: str) -> None:
    _recover_attempts.setdefault(key, []).append(time.time())


def recover_identity(recovery_code: str, db: Session, client_key: str = "unknown") -> dict:
    """用恢复码找回原账号，并重新签发新 token（旧 token 失效）。

    双重限流：
    - 按 client_key（通常为客户端 IP）分桶，避免单个来源的失败尝试
      连坐封禁所有用户的恢复接口；
    - 额外叠加一个全局节流阈值，防止攻击者轮换大量来源 IP 绕过单 IP
      限流、对不同恢复码做分布式穷举（这种攻击单靠 IP 分桶无法防御）。
    注意：限流状态存于进程内存，多进程部署（如 uvicorn --workers N）下
    各进程互不可见，生产环境建议换成 Redis 等共享存储实现。
    """
    code = (recovery_code or "").strip().upper()
    # 通用错误提示，避免枚举判断账号是否存在
    error = HTTPException(status_code=401, detail="恢复码无效或已失效")

    if not _rate_limit_ok(client_key, _RECOVER_WINDOW_SECONDS, _RECOVER_MAX_ATTEMPTS):
        raise HTTPException(status_code=429, detail="尝试次数过多，请稍后再试")
    if not _rate_limit_ok(_GLOBAL_KEY, _GLOBAL_WINDOW_SECONDS, _GLOBAL_MAX_ATTEMPTS):
        raise HTTPException(status_code=429, detail="尝试次数过多，请稍后再试")

    if len(code) < 8:
        _record_failure(client_key)
        _record_failure(_GLOBAL_KEY)
        raise error

    code_hash = _hash(code)
    user = db.query(User).filter(User.recovery_code_hash == code_hash).first()
    if user is None or user.disabled_at is not None:
        _record_failure(client_key)
        _record_failure(_GLOBAL_KEY)
        raise error

    # 成功：清空失败计数，重新签发 token（轮换）
    _recover_attempts.pop(client_key, None)
    token_plain, token_hash = _new_token()
    user.auth_token_hash = token_hash
    db.commit()
    db.refresh(user)

    return {
        "userId": user.id,
        "authToken": token_plain,
    }


def _resolve_user(token: str, db: Session) -> User | None:
    token_hash = _hash(token)
    user = db.query(User).filter(User.auth_token_hash == token_hash).first()
    if user is None or user.disabled_at is not None:
        return None
    return user


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    """强制登录依赖：从 Authorization: Bearer <token> 解析当前用户。"""
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="未登录")
    token = authorization.split(" ", 1)[1].strip()
    user = _resolve_user(token, db)
    if user is None:
        raise HTTPException(status_code=401, detail="登录凭证无效或已失效")
    return user


def optional_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User | None:
    """可选登录依赖：无 token 可匿名调试；带 token 则必须有效。"""
    if not authorization or not authorization.lower().startswith("bearer "):
        return None
    token = authorization.split(" ", 1)[1].strip()
    user = _resolve_user(token, db)
    if user is None:
        raise HTTPException(status_code=401, detail="登录凭证无效或已失效")
    return user
