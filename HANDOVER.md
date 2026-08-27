# HealthArchive（健康档案）交接文件

> 本文件用于快速重建上下文。最后更新：2026-08-26，v1 精简版发布准备——OCR 每日预算上限 + `ENABLE_CLOUD_BACKUP` 开关把账号/云备份整体做成可选（见第 13 节）。此前更新：2026-08-26，真实图片识别端到端联调，修复多个隐藏 bug（见第 11 节）；2026-08-19，V0.5.1（本地完整备份，免服务器，推荐默认路径）+ V0.5（匿名身份 + 云端备份/恢复，进阶可选项）。

---

## 0. 一句话定位

一个面向中国成年人的「个人健康档案」Flutter App（MVP→V0.5）：本地 Drift 为主数据源，可拍照/上传医院化验单，经 FastAPI 后端 + 百度 OCR + DeepSeek 结构化后由用户确认入库；V0.5 起支持**匿名账号 + 云端备份/恢复**（不做实时同步）。

---

## 1. 项目位置与产物

- **项目根目录**：`D:\健康ios项目mvp-20260819` （**注意：含中文路径**）
- **最新 Release APK**：`D:\健康ios项目mvp-20260819\release\health-archive-v1.0.0.apk`
  - 大小：63,013,452 字节（≈ 60 MB）
  - 版本：`1.0.0+1`，applicationId/namespace：`com.weixu.health`，App 名「健康档案」
  - 构建说明：正式 APK **只能在纯英文路径**（如 `D:\health_archive_build`）构建，因为原项目中文路径下 Flutter release 的 AOT 无法写 `app.dill`（`D:\����ios��mvp...` 乱码）。构建后在临时目录 `android/gradle.properties` 加 `kotlin.incremental=false` 可规避 Kotlin 增量缓存写入失败；**原项目 gradle.properties 不要加**。
  - 已把这套「同步到英文路径临时目录 → 构建 → 拷回 release/」的流程写成脚本 `scripts/build_release_apk.ps1`，用法见脚本头部注释。**必须由用户在自己开的终端里手动运行**，不能用 Claude Code 的工具调用执行（见第 6 节 Gradle loopback 已知问题）。
- **前端在线预览**：`lib/` 里 `flutter run -d chrome`（web 构建可用）。

---

## 2. 技术栈与依赖

- Flutter 3.47.0 / Dart 3.13.0（Windows + Android 14 API34 模拟器环境已配好）
- 状态：无状态管理框架（全局单例 + 编译期注入）
- Drift 本地数据库（schemaVersion=5），表：HealthMetrics / DailyHealthRecords / MedicalReports / Diseases / Medications / UserProfile
- FastAPI 后端（backend/）+ 百度 OCR + DeepSeek（结构化）
- 关键 pub 依赖：drift、drift_flutter、file_picker(10.3.10)、path_provider、image_picker、http、flutter_secure_storage、shared_preferences
- 关键后端依赖（backend/requirements.txt，已 pip 安装到本机 Python3.14）：fastapi、uvicorn、SQLAlchemy、psycopg、PyJWT、python-dotenv、pytest、httpx

---

## 3. 目录结构（backend）

```
backend/
  main.py                        # FastAPI 入口：/api/report/ocr、/api/report/recognize、挂载 auth+backup
  app/db.py                      # SQLAlchemy engine（DATABASE_URL 环境变量：PG生产/SQLite本地）
  app/models.py                  # 云端表：users(匿名)/user_profiles/health_metrics/daily/reports/report_metrics/report_files/backups/diseases/medications
  app/auth.py                    # 匿名注册，opaque token（仅存 SHA-256），恢复码（哈希存储），get_current_user，限流
  app/sms.py                     # 【V0.5 已删除】手机号方案弃用
  app/storage.py                 # 对象存储抽象：LocalObjectStorage(默认)/R2ObjectStorage(私有桶+短时签名URL)
  app/api_auth.py                # /api/anonymous/register、/api/anonymous/recover、/api/auth/me
  app/api_backup.py              # /api/backup(整体备份+原图上传)、/latest、/files/{file_id}、DELETE /data、DELETE /account
  tests/test_v05.py              # 9 个 pytest（匿名注册/恢复码/越权隔离/备份/恢复/删除/注销/OCR鉴权）
```

---

## 4. V0.5 匿名方案（当前主线）

- 首次启动 App → 自动 `POST /api/anonymous/register` → 服务端生成 `user_id` + opaque `auth_token` + `recovery_code`。
- 三要素分离：`user_id` 只是内部标识，不单独作凭证；`auth_token` 是 API 凭证（服务端只存 SHA-256 哈希、可轮换）；`recovery_code` 用于换机/重装恢复（同样只存哈希，找回后重新签发 token，旧 token 失效）。
- 权限铁律：所有健康数据 API 用 `auth_token` 解析出的 `current_user_id` 做 `WHERE user_id=...` 过滤，**绝不信任前端传来的 user_id**（有越权测试：用户 A 的 token 不能读/删 B 的数据或文件）。
- 恢复码有频率/失败次数限制 + 通用错误提示，防枚举。
- 备份/恢复为「整体」模式：立即备份上传本地 Drift 快照 JSON + 报告原图（文件只进对象存储/本地私有目录，PostgreSQL 只存元数据）；恢复=下载最新备份覆盖/重建本地 Drift。
- 删除云端备份（保留账号）/ 彻底删除匿名档案（删账号）均需二次确认。
- OCR/DeepSeek 后端 API 用「可选鉴权」：有 token 则校验，无 token 本地调试也可用（避免本地无 Key 挂）。
- 暂不做：手机号/短信/密码/第三方登录、实时多设备同步、复杂冲突合并。

---

## 4.1 V0.5.1 本地完整备份（免服务器，推荐默认路径）

个人/小范围使用场景下，V0.5 的自建后端（FastAPI+DB+对象存储）属于过度设计——需要用户自己长期部署运维一台服务器才有意义。V0.5.1 加了一条**零服务器**的备份路径，且现在是「数据与隐私」页面里推荐的默认选项；V0.5 云端备份代码原样保留，作为进阶可选项共存，两者互不影响。

- `lib/services/local_backup_service.dart`：`exportBundle()` 把 `HealthRepository.exportHealthData()` 的 JSON 快照 + 所有报告原图打包成一个 zip（`archive` 包），写到应用文档目录 `exports/`；`exportAndShare()` 额外调用 `share_plus` 唤起系统分享面板，用户自己选择发到微信文件传输助手/网盘/AirDrop 等任意渠道保存，不经过任何自建服务器。`restoreFromFile()`/`pickAndRestore()` 走 `file_picker` 选择之前导出的 zip，解包图片落盘、解析 JSON，交给 `SnapshotImporter` 覆盖重建本地 Drift。
- `lib/services/snapshot_importer.dart`：把「快照 JSON → 覆盖重建本地 Drift」这段逻辑从 `CloudBackupService` 里提出来做成公共的 `SnapshotImporter.restore(repo, snapshot, {reportImagePaths})`，`CloudBackupService.restore()` 与 `LocalBackupService.restoreFromFile()` 共用；本地路径额外传入 `reportImagePaths`（旧报告 id → 恢复后的新图片路径），因此本地恢复能找回报告原图，**比云端恢复更完整**（云端恢复目前仍不带回原图，见下）。
- 页面入口：「数据与隐私」`PrivacyPage` 新增「备份（推荐）」分组：「完整备份并分享」「从备份文件恢复」（二次确认覆盖提示）；原 JSON 导出改名为「导出健康数据（纯文本）」放进「其它」分组，说明它不含报告原图。
- 往返测试：`test/local_backup_service_test.dart`，用假的 `PathProviderPlatform`（临时目录）+ 内存 Drift，验证 export→restore 后 profile/report/图片字节/metric 的 reportId 映射/daily/disease/medication 都能正确还原。

---

## 5. Flutter 侧对接

- 全局单例：`identityService`（首次启动 `unawaited(ensureIdentity())` 自动匿名注册，token/恢复码存 secure storage，web 回退 shared_preferences）、`cloudBackupService`（V0.5 进阶可选项，需自建后端）、`localBackupService`（V0.5.1 免服务器默认路径）、`reportOcrService`、`appRepository`。
- 页面：「我的」→「账号与云端备份」`CloudBackupPage`（档案状态、恢复码显示/复制、立即备份、从云端恢复、删除云端备份、彻底删除匿名档案、退出登录，需配置 `REPORT_API_BASE` 才生效）；「数据与隐私」`PrivacyPage`（推荐默认路径：完整备份并分享 / 从备份文件恢复；其它：导出 JSON 纯文本 / 删除本地全部数据）。
- 后端地址：统一用编译期变量 `REPORT_API_BASE`，**一律不写死**（Android 模拟器用 `http://10.0.2.2:8000`，Web 本机 `http://127.0.0.1:8000`，Release 需部署公网后传 `https://域名`）。
- 报告识别流程（V0.4A-D）：上传/拍照 → FastAPI(`/api/report/ocr` 百度OCR) / (`/api/report/recognize` OCR+DeepSeek) → ReportReviewPage 用户确认 → Drift。

---

## 6. 当前验证状态（全绿）

- 后端 `pytest`：backend/tests/test_v05.py，SQLite 临时库自动建表（最新数字见第 12 节）
- Flutter 测试：**必须用 `flutter test -j 1`（或 `scripts/run_flutter_tests.ps1`），不要用裸 `flutter test`**——原因见第 12 节「flutter test 并发假象问题」。
- `flutter build web --release`：**成功**
- `flutter build apk --release`：**成功**（在英文目录 D:\health_archive_build 构建后拷回 release/；2026-08-20 已重新出包并在真机小米 MIUI 14 上验证可正常启动，不再秒退）
  - 修过一个遗留 bug：`android/app/build.gradle.kts` 里 `namespace`/`applicationId` 是 `com.weixu.health`，但 `MainActivity.kt` 一直放在 Flutter 默认模板路径 `kotlin/com/example/health_archive/`、包名也还是 `com.example.health_archive`，导致清单里找的 `com.weixu.health.MainActivity` 编译产物里根本不存在，装到真机上会 `ClassNotFoundException` 秒退。已把文件挪到 `kotlin/com/weixu/health/MainActivity.kt` 并改包名为 `com.weixu.health`（两处项目目录已同步）。以后基于此模板改包名时要记得同步移动这个文件。
  - 在本机用 Claude Code 的工具（Bash/PowerShell 调用）直接跑 Gradle 会必现 `Unable to establish loopback connection`（Java NIO Selector 在被 Claude 启动的子进程里创建内部 loopback pipe 失败，属已知的 Windows 环境问题，非项目配置问题）；构建 apk 需要用户自己手动开一个终端窗口跑 `flutter build apk --release`，不能让 Claude 直接跑。
- Android 模拟器（pixel7_api34，emulator-5554，Android 14）已启动过并能 `flutter run` 装上 App

---

## 7. 环境备注

- **JDK**：D:\jdk21（Temurin 21，免安装）；**Android SDK**：D:\Android\Sdk（platform-tools、build-tools 35/36、platforms android-34/35/36、cmdline-tools/latest、emulator、system-image android-34）。用户环境变量已设 JAVA_HOME、ANDROID_HOME、ANDROID_SDK_ROOT。
- Flutter SDK：D:\development\flutter（stable 3.47）。
- Git：项目是 git 仓库（有 .git）。
- 生产部署（未做，需用户决定）：日本 VPS + PostgreSQL + 域名 HTTPS；报告图片将来可迁对象存储（R2/OSS/COS）。

---

## 8. 安全注意

- 不把 Baidu/DeepSeek Key、auth_token、recovery_code 打印进日志。
- `backend/.env` 已被 `.gitignore` 排除（`.env.example` 只留变量名）。
- 上传文件校验大小 + MIME；服务端不信任客户端文件名。

---

## 9. 已知限制 / TODO

- **必须英文路径构建 APK**（中文路径 AOT 限制）。
- OCR/DeepSeek 真实联调需用户给 Key 并部署后端（本机无 Key，`backend/.env` 疑似已填但未验证）。
- 恢复功能：报告原图目前恢复时按「报告记录」处理，暂不重建原图文件（可在后续补 `/api/backup/files` 下载）。
- 尚未：实时多设备同步、正式 App 图标（现用默认）、公网部署、正式 keystore（上 Play 前）。

---

## 10. 快速跑通（本地）

```bash
# 后端（无 Key 时 OCR 会报网络/未配置；备份/恢复接口无钥可用）
cd D:\健康ios项目mvp-20260819\backend
python -m pytest tests -q                 # 9 passed
uvicorn main:app --port 8000              # 若已装依赖

# Flutter 测试/构建（web 可直接跑；apk 需英文目录）
cd D:\健康ios项目mvp-20260819
flutter test
flutter run -d chrome --dart-define=REPORT_API_BASE=http://127.0.0.1:8000

# Android 模拟器运行
flutter run -d emulator-5554 --dart-define=REPORT_API_BASE=http://10.0.2.2:8000
```

---

## 11. 2026-08-26 真实图片识别端到端联调记录（重要 bug 修复）

背景：用户反馈"无论拍什么照片，识别出来的都是固定假数据"。排查发现装的是很久以前的 release APK，走的是旧代码里"后端未配置就静默回退 Mock 假数据"的逻辑（当前源码已不这样写）；且后端从未公网部署过，本机也从未真正跑通过一次真实识别。本节记录这次为了在本机 + 真机上重新跑通全链路而发现并修复的**代码层面真 bug**（不是环境问题）：

1. **图片上传没声明 Content-Type，被后端拒绝**：`lib/services/report_ocr_service.dart` 和 `lib/services/report_recognition_service.dart` 里 `http.MultipartFile.fromBytes(...)` 都没传 `contentType`，`package:http` 默认给 `application/octet-stream`，后端 `_validate_image()` 只认 `image/jpeg`/`image/png`，导致**无论传什么图都报「仅支持 JPG/JPEG/PNG 图片」**。已加 `contentType: mediaTypeForImageFileName(fileName)`（新增 `pubspec.yaml` 直接依赖 `http_parser`）。
2. **`backend/.env` 里的 Key 从来没被真正读取过**：`backend/requirements.txt` 里有 `python-dotenv`，但全项目没有任何地方调用 `load_dotenv()`。`.env` 文件本身填得好好的，但进程环境变量里其实是空的，`os.getenv("BAIDU_OCR_API_KEY", "")` 永远拿到空字符串，报「缺少百度 OCR API Key」。已在 `backend/main.py` 最顶部（其它 import 之前）加 `from dotenv import load_dotenv; load_dotenv()`。**这是个历史上一直存在、只是没人发现的 bug**——以后新增任何读环境变量的模块，必须确认这行已经在 main.py 里跑过，且要在这些模块被 import 之前执行。
3. **百度 OCR 没开旋转检测，手机拍照角度不对就会读出乱码**：`backend/services/baidu_ocr_service.py` 调用百度「通用文字识别（高精度含位置版）」时没传 `detect_direction` 参数。手机拍的照片如果不是绝对正的（很常见），百度会按原始像素方向识别，整行文字被读成一列无关字符（实测把"糖化血红蛋白"读成"耕化地等曰A"之类的乱码），AI 那边因为看不懂文字，正确地保守返回 `metrics: []`，表现为「未识别到可保存的检查指标」。已加 `"detect_direction": "true"`，让百度自动纠正旋转后再识别。**这个参数的坐标返回值是相对于纠正后的图片**，如果以后要把识别框叠加画在原始照片上（如 OCR 调试页），需要额外处理旋转对齐，目前的核对页流程不依赖这个坐标画框，不受影响。
4. **OCR 常把 "1" 认成小写 "l" 导致本地指标匹配失败**：糖化血红蛋白的英文缩写 `HbA1c`，OCR 经常识别成 `HbAlc`（数字 1 → 字母 l），字典 `lib/models/metric_dictionary.dart` 里原来的别名列表没覆盖这种误读，导致 AI 已经正确提取出数值，但本地却提示「无法匹配到健康指标」。已在 `HBA1C` 条目补充别名 `HbAlc`/`HbAIc`/`糖化血红蛋白Alc`/`糖化血红蛋白AIc`。**这是个模式性风险**：任何缩写里带数字 "1" 的指标以后都可能被 OCR 读错，如果用户反馈类似"识别出数值但匹配不到"，先怀疑这个。
5. **数据库初始化异常被静默吞掉**：`lib/main.dart` 的 `main()` 里 `catch (_) {}` 不打任何日志，导致数据库打开失败时只会在界面上看到一句「数据库未就绪，无法保存」，完全查不出真实原因。已改成 `catch (e, st) { debugPrint('AppDatabase init failed: $e\n$st'); ... }`，方便以后用 `adb logcat -s flutter:V` 直接看到根因（不含健康数据内容，只是异常信息，符合隐私约定）。实测触发过一次真实的 `FormatException`（drift 读 `PersonProfilesTable` 的日期列时按整数时间戳解析，但库里存的是文本日期），原因是这台测试机在同一天里装过好几个不同阶段的测试 APK、共用同一份本地 SQLite 文件，日期字段的存储格式在不同版本之间不兼容——**清空 App 数据（卸载重装或系统设置里清除存储）即可解决**，属于测试环境遗留问题，不是这次改动引入的新 bug。
6. **清理了一处死代码/隐患**：`lib/main.dart` 原来有个全局 `reportRecognitionService`，其构建函数 `_buildRecognitionService()` 在 release 模式下永远返回 `MockReportRecognitionService()`（假数据）。已确认真实拍照/上传流程（`lib/pages/report_recognition_flow.dart`）压根不用这个全局变量，是彻底的死代码，但留着就是个「以后不小心接错线又变回输出假数据」的地雷，已直接删除（连同 `services/report_recognition_service.dart` 的 import）。`MockReportRecognitionService` 类本身还在（`test/compile_check_test.dart` 编译校验会引用），没有删。

**本机测试环境的临时拓扑**（仅供下次继续调试参考，不是生产方案）：
- 后端跑在本机 `127.0.0.1:8001`（8000 端口被一个不相关的「C-Lodop打印服务系统」占用，会返回 200 造成误判，注意排查端口占用不能只看 curl 状态码，要看返回内容）。
- 真机是通过 **Android 无线调试**（`adb pair` / `adb connect`）连上本机的，因为这台设备所在的家庭网络是多路由器/mesh 组网，手机和电脑经常落在不同网段导致 LAN 直连不通。
- 最终用 `adb reverse tcp:8001 tcp:8001` 把手机的 `127.0.0.1:8001` 转发到电脑的 `127.0.0.1:8001`，绕开了局域网路由问题。测试用的 release APK 就是编译成 `REPORT_API_BASE=http://127.0.0.1:8001`，**依赖这条 adb reverse 隧道存活**，仅用于本机联调，不是给真实用户用的配置——真实发布仍需按第 9 节 TODO 做公网后端部署。
- 编译 apk 仍然只能由用户在自己开的终端里手动跑（Claude 直接起 Gradle 进程必现 `Unable to establish loopback connection`，PowerShell/Bash 都一样，是这台机器的已知环境限制，见第 6 节）；`adb install -r` / `adb uninstall` / `adb logcat` 等可以由 Claude 直接操作。

---

## 12. 2026-08-26 全项目安全/数据完整性审计与修复

背景：用户要求"检查代码，重新审计各功能版本是否有明显漏洞"。审计覆盖 Flutter 前端、Drift 迁移、FastAPI 后端三块，发现并修复了以下问题（均已跑对应测试验证）：

1. **`flutter test`（裸命令，默认并发）并发假象问题**：反复对比多次运行的输出（`grep -oE "test/[a-zA-Z0-9_]+\.dart"`），发现裸 `flutter test` 只会真正加载 `test/` 下 9 个文件里的 3 个（`compile_check_test.dart`/`e2e_flow_test.dart`/`widget_test.dart`），其余 6 个文件从未被执行，但命令依然打印 "All tests passed!" 并以 exit 0 结束——**假绿**。用 `flutter test -j 1`（并发数=1）能稳定加载并跑完全部 9 个文件（42 个测试全过）。这是本机 Windows 环境的已知怪癖（很可能与第 6 节记录的 Gradle loopback 连接问题同源），不是测试代码本身的 bug。**以后任何时候需要一个可信的 flutter test 结果，一律用 `scripts/run_flutter_tests.ps1`（内部就是 `flutter test -j 1`），不要相信裸 `flutter test` 的输出。**
2. **恢复流程中途崩溃会永久清空数据**：`lib/services/snapshot_importer.dart` 的 `restore()` 原来是先 `clearAllHealthData()` 再逐张表重新导入，中间任何一步崩溃/被杀都会让 App 停留在"已清空但没写完"的半损坏状态。已给 `HealthRepository` 加了公开的 `transaction<T>()` 方法（包一层 `_db.transaction()`），把清空+重建整个包进同一个数据库事务，未正常返回就不提交。
3. **单份报告删除、备份恢复不清理本地原图**：`report_detail_page.dart` 的 `_deleteReport()` 只删数据库行、不删磁盘上的报告原图；`local_backup_service.dart`/`cloud_backup_service.dart` 的恢复流程也一样，每次"清空重建"都会在 `report_images/` 目录残留一份旧图。已分别在删除成功后调用 `deleteManagedReportImage()`，并在本地/云端恢复成功后清理恢复前遗留的原图（新增 `listReportImagePaths()` 辅助函数）。
4. **本地 zip 备份没有解压体积/条目数上限，存在 zip 炸弹风险**：`local_backup_service.dart` 的 `restoreFromFile()` 现在会先按 zip 文件本身大小（≤300MB）、条目数（≤5000）、单条目声明大小（≤50MB）、总声明大小（≤500MB）做校验，全部通过后才真正触发解压（访问 `.content`），避免损坏/构造过的 zip 撑爆内存。
5. **云端备份的报告原图永远下载不到（本人也不行）**：`backend/app/api_backup.py` 的 `create_backup()` 里构造 `ReportFile(...)` 时漏传了 `file_id=file_id`，导致落库的是 `models.py` 里 `default=_uuid` 生成的随机 UUID，而不是客户端声明、已校验过的 `fileId`——后续任何按 `fileId` 的下载请求都查不到记录。已补上这个字段，并把 `ReportFile.file_id` 列从 `String(32)` 放宽到 `String(64)`（匹配 `_FILE_ID_PATTERN` 的最大长度）。`download_file()` 同时加了 `.order_by(created_at.desc())`（同一 fileId 多次备份会有多条记录，取最新）和 `X-Content-Type-Options: nosniff` 响应头。`backend/tests/test_v05.py` 的 `test_user_isolation` 补了"本人能正确下载回同一张图片"的回归断言。
6. **恢复码防爆破限流只按来源 IP 分桶**：`backend/app/auth.py` 原来的 `recover_identity()` 只对单个来源 IP 限流（15 分钟 5 次），攻击者只要轮换大量来源 IP 就能对不同恢复码做分布式穷举，单 IP 分桶完全防不住。已加一层全局限流（1 分钟内全站最多失败 20 次）叠加在原有的按 IP 限流之上，两层都过了才放行、任何一层失败都记两边的失败计数。
7. **OCR/结构化识别接口零限流，代理付费第三方 API 却对匿名调用方完全开放**：`backend/main.py` 的 `/api/report/ocr`、`/api/report/recognize` 用的是可选鉴权（`optional_user`），无 token 也能调用，且原来没有任何频率限制——任何人都能无限刷这两个接口，直接消耗百度 OCR / DeepSeek 的付费额度。已按 `app/auth.py` 里恢复码限流同样的双层模式（按客户端 IP 分桶 60 秒内最多 10 次 + 全局 60 秒内最多 100 次）加了内存限流器 `_check_ocr_rate_limit()`，超限返回 429。`test_v05.py` 新增 `test_ocr_rate_limit_blocks_excessive_requests` 验证连续请求会触发 429。

**已知遗留、本次未处理**：迁移测试之前只覆盖空库升级，本次已给 `test/migration_test.dart` 补了带真实数据的 5→6 迁移用例（验证已有的 health_metrics/medical_reports/daily_health_records/diseases/medications 行升级后不丢数据、且 `profileId` 正确落到默认档案 1）；限流状态目前都存在进程内存里，多进程部署（`uvicorn --workers N`）下各进程互不可见，生产环境建议换成 Redis 等共享存储实现（`auth.py`/`main.py` 里都留了对应注释）。

---

## 13. 2026-08-26 v1 精简版发布准备：只做 OCR 转发，不存用户数据

背景：和用户讨论了发布到应用商店的路线。结论是 v1 先不上云存数据——数据全部留在手机本地（已有的 Drift + 本地 zip 备份），只留一台「转发专用」小服务器代理百度 OCR / DeepSeek 调用（不落库、不存报告、不建账号），降低 App 商店审核里的医疗/隐私合规风险和运维成本；已建好但未发布的 V0.5 匿名账号 + 云端备份系统整体保留代码，作为 v2（验证到真实付费/多端同步需求后再启用）。本节记录把这个决定落到代码里的三处改动：

1. **OCR/识别接口加了第三层「每日预算」限流**：`backend/main.py` 原来的限流只有两层（按 IP 60 秒 10 次 + 全局 60 秒 100 次），本次加了第三层全局每日总量上限 `_OCR_DAILY_MAX_ATTEMPTS`（环境变量 `OCR_DAILY_BUDGET` 可调，默认 300），专门兜底控制百度 OCR / DeepSeek 的每日账单上限——前两层只防"短时间刷"，防不住"一整天持续但不算高频"的正常流量把调用量堆到预算之外。三层各用独立 key（`__global_minute__`/`__global_daily__`），避免共用同一份时间戳列表时短窗口过滤把长窗口还需要的历史记录提前裁掉。超出后当天直接拒绝新请求（429），避免服务被动欠下一笔无法预估的第三方账单。
2. **`lib/main.dart` 去掉了启动时静默调用 `/api/anonymous/register` 的逻辑**：`identityService.ensureIdentity()` 原来在 `main()` 里 `unawaited()` 触发，v1 后端默认不挂载对应路由，这个调用注定失败（虽然有 try/catch 不影响启动，但纯属浪费一次网络请求）。改成注释保留、不调用；`identityService` 本身没删，v2 重新启用云备份时把这行加回来即可。顺带确认了「隐藏云端备份入口」这个待办其实不需要额外 UI 改动——`profile_page.dart` 从来没有接入过 `CloudBackupPage` 的入口，`about_page.dart` 里显示的是一张写死的禁用状态卡片（`_StatusTile(...ok: false)`，文案「本轮暂不启用，避免影响本机测试」），这条本来就没有暴露给用户。
3. **新增 `ENABLE_CLOUD_BACKUP` 环境变量，把账号/云备份整体做成可选、默认关闭**：`backend/main.py`
   - `_ENABLE_CLOUD_BACKUP = os.getenv("ENABLE_CLOUD_BACKUP", "false")...`，默认 `false`。
   - 默认关闭时：`lifespan()` 不调用 `init_db()`（不创建/触碰任何数据库文件或表）；不 `include_router(auth_router)` / `include_router(backup_router)`（`/api/anonymous/*`、`/api/backup/*` 系列路由完全不存在，访问会 404）；OCR 两个接口的鉴权依赖从 `Depends(optional_user)` 换成了 `Depends(_ocr_user_dependency)`，该变量在关闭时指向新增的 `_no_auth()`（永远返回 `None`，不查库）——这一步是必须的：即使 endpoint body 里从没读过 `user` 参数，`optional_user` 这个依赖本身只要客户端带了 `Authorization: Bearer` 头就会去查 `users` 表，而 `users` 表在云备份关闭时根本没建过，会抛未处理的 `OperationalError`。
   - 打开（`ENABLE_CLOUD_BACKUP=true`）时行为和之前完全一致：建表、挂载两个 router、OCR 接口走真正的可选鉴权校验（无 token 放行，带 token 必须合法，否则 401）。
   - 已用一次性脚本手动验证 v1 默认模式：路由列表只剩 `/api/report/ocr`、`/api/report/recognize`（加 FastAPI 自带的 `/docs` 等），带一个伪造的 Bearer token 请求 OCR 接口不再 401/500，而是正常往下走到百度 OCR 调用那一步（502，因为测试图片是假的/没配真实 Key）——证明鉴权依赖切换生效、且不会因为查无 `users` 表而崩溃。
   - `backend/tests/test_v05.py` 覆盖的是完整的 v2 云备份场景（注册/token/恢复码/备份/越权隔离/OCR 可选鉴权 401 断言等），因此在其导入 `main` 之前的环境变量设置块里加了 `os.environ["ENABLE_CLOUD_BACKUP"] = "true"`，让这份测试继续按"云备份开启"跑通；`pytest tests -q` 12 个用例全过。

**发布路线（供下次接手参考）**：v1 = App 全部数据在本机（Drift + 本地 zip 备份）+ 一台只转发 OCR/DeepSeek 调用、不落库的小服务器（`ENABLE_CLOUD_BACKUP` 保持默认关闭），目标是先发布到应用商店验证是否有人用；v2 = 有真实付费/多端同步需求后，把 `ENABLE_CLOUD_BACKUP=true` 打开即可复用已经写好、测试覆盖的整套匿名账号 + 云端备份系统，无需另开分支重写。

---

## 14. 2026-08-26（同日续）部署 + 域名/备案路线的几次反复，当前状态

**服务器部署已完成并验证成功**：v1 精简后端已部署到腾讯云轻量应用服务器 `lhins-04e0p0te`（上海区域，公网 IP `115.159.50.125`，Ubuntu 24.04，SSH 用户名 `ubuntu` 不是 `root`）。部署方式：`/opt/healtharchive/backend/` 下放代码 + venv，`systemd` 单元 `healtharchive-backend.service`（`ENABLE_CLOUD_BACKUP=false`、`uvicorn main:app --host 0.0.0.0 --port 8001`、`Restart=on-failure`、开机自启），腾讯云控制台防火墙（不是 `ufw`，是控制台层面单独一层）放行了 TCP 8001。已用真机验证：本地打包 `flutter build apk --debug --dart-define=REPORT_API_BASE=http://115.159.50.125:8001` 装到真手机，真实拍照识别报告成功跑通全链路（真百度 OCR + 真 DeepSeek）。

**域名/备案路线中间经历了两次反转，当前定论是「留在大陆 + 走 ICP 备案」**：
1. 最初打算大陆备案（服务器就是上面这台上海机器）。
2. 备案过程中（企业实名认证、域名选型等）因为流程繁琐/审核周期不确定，用户一度决定放弃备案，改买香港区服务器（不需要备案，当天能配好 HTTPS）——但**香港服务器最终没有下单购买**，没有产生浪费。
3. 后来用户又改回大陆备案路线，理由是已经把 `tuoputeng.com` 域名买好（企业身份直接购买，不存在个人/企业不一致的问题），干脆继续走备案，服务器继续用已经部署好的上海那台。
4. 结论：**上海服务器保留使用，不用再部署第二台**；`tuoputeng.com` 是最终域名；正在腾讯云 ICP 备案表单里填写中（服务名称暂定「拓普腾健康档案」，主办单位「深圳拓普腾科技有限公司」，备案局广东省通信管理局）。

**当前卡点/下一步（重要，防止跨会话遗忘）**：
- ICP 备案表单尚未提交完，需要继续陪用户逐字段填完并提交。
- 备案通常需要审核 1～20 个工作日（管局审核，无法加速，只能等）。
- **备案通过之前，`tuoputeng.com` 不能解析到大陆服务器 IP**（腾讯云会拦截未备案域名指向大陆 IP），所以 DNS 解析、Nginx 反代、Let's Encrypt HTTPS 这几步必须等备案审核通过拿到备案号之后才能做。
- 备案通过后要做：① DNS A 记录指向 `115.159.50.125` ② 服务器装 Nginx + certbot 配 HTTPS（建议用子域名如 `api.tuoputeng.com` 专门跑接口，和以后可能的官网分开）③ 重新编译 APK（`--dart-define=REPORT_API_BASE=https://api.tuoputeng.com` 或类似）④ 装真机再验证一次。
- 另外还有一个**独立于网站 ICP 备案的「APP 备案」**（工信部要求，App 调用域名后端服务需要单独报备），之前定的是等接近真正上架时再处理，需要在那时候重新确认是否必须做、以及和网站备案的先后顺序。
- **iOS 上架**：用户确认有 Mac，可以用 Xcode 编译签名。除了 Mac，还需要：Apple Developer Program（约 $99/年，若用公司主体需要邓白氏编码 D-U-N-S Number，建议提前申请因为审核可能要几天到几周）、App Store Connect 建 App 记录、隐私政策链接（健康数据类 App 审核会重点看，但本项目数据全部存本地这点是加分项）、TestFlight 内测。iOS 和 Android 共用同一套后端和域名，不需要重复部署，只是编译参数换一下即可。这条线目前只是知识准备，还没有开始实际操作。

**2026-08-26 22:00 左右更新：ICP 备案表单已提交**，进度可查询（腾讯云控制台备案页）：
- 备案订单号：`30178775210119748`，订单类型「首次备案」，提交时间 2026-08-26 21:48:21
- 当前进度：第 2 步「腾讯云审核」（审核中）。完整 5 步流程：① 提交初审（已完成）② 腾讯云审核（当前，1-2个工作日内会电话核实）③ 待提交管局（提交后 24 小时内）④ 工信部短信核验（24小时内）⑤ 管局审核（1-20个工作日，最终这步过了才算备案成功）
- **腾讯云审核电话会打给徐威**（备案负责人/联系人），手机尾号 5266 和 7131 两个号码都会打，**第一次没接通会在 1 小时内再打一次，两次都没接通会导致驳回**——一定要保持手机畅通，不要开骚扰拦截，审核电话不支持回拨。
- 电话通常会核实这些内容（据经验，不同批次问法略有出入，但方向一致）：① 确认是不是负责人/联系人本人接听 ② 核对公司名称「深圳拓普腾科技有限公司」、统一社会信用代码是否正确 ③ 确认网站/域名 tuoputeng.com 的用途和备案表单里填的服务内容是否一致（回答要贴近「健康档案类 App 的配套接口服务」这个方向，不要跟表单对不上）④ 核对负责人身份证信息（姓名、证件号、住址等，是否与提交资料一致）⑤ 提醒/确认知晓不得利用网站发布违法信息等备案责任条款。回答思路：如实、简短、和表单信息保持一致即可，不需要背稿子。
- 公安联网备案：授权已完成，需要等通信管理局审核通过、拿到「公安联网备案数据码」后，再去公安联网备案平台单独完成一次（这是备案通过之后的收尾步骤，不是现在要做的）。
- **下次接手先做什么**：打开腾讯云控制台备案页查订单号 `30178775210119748` 当前处于第几步；如果还在等电话/等管局审核，就是纯等待，不需要额外操作；如果管局审核已经通过（拿到备案号），就直接进入本节前面写的「备案通过后要做」那四步（DNS 解析 → Nginx+HTTPS → 重新编译 APK → 真机验证）。
