"""B2：APNs 推送发送 service（真实 + mock）。

「代码优先、配置后补」：
  * 是否真正发送由 PUSH_ENABLED 控制（默认 false）。
  * Apple 侧参数全部来自环境变量（见 .env.example / IOS_PUSH_SETUP.md）：
      APNS_KEY_ID, APNS_TEAM_ID, APNS_BUNDLE_ID,
      APNS_PRIVATE_KEY (.p8 内容) 或 APNS_PRIVATE_KEY_PATH,
      APNS_USE_SANDBOX (true/false)
  * PUSH_ENABLED=false 或参数不全时，自动退化为 MockApnsClient：只记日志、不外发，
    保证没有 Apple 凭证也能开发 / 运行 / 测试。

真实 APNs 走 HTTP/2 + ES256 JWT（token-based，用 .p8 私钥），不需要证书文件。
"""
from __future__ import annotations

import logging
import os
import time
from dataclasses import dataclass

logger = logging.getLogger("uvicorn.error")


def _env_bool(name: str, default: bool = False) -> bool:
    return os.getenv(name, str(default)).strip().lower() in {"1", "true", "yes", "on"}


@dataclass
class ApnsConfig:
    enabled: bool
    key_id: str
    team_id: str
    bundle_id: str
    private_key: str  # PEM/.p8 文本内容
    use_sandbox: bool

    @classmethod
    def from_env(cls) -> "ApnsConfig":
        private_key = os.getenv("APNS_PRIVATE_KEY", "").strip()
        if not private_key:
            path = os.getenv("APNS_PRIVATE_KEY_PATH", "").strip()
            if path and os.path.isfile(path):
                with open(path, "r", encoding="utf-8") as fh:
                    private_key = fh.read().strip()
        return cls(
            enabled=_env_bool("PUSH_ENABLED", False),
            key_id=os.getenv("APNS_KEY_ID", "").strip(),
            team_id=os.getenv("APNS_TEAM_ID", "").strip(),
            bundle_id=os.getenv("APNS_BUNDLE_ID", "").strip(),
            private_key=private_key,
            use_sandbox=_env_bool("APNS_USE_SANDBOX", True),
        )

    @property
    def is_complete(self) -> bool:
        return bool(
            self.enabled
            and self.key_id
            and self.team_id
            and self.bundle_id
            and self.private_key
        )

    def missing_fields(self) -> list[str]:
        out = []
        if not self.enabled:
            out.append("PUSH_ENABLED")
        if not self.key_id:
            out.append("APNS_KEY_ID")
        if not self.team_id:
            out.append("APNS_TEAM_ID")
        if not self.bundle_id:
            out.append("APNS_BUNDLE_ID")
        if not self.private_key:
            out.append("APNS_PRIVATE_KEY/APNS_PRIVATE_KEY_PATH")
        return out


@dataclass
class ApnsResult:
    ok: bool
    channel: str  # 'apns' | 'mock'
    status_code: int | None = None
    detail: str | None = None


class MockApnsClient:
    """不外发，只记录日志。没有 Apple 凭证时的默认实现。"""

    channel = "mock"

    def __init__(self, reason: str = "") -> None:
        self._reason = reason

    def send(self, token: str, title: str, body: str, data: dict | None = None) -> ApnsResult:
        logger.info(
            "APNs mock send | token: %s… | title: %s | reason: %s",
            token[:8],
            title,
            self._reason or "PUSH disabled",
        )
        return ApnsResult(ok=True, channel="mock", detail=self._reason or "mock")


class RealApnsClient:
    """真实 APNs（token-based JWT + HTTP/2）。"""

    channel = "apns"

    def __init__(self, config: ApnsConfig) -> None:
        self._config = config
        self._jwt: tuple[str, float] | None = None  # (token, issued_at)

    def _auth_token(self) -> str:
        import jwt  # PyJWT，ES256 需要 cryptography

        now = time.time()
        if self._jwt and now - self._jwt[1] < 45 * 60:
            return self._jwt[0]
        token = jwt.encode(
            {"iss": self._config.team_id, "iat": int(now)},
            self._config.private_key,
            algorithm="ES256",
            headers={"kid": self._config.key_id},
        )
        self._jwt = (token, now)
        return token

    def _host(self) -> str:
        return (
            "https://api.sandbox.push.apple.com"
            if self._config.use_sandbox
            else "https://api.push.apple.com"
        )

    def send(self, token: str, title: str, body: str, data: dict | None = None) -> ApnsResult:
        import httpx

        payload = {"aps": {"alert": {"title": title, "body": body}, "sound": "default"}}
        if data:
            payload.update(data)
        headers = {
            "authorization": f"bearer {self._auth_token()}",
            "apns-topic": self._config.bundle_id,
            "apns-push-type": "alert",
        }
        try:
            with httpx.Client(http2=True, timeout=10) as client:
                resp = client.post(
                    f"{self._host()}/3/device/{token}", json=payload, headers=headers
                )
            ok = resp.status_code == 200
            if not ok:
                logger.warning("APNs send failed | status: %s | body: %s", resp.status_code, resp.text[:200])
            return ApnsResult(
                ok=ok,
                channel="apns",
                status_code=resp.status_code,
                detail=None if ok else resp.text[:200],
            )
        except Exception as exc:  # noqa: BLE001 - 外部依赖失败不应让接口 500
            logger.warning("APNs send exception | %s", exc)
            return ApnsResult(ok=False, channel="apns", detail=str(exc))


_client_cache: object | None = None


def get_apns_client(force_reload: bool = False):
    """按当前环境返回 APNs 客户端：配置齐全用真实，否则 mock。"""
    global _client_cache
    if _client_cache is not None and not force_reload:
        return _client_cache
    config = ApnsConfig.from_env()
    if config.is_complete:
        logger.info("APNs: 使用真实客户端 (sandbox=%s)", config.use_sandbox)
        _client_cache = RealApnsClient(config)
    else:
        reason = "缺少配置: " + ", ".join(config.missing_fields())
        logger.info("APNs: 使用 mock 客户端（%s）", reason)
        _client_cache = MockApnsClient(reason=reason)
    return _client_cache


def send_push_to_installation(
    db, installation_id: str, title: str, body: str, data: dict | None = None
) -> ApnsResult:
    """按 installation_id 查 device token 并发送。查不到返回 ok=False。"""
    from app.models_push import DeviceToken

    row = (
        db.query(DeviceToken)
        .filter(DeviceToken.installation_id == installation_id)
        .one_or_none()
    )
    if row is None:
        return ApnsResult(ok=False, channel="none", detail="该设备未注册推送 token")
    return get_apns_client().send(row.token, title, body, data)
