# iOS 推送（APNs）配置清单

> 代码已经写好（Flutter 端 + FastAPI 后端），**现在不配置也能开发 / 运行 / 测试**：
> 未配置时后端只保存 device token，不真正发推送（测试接口走 mock）；Flutter 端
> `PUSH_ENABLED=false` 时不注册 APNs。
>
> 等你准备好 Apple Developer 账号后，按本文件把参数填进 `backend/.env` 即可，
> **不需要改推送代码**。

---

## 1. 现在能用的（无需 Apple 配置）

- 复查提醒 / 服药提醒写入本地 `reminders` + `notifications` 表。
- **本地系统通知**（`flutter_local_notifications`）：复查一次性、服药每日重复，
  离线可用、按设备时区。iOS 首次创建提醒时会弹通知权限。
- 应用内「提醒」页 + 首页「待办提醒」摘要卡。
- 后端 `/api/push/device-tokens`（增删改）、`/api/push/status`、`/api/push/test`
  已挂载；未配置 APNs 时 `/api/push/test` 返回 `channel: "mock"`。

远程 APNs 推送是**额外的送达渠道**（未来用于服务端主动下发，如跨设备/家庭成员事件）。

---

## 2. 需要在 Apple 侧创建的东西

| 步骤 | 在哪里 | 产出 |
|---|---|---|
| 加入 Apple Developer Program（$99/年；公司主体需 D-U-N-S） | developer.apple.com | Team ID（10 位，如 `ZZ8JW5PS4S`） |
| 注册正式 App ID / Bundle ID，勾选 **Push Notifications** 能力 | Certificates, IDs & Profiles → Identifiers | Bundle ID（如 `com.weixu.healthArchive`） |
| 创建 **APNs Auth Key（.p8）** | Keys → 新建，勾 Apple Push Notifications service (APNs) | 一个 `.p8` 私钥文件（**只能下载一次**）+ Key ID（10 位） |
| Xcode 里给 Runner target 开 **Push Notifications** capability | Xcode → Signing & Capabilities → + Capability | `Runner.entitlements` 增加 `aps-environment` |
| （TestFlight/真机调试）确认 entitlement 为 `development`；正式版为 `production` | Xcode 自动按构建配置处理 | — |

> 用 **.p8 Auth Key** 方式，不需要 APNs 证书（.p12）。一个 Key 同时覆盖 sandbox 和 production。

---

## 3. 填进 `backend/.env` 的参数

```dotenv
PUSH_ENABLED=true
APNS_KEY_ID=<Keys 页面那个 10 位 Key ID>
APNS_TEAM_ID=<Membership 页面的 Team ID>
APNS_BUNDLE_ID=com.weixu.healthArchive
# .p8 私钥：二选一
APNS_PRIVATE_KEY_PATH=/opt/healtharchive/secrets/AuthKey_XXXX.p8
# 或者直接把 .p8 文件内容（含 BEGIN/END 行）贴成一行，用 \n 连接：
# APNS_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
# TestFlight / 真机调试 = true；App Store 正式版 = false
APNS_USE_SANDBOX=true
```

安全：`.p8` 不要提交 Git；服务器上权限设 `600`；`backend/.env` 已被 `.gitignore` 排除。

---

## 4. 编译 Flutter 时打开推送

```bash
flutter build ios --release \
  --dart-define=REPORT_API_BASE=https://api.tuoputeng.com \
  --dart-define=PUSH_ENABLED=true
```

`PUSH_ENABLED=true` 时 App 启动会向 iOS 申请 APNs 注册，拿到 device token 后
`POST {REPORT_API_BASE}/api/push/device-tokens`（匿名 `installation_id`，不需要账号）。

---

## 5. 验证

1. 后端 `python -m pytest backend/tests/test_push.py -v`（device token 增删改 + mock 发送，**不需要真实凭证**）。
2. 配好 `.env` 后重启后端，`GET /api/push/status` 应返回 `{"channel": "apns"}`。
3. 真机装上带 `PUSH_ENABLED=true` 的包，看后端日志有 `push token upserted`。
4. `POST /api/push/test {"installation_id": "<该设备的>"}` → 真机应收到测试推送。

---

## 6. 代码位置

| 层 | 文件 | 作用 |
|---|---|---|
| Flutter | `lib/services/push_service.dart` | APNs 注册、token 上传、`PUSH_ENABLED` 开关、匿名 installation_id |
| Flutter | `lib/services/notification_service.dart` | 本地系统通知排程（复查/服药） |
| iOS 原生 | `ios/Runner/AppDelegate.swift` | `health_archive/push` MethodChannel：触发注册、回传 device token |
| 后端 | `backend/app/push_db.py` / `models_push.py` | `device_tokens` 表（独立小库，与云备份开关无关） |
| 后端 | `backend/app/api_push.py` | `/api/push/device-tokens`、`/status`、`/test` |
| 后端 | `backend/services/apns_service.py` | APNs 发送 service：真实（.p8 JWT + HTTP/2）/ mock 自动切换 |

---

## 7. 尚未做（后续）

- **服务端定时下发**：目前到点提醒由**设备本地通知**负责。若要服务端按 `reminders`
  排程主动 push（例如设备长期不开），需要后端加一个 scheduler（cron/APScheduler）
  读取同步过来的提醒并调 `send_push_to_installation`。届时还需把 `reminders` 同步到后端。
- **App 备案**：工信部要求，App 调用域名后端服务需单独报备，见 `IOS_V1_V6_ROADMAP.md` 第 14 节。
- Android FCM（当前只做了 iOS APNs）。
