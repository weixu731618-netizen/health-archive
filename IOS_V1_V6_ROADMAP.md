# Health Archive iOS V1–V6 开发交接与路线图

> 更新日期：2026-08-28  
> 用途：下次继续开发时快速恢复上下文。  
> 原则：优先跑通关键路径，不重复做低价值的细碎测试。

## 1. 当前结论

- V1「iPhone 真机稳定运行」已完成。
- V2「清除假数据并完善本地功能」的核心代码已完成，已通过静态检查和 31 项 Flutter 测试，新 Release 包已覆盖安装到真机。
- V2 只剩一次快速人工验收：确认首页、记录页和身体页不再显示演示数值/假报告。
- V3 真实 OCR 走 HTTPS，卡在 ICP 备案，属于「上架/合规」线，与下面的产品功能线并行。

## 1.5 产品功能路线（与备案并行推进，2026-08-29 定）

按「先把档案做完整，再让档案有人管、用得上」拆成两个大版本，各 4 个小版本，逐个做完验收再开下一个：

**版本 A：把「档案」做完整（报告侧）**

- **A1 影像/病理报告存档** — ✅ 已完成（2026-08-29）。X光/CT/MRI/B超/心电图/病理这类「图片+文字结论、无数字指标」的报告，走 `ImagingReportPage`：拍照/选图 → OCR 全文（可编辑）→ 手填医院/日期/类型 → 存为一条 `medical_reports` 记录（`recognitionStatus=confirmed`，不关联指标）。收尾内容见第 12 节。
- **A2 报告原件下载/分享** — ✅ 已完成（2026-08-29）。记录页每张报告卡片 + 报告详情页（正文按钮 + AppBar 图标）都能「分享 / 导出原件」，走系统分享面板（iOS 上即「存储到文件 / 存储图像 / AirDrop / 微信」等）。详情见第 13 节。
- **A3 PDF 报告导入** — ✅ 代码完成（2026-08-29，待真机验证）。「上传化验单」和「添加影像/病理报告」的文件选择器都接受 PDF；PDF 首页用 `pdfx` 渲染成 PNG 走现有 OCR / 识别 / 核对流程，**原始 PDF 落盘**作为报告原件（导出 / 备份给回的是 PDF）。详见第 14 节。多页 = A4。
- **A4 体检报告批量识别** — 一份多页 PDF / 多图 → 一次几十项指标 → 批量核对入库。建在 A3 之上。

**版本 B：让档案「有人管、用得上」**

- **B1 多人家庭档案放出** — ✅ 代码完成（2026-08-29，待真机验证）。schema v7（`person_profiles.height_cm` + 把旧 `user_profile` 并入档案 1）；仓库所有读写按「当前档案」`activeProfileId` 过滤；首页 AppBar 档案切换器 + 「我的 → 家庭成员」管理页（增删改、切换、级联删除）；整档备份覆盖全部成员。详见第 15 节。
- **B2 备忘 / 提醒中心** — ✅ 代码完成（2026-08-29，待 CocoaPods/APNs 配置后真机验证）。复查提醒（指标历史页设）+ 服药提醒（用药编辑页开关+时间）→ `reminders` + `notifications` 表 → 本地系统通知（`flutter_local_notifications`，离线可用）+ 应用内「提醒」页 + 首页「待办提醒」摘要卡。远程 APNs 推送骨架（Flutter token 获取 + FastAPI device-token API + APNs 发送 service，mock 兜底，`PUSH_ENABLED` 开关）也一并写好，Apple 侧配置见 `IOS_PUSH_SETUP.md`。详见第 16 节。
- **B3 记录页搜索 / 筛选 / 标签** — ✅ 代码完成（2026-08-29，待真机验证）。schema v9（`medical_reports.tags` 逗号分隔）；记录页顶部搜索框（医院/类型/结论文字/指标名/标签/记录标题）+ 「筛选」bottom sheet（时间范围预设+自定义、只看异常、标签多选、医院多选）+ 生效条件 chip 展示；报告卡片显示标签、长按编辑标签（常用「体检/术前/复查/住院/门诊」+ 自定义）。详见第 17 节。
- **B4 首页 + 我的 重新设计** — ✅ 代码完成（2026-08-29，待真机验证）。核心是「给医生看的摘要」页（疾病史 + 当前用药 + 近期异常指标含趋势箭头 + 近期报告 → 导出为长图 / 分享文字，纯 Dart 截图无原生依赖）；「我的」分组（档案 / 健康记录 / 就医 / 数据）+ 查看家庭成员时资料卡加提示；首页 AppBar 加搜索入口。首页 body 未大改（B1/B2 已叠加、结构尚可）。详见第 18 节。

（HealthKit 接入、应用锁/备份加密密码 UI 暂不排期。）

## 2. V1 真机验证记录

真机信息：

- 设备名：威的iPhone
- 型号：iPhone 16（iPhone17,3）
- iOS 目标设备 ID：`00008140-00010D6A11E3001C`
- Bundle ID：`com.weixu.healthArchive`
- iOS 最低版本：15.0
- Xcode：26.6
- 签名方式：Automatic
- Development Team：`ZZ8JW5PS4S`
- 当前使用免费/Personal Team 开发签名，真机 App 通常需要约每 7 天重新签名安装。

已验证通过：

- Mac 和 iPhone 信任。
- iPhone 开发者模式。
- Apple Development 证书与 provisioning profile。
- Release 构建、签名、覆盖安装、脱离 Mac 启动。
- Drift 本地数据库写入、编辑、删除和冷启动持久化。
- 相机拍摄和报告图片预览。
- 相册选择。
- 完整 ZIP 备份、保存到 iOS「文件」、从备份覆盖恢复。

测试数据清理：

- App 内用于测试的 `79 kg` / `79.5 kg` 记录已删除并经冷启动确认不再出现。
- iOS「文件」中之前保存的测试备份仍可能包含 `79 kg`，正式使用前应手动删除该备份文件。

## 3. V2 假数据清理

已完成的生产 UI 改动：

- 记录页只显示用户实际录入或导入的数据。
- 删除「历史假数据示例」、「深圳某医院」、「生化检查」等生产入口。
- 首页和身体页在空数据库时只显示真实空状态，不再显示 `LDL-C 3.6`、`HbA1c 6.8%`、`ALT 32`、肌酐或肾功能趋势示例。
- 无 `reportId` 进入报告详情时显示空状态，不构造假报告。
- Mock 识别类和测试数据仍保留在测试层，不进入生产 UI。

改动文件：

- `lib/pages/records_page.dart`
- `lib/models/body_area_health.dart`
- `lib/pages/body_page.dart`
- `lib/pages/home_page.dart`
- `lib/pages/report_detail_page.dart`
- `test/widget_test.dart`
- `test/e2e_flow_test.dart`

已验证：

```bash
/Users/wei/Documents/Codex/tools/flutter/bin/flutter analyze
/Users/wei/Documents/Codex/tools/flutter/bin/flutter test -j 1
```

结果：

- `flutter analyze`：No issues found
- Flutter 测试：31 passed

## 4. 本机 Flutter 和 iOS 构建命令

Flutter SDK 不在当前 shell PATH 中，实际路径为：

```text
/Users/wei/Documents/Codex/tools/flutter/bin/flutter
```

静态检查：

```bash
/Users/wei/Documents/Codex/tools/flutter/bin/flutter analyze
```

完整串行测试：

```bash
/Users/wei/Documents/Codex/tools/flutter/bin/flutter test -j 1
```

真机 Release 构建：

```bash
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination 'platform=iOS,id=00008140-00010D6A11E3001C' \
  -allowProvisioningUpdates \
  -derivedDataPath /private/tmp/healtharchive-release-derived \
  build
```

安装：

```bash
xcrun devicectl device install app \
  --device 00008140-00010D6A11E3001C \
  /private/tmp/healtharchive-release-derived/Build/Products/Release-iphoneos/Runner.app
```

重启 App：

```bash
xcrun devicectl device process launch \
  --device 00008140-00010D6A11E3001C \
  --terminate-existing \
  com.weixu.healthArchive
```

注意：用 `devicectl` 独立启动 Flutter Debug 包会显示 iOS 14+ 调试限制提示；脱离 Flutter tooling 验收时应安装 Release 包。

## 5. V3：接入真实 OCR

目标链路：

```text
拍照/相册 → HTTPS 后端 → 百度 OCR → DeepSeek 结构化
→ 用户核对 → 保存报告与指标 → 查看原图
```

待办：

1. 等待 `tuoputeng.com` ICP 备案通过。
2. 配置 `api.tuoputeng.com` DNS A 记录指向上海服务器。
3. 部署 Nginx + HTTPS 证书。
4. 确认 FastAPI 后端仍使用 V1 精简模式：`ENABLE_CLOUD_BACKUP=false`。
5. 编译 iOS 时传入：

   ```text
   REPORT_API_BASE=https://api.tuoputeng.com
   ```

6. 用真实化验单验证完整链路。
7. 验证失败情形：模糊图、空结果、超时、服务器不可用、每日预算耗尽。

完成标准：

- 一张真实化验单能识别出主要指标。
- 用户核对后能保存到 Drift。
- 记录页、身体页和报告详情能查看真实数据和原图。
- 后端不长期保存用户报告和识别文本。

## 6. V4：隐私和数据安全

上架前必做：

- 公开可访问的隐私政策 URL。
- 明确披露报告图片会发送给识别服务器及第三方 OCR/模型服务。
- 强制 HTTPS。
- 服务端不持久化报告图片和识别原文。
- 日志不记录健康内容、token、恢复码或 API Key。
- 备份导出前明确提示其包含敏感健康信息。
- 清理测试域名、调试入口和测试文案。
- App Store Privacy 回答必须与实际网络数据流一致。

可后续增强：

- 本地数据库文件保护或字段加密。
- ZIP 备份密码加密。
- App 进入后台时遮挡健康页面。
- Face ID / 应用锁。
- API Key 轮换、服务器访问审计和共享限流存储。

## 7. V5：TestFlight 内测

前置：

- 付费 Apple Developer Program。
- 若以公司主体发布，完成公司团队、D-U-N-S 等所需资料。
- App Store Connect 创建 App 记录。
- 确定正式 App 名称、Bundle ID、版本号和图标。

待办：

1. 生成正式 Archive。
2. 上传 App Store Connect。
3. 填写 TestFlight 描述、联系方式和测试重点。
4. 先进行内部测试，再视需要提交外部 Beta Review。
5. 收集崩溃、截图和反馈，修复后上传新构建。

完成标准：

- 测试者不连 Mac，通过 TestFlight 安装并跑完核心链路。

## 8. V6：App Store 上架与大陆合规

App Store 侧：

- App 名称、副标题、关键词和描述。
- iPhone 商店截图。
- 支持 URL 和隐私政策 URL。
- 年龄分级。
- App Privacy 数据披露。
- 加密出口合规回答。
- 审核说明，强调产品是「个人健康档案管理工具」，不提供医疗诊断。
- 提交 App Review 并处理审核反馈。

中国大陆侧：

- 完成当前 `tuoputeng.com` 网站 ICP 备案。
- 正式域名、DNS 和 HTTPS。
- 按上架地区、实际网络服务和届时现行要求完成 APP 备案。
- 在通信管理局审核通过后完成公安联网备案等收尾事项。
- 上架前再核对健康类 App 是否触发额外资质或内容限制。

完成标准：

- App Store 审核通过并可公开下载。
- 生产 OCR 域名稳定可用。
- 隐私政策、商店披露、实际代码行为和备案信息一致。

## 9. 最快关键路径

```text
V2 快速验收
→ 备案等待期间并行准备 V4/V5 材料
→ 备案通过后立即完成 V3 HTTPS/OCR
→ V4 上架必要安全收口
→ V5 TestFlight
→ V6 App Store 与备案收尾
```

备案审核期间可并行进行：

- 正式 App 图标。
- 隐私政策。
- App Store 文案与截图脚本。
- Apple Developer 公司主体准备。
- 本地数据与备份安全改造。

## 10. Git 状态注意

本轮有未提交改动，不要误以为工作区干净：

- Xcode 写入 Development Team，并将 `ios/Runner.xcodeproj/project.pbxproj` 的 object version 从 54 升级为 60。
- V2 生产 UI 假数据清理。
- V2 相应的 widget/e2e 测试更新。

下次开始时先执行：

```bash
git status --short
git diff --stat
```

未经用户明确要求，不要擅自提交、推送或丢弃这些改动。

## 11. 下次继续开发的第一步

1. 读取本文档和 `HANDOVER.md`。
2. 检查 Git 工作区。
3. 向用户确认 V2 真机快速视觉验收是否通过。
4. 查询 ICP 备案当前进度。
5. 若备案未通过：并行推进隐私政策、正式图标、备份安全或 TestFlight 材料。
6. 若备案已通过：直接进入 DNS → Nginx/HTTPS → `REPORT_API_BASE` → 真实 OCR 端到端验证。
7. 产品功能线：A1、A2 已完成；**A3、B1、B2、B3、B4 代码完成，待真机验证**（第 12–18 节 + `IOS_PUSH_SETUP.md`）。A4（体检报告批量识别）暂缓，需先定后端方案。版本 A / B 的其余项都做完了——下一步是把这批改动在真机上验一轮（先解决第 8 条的 CocoaPods），再考虑 A4 或转向 V3/V4 上架线。
8. 本机 iOS 构建阻塞：`flutter_local_notifications` / `flutter_timezone` 不支持 SPM，需要 CocoaPods，而本机系统 Ruby 2.6 装不了新版 CocoaPods。真机验证 B2 前要先装 CocoaPods（`sudo gem install cocoapods` 需装 Ruby 3+，或 `brew install cocoapods`）。A1/A3/B1 用的 pdfx 支持 SPM，不受影响。

## 12. A1 影像/病理报告存档 —— 完成记录（2026-08-29）

**改动文件（均在工作区，未提交）：**

- `lib/pages/imaging_report_page.dart`（新增）：影像/病理报告录入页。拍照/相册 → `reportOcrService.ocrImage` 取全文填入可编辑文本框 → 选类型（X光/CT/MRI/B超/心电图/病理/其他）+ 医院 + 日期 → `repo.insertReport(recognitionStatus:'confirmed')`，不写任何 `health_metrics`。
- `lib/pages/add_page.dart`：新增「添加影像/病理报告」入口卡片；原「拍摄检查报告 / 上传报告」改名为「拍摄化验单 / 上传化验单」并改副文案，和影像入口区分清楚（三个报告入口目前并存，B4 再统一重构）。
- `lib/pages/records_page.dart`：`_ReportTile` 适配无指标报告——`metricCount>0` 显示「类型 · N 项指标」，`metricCount==0` 显示「类型 · 图文报告」并在下面补一行 `rawText` 结论摘要（`\s+` 折叠、最多两行、省略号）。
- `lib/pages/report_detail_page.dart`：无关联指标时收起「影响部位」「检查指标」两个空区块；`rawText` 非空则由已有的「报告结论」区块展示，`rawText` 也为空时显示一句「本报告为图文报告，未录入文字内容」。化验单（有指标）版面完全不变。
- `lib/data/health_repository.dart` + `lib/services/snapshot_importer.dart`：**修了一个备份丢数据的问题**——`exportHealthData()` 的 `reports` 项原来不含 `rawText`，影像报告的结论文字一备份就丢；现在 export 带上 `rawText`，`SnapshotImporter._importReports` 恢复时写回。`local_backup_service.exportBundle()` 里对 reports 只 `remove('sourceImagePath')`，不影响 `rawText`。
- 测试：`test/e2e_flow_test.dart` +3 用例（详情页收起空区块、纯图文报告说明、记录页图文报告卡片）；`test/local_backup_service_test.dart` 现有往返用例加 `rawText` 断言 + 新增「纯影像报告往返」用例；`test/compile_check_test.dart` 引用新页面（WIP 已加）；`test/widget_test.dart` 跟随入口改名。

**验证：** `flutter analyze` 无问题；`flutter test -j 1` 38 passed（用 `/Users/wei/Documents/Codex/tools/flutter/bin/flutter`）。

**未做（属于后续小版本，不在 A1）：** 原件下载/分享（A2）、PDF（A3）、「添加」页三入口合并重构（B4）。真机人工验收：从「添加 → 添加影像/病理报告」拍一张 CT/B超报告，确认能识别文字、存档后在「记录」里显示为「类型 · 图文报告」、点进详情能看到结论和原图。

## 13. A2 报告原件下载 / 分享 —— 完成记录（2026-08-29）

**思路：** iOS 的系统分享面板本身就包含「存储到‘文件’」「存储图像」「AirDrop」「微信」等，所以「下载」= 调 `share_plus` 唤起分享面板，用户自己选存到哪里；不单独做「保存到相册」按钮。

**改动文件（均在工作区，未提交）：**

- `lib/utils/report_export.dart`（新增）：
  - `reportShareCaption(report)` → 「医院 · 类型 · 日期」一行说明（缺项跳过）。
  - `buildReportSharePayload(report, {fileExists})` → 纯逻辑，决定导出什么：**有原图**就导原图文件 + 只带说明行（不塞 OCR 全文，免得化验单几百行原始文字污染分享内容）；**没有原图但有 `rawText`**（旧数据 / Web / 只填了结论的影像报告）退化为分享文字；两者都没有则 `hasAnything=false`。`fileExists` 参数仅供测试注入。
  - `shareReport(report)` → 组装后调 `SharePlus.instance.share(ShareParams(files/text/subject))`；返回 `false` 表示没有可导出的内容。跟随 `local_backup_service.dart` 的既有写法直接 `import 'dart:io'`。
- `lib/pages/report_detail_page.dart`：AppBar 右上角加 `Icons.ios_share` 图标动作 + 正文「原始报告」下方加一个「分享 / 导出原件」`OutlinedButton.icon`（放在「删除报告」上面）。`_shareReport()` 里 `shareReport` 返回 false → SnackBar「该报告没有可导出的原图或文字」，异常 → 「分享失败，请重试」。
- `lib/pages/records_page.dart`：`_ReportTile` 头部行（日期 + 来源 chip 之后）加一个紧凑的 `Icons.ios_share` `IconButton`，`onShare` 回调冒泡到 `_RecordsPageState._shareReport(report)`，同样的 SnackBar 兜底。不用长按（35–70 岁用户发现不了）。

**测试：** `test/report_export_test.dart`（新增，5 个用例，覆盖说明行拼接 + 4 种 payload 分支）；`test/e2e_flow_test.dart` 补断言：详情页有「分享 / 导出原件」按钮和 `ios_share` 图标、记录页报告卡片有 `ios_share` 图标；`test/compile_check_test.dart` 引用新符号。

**验证：** `flutter analyze` 无问题；`flutter test -j 1` 43 passed。

**未做 / 边界：** PDF 的「导出」目前只是把已存的原图文件交出去——A3 做完 PDF 导入后，导出逻辑天然复用（`sourceImagePath` 换成 PDF 路径即可，`share_plus` 不挑文件类型）。真机人工验收：记录页点报告卡片上的分享图标、或进详情点「分享 / 导出原件」，确认弹出系统分享面板且能存到「文件」/发到微信；对没有原图的报告确认走文字分享。

## 14. A3 PDF 报告导入 —— 完成记录（2026-08-29，代码完成，待真机验证）

**范围：** 只处理 **PDF 首页**——单页化验单 / 单页影像报告是绝大多数情况。多页体检报告「一份 PDF → 几十项指标批量入库」是 A4。

**依赖：** 新增 `pdfx: ^2.9.1`（解析到 2.11.0；移动端走 pdfium，无需额外 Android 配置；iOS 首次 `flutter build ios` 会自动生成 Podfile 并 pod install）。

**改动文件（均在工作区，未提交）：**

- `lib/utils/pdf_support.dart`（新增）：`isPdfFileName()` + `renderPdfFirstPageToPng(bytes)`——用 `PdfDocument.openData` 打开，首页按目标宽度 1600px（1–4 倍缩放）渲染成 PNG。失败（加密 / 损坏 / 平台不支持）抛异常。
- `lib/utils/image_storage.dart`：`PickedReportImage` 加 `isPdf` 字段；`pickLabReportImage()` 的 `allowedExtensions` 加 `pdf`；选中 PDF 时——`bytes`/`fileName` 变成「首页 PNG」+ `xxx_p1.png`（下游按扩展名判上传 Content-Type，必须是 .png），`path` 指向**落盘的原始 PDF**（`.pdf`），`isPdf=true`。渲染失败抛 `StateError('无法读取该 PDF（可能已加密或损坏），请改用报告截图')`。
- `lib/pages/report_detail_page.dart`：`_buildOriginalImage()` 判断 `sourceImagePath` 以 `.pdf` 结尾 → 显示「PDF 原件」卡片（图标 + 「用『分享 / 导出原件』发送或保存」+ 分享按钮），不再用 `Image.file` 渲染 PDF 路径。
- `lib/pages/report_import_page.dart` / `imaging_report_page.dart` / `add_page.dart`：文案与按钮改为「图片 / PDF」；`report_import_page` 的选择失败提示改成透出 `StateError.message`（这样 PDF 渲染失败能显示具体原因）。

**链路复用（未改动）：**

- 化验单 PDF：`report_import_page → startReportRecognitionFlow(picked)` → 后端 `/api/report/recognize` 收到首页 PNG（`.png` 文件名 → `image/png`）→ `ReportReviewPage`。`RemoteReportRecognitionService(imagePath: picked.path)` 拿到的是 `.pdf` 路径，`ReportReviewPage._save()` 存 `_report.sourceImagePath` → **报告原件是 PDF**。
- 影像 PDF：`imaging_report_page` → `reportOcrService.ocrImage(首页 PNG)` 填结论文字，`_save()` 用 `_image!.path`（`.pdf`）作 `sourceImagePath`。
- 导出 / 分享（A2）：`report_export.buildReportSharePayload` 只看文件是否存在，`.pdf` 原样进 `filePaths`，`share_plus` 不挑类型 → 导出的就是原始 PDF。
- 本地备份（`local_backup_service`）：按 `report_{id}${ext}` 打包、`report_(\d+)` + `p.extension` 还原，`.pdf` 已能往返，无需改。

**测试：** `test/pdf_support_test.dart`（`isPdfFileName` 纯逻辑）；`compile_check_test.dart` 引用新符号。`renderPdfFirstPageToPng` 依赖 pdfium 平台绑定，headless `flutter test` 跑不了，未加渲染测试。`flutter analyze` 无问题；`flutter test -j 1` 46 passed。

**待真机验证 / 已知边界：**

- iOS 首次构建要让 pdfx 的 pod 装上（用户 Mac 需先 `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`，这也是 Claude 端 iOS Simulator 集成用不了的原因）。
- `flutter build web` 可能因 pdfx web 需要额外的 pdf.js 资源而受影响——web 不是发布目标，未处理。
- 多页 PDF 只取首页；多页体检报告留给 A4。
- 加密 PDF 不支持（`pdfx` 需要密码），会提示改用截图。
- 真机人工验收：把一份 PDF 化验单 / PDF 影像报告分别从「上传化验单」「添加影像/病理报告」导入，确认首页能渲染出来、识别/结论正常、存档后详情页显示「PDF 原件」卡片、「分享 / 导出原件」给回的是 PDF 文件。

## 15. B1 多人家庭档案 —— 完成记录（2026-08-29，代码完成，待真机验证）

**Schema v7（`lib/data/app_database.dart`，已 `dart run build_runner build` 重新生成 `.g.dart`）：**

- `person_profiles` 加 `height_cm`。迁移：`from==6` 才 `addColumn`（`from<6` 时 `createTable` 已按当前定义带上该列）；`from<7` 把单行 `user_profile`（昵称/性别/生日/身高）用 `COALESCE` 合并进档案 1，之后 `user_profile` 表保留但不再读写。

**仓库层（`lib/data/health_repository.dart`）：**

- 新增 `int activeProfileId` + `setActiveProfileId(id)`（校验存在，否则回落 1）。所有 `getAllMetrics/getMetricsByBodySystem/getMetricHistory/getAllDailyRecords/getAllReports/getMetricsByReport/getAllDiseases/getAllMedications` 的 `profileId` 过滤、以及 5 个 `insertXxx` 的 `profileId` 默认值，从写死的 `defaultProfileId` 改成 `activeProfileId`（签名 `int profileId = defaultProfileId` → `int? profileId`，内部 `?? _activeProfileId`）。
- 人员 CRUD：`insertPersonProfile` / `updatePersonProfileFields` / `deletePersonProfileCascade`（禁止删 id=1 / 删到不剩；级联清 5 张表 + 回落 active 到 1）/ `restorePersonProfile`（按原 id 覆盖重建，供备份恢复）/ `listReportImagePathsForProfile`（删成员前清磁盘图）/ `countPersonProfiles`。
- `getProfile()` / `upsertProfile()` 保留原名作兼容壳，实际作用在**当前档案**上，返回新的轻量 `ProfileView`（字段名 `nickname/gender/birthDate/heightCm` 沿用旧的，页面只改类型注解）。
- `exportHealthData()` 改为**直接读整表**（不走按档案过滤的 getter），覆盖全部人员；`personProfiles` 列表加 `heightCm`。`clearAllHealthData()` 结束时 `_activeProfileId = 1`。

**恢复（`lib/services/snapshot_importer.dart`）：** 新增 `_importPersonProfiles`（按原 id `restorePersonProfile` 重建全部人员），排在 `_importProfile` 前；`_importProfile` 降级为「旧备份只有单个 profile」时写回本人。各条记录的 `profileId` 透传逻辑本来就有。

**App 层（`lib/main.dart`）：** 全局 `ValueNotifier<int> activeProfileNotifier` + `switchActiveProfile(id)`（写仓库 + `shared_preferences` 持久化 + 通知）；启动时读回上次选中的档案；`MainShell` 用 `ValueListenableBuilder` + `KeyedSubtree(key: tab+profile)` 包住当前 Tab 页，切换档案时整页重建触发 `initState` 按新档案重载。

**UI：**

- `lib/widgets/profile_switcher.dart`：首页 AppBar 的档案切换器（`PopupMenuButton`，列人员 + 「管理家庭成员」）。**只有 1 个人时不显示**。
- `lib/pages/family_members_page.dart`：人员列表（点选即切换）、底部「添加家庭成员」、每行 `⋮` 菜单「编辑资料 / 删除该成员」。表单 `bottom sheet`（称呼 / 关系 / 性别 / 生日；「本人」不显示关系选择）。删除有二次确认，会先收集该成员报告原图路径再级联删除、然后清磁盘文件。
- `lib/pages/profile_page.dart`：「个人资料」下方加「家庭成员」入口。「我的」页的资料卡、疾病史、用药数现在都跟随当前档案。
- `lib/pages/home_page.dart`：`_profile` / `_OverviewCard.profile` 类型 `UserProfileData?` → `ProfileView?`。

**测试：** `test/multi_profile_test.dart`（6 例：新增/切换/隔离、回落、级联删除、禁删本人、getProfile 作用域、export 覆盖全员）；`test/migration_test.dart` 加 5→7 的 `user_profile` 并入断言；`test/local_backup_service_test.dart` 加「本人 + 家庭成员及各自数据完整往返」；`compile_check_test.dart` 引用新符号；`sample_data_seeder` 加了一个配偶「徐女士」+ 少量数据（切换器演示用）。`flutter analyze` 无问题；`flutter test -j 1` 53 passed。

**模拟器验证（2026-08-29，iPhone 17e / iOS 26.5）：**

- `sudo xcode-select` 修好后，`flutter run` 首次构建自动 `pod install`（pdfx / A3），42s 编译通过，App 正常启动。
- 修了一个 B1 引入的崩溃：`_MemberFormSheet`（添加/编辑成员的 bottom sheet）用 `Column(mainAxisSize:min)` 直接放在 `isScrollControlled` 的 sheet 里，键盘弹起时 `RenderFlex overflowed` → 级联 `referenceBox.attached` / `_dependents.isEmpty` 断言 → 红屏。已用 `SingleChildScrollView` 包住内容修复。
- 已验证通过：我的 → 家庭成员 → 添加成员（Mama Wang / 母亲 / 女）→ 列表出现该成员 → 点选切换 → 我的页资料卡变 Mama Wang、疾病史/用药清空（数据隔离）→ 首页 AppBar 出现档案切换器「👥 Mama Wang ▾」、概览与主题全部「暂无资料」→ 切换器菜单（徐先生 / ✓Mama Wang / 管理家庭成员）→ 切回徐先生，8 个需关注部位、各主题份数全部恢复。切换零异常。
- A1「添加影像/病理报告」页渲染正常（拍照 / 选图片 / PDF、报告类型、识别文字框、保存）。选文件 + OCR 需真机相册 + 后端，未跑端到端。

**待真机验证 / 已知边界：**

- 迁移 v6→v7 与 5→7 有单测覆盖，仍建议真机上装旧版再覆盖安装确认本人资料没丢。
- 「我的」页标题仍是「我的」，查看家庭成员时略有歧义——留到 B4 首页/我的重构一起处理。
- 删成员时磁盘报告原图已按该成员的报告路径清理；若清理中途失败会留孤儿文件（不影响数据），「删除全部数据」仍会兜底。
- `user_profile` 表保留未删（drift 删表麻烦），迁移后不再读写。
- 真机人工验收：我的 → 家庭成员 → 添加一个成员 → 首页出现切换器 → 切过去后首页/身体/记录/我的都变成该成员的数据、加一条记录只进该成员、切回本人数据不受影响 → 完整备份并分享 → 删除全部数据 → 从备份恢复，确认两个人的数据都回来。

## 16. B2 备忘 / 提醒中心 + iOS 推送 —— 完成记录（2026-08-29，代码完成，待真机验证）

按用户「代码优先、配置后补、mock 兜底」的 8 点要求实现。**没有 Apple Developer / APNs 凭证也能开发、运行、测试。**

### 数据库（schema v8）

- `reminders` 表：`kind`（recheck/medication）、`title`、`detail`、`relatedMetricId`、`relatedMedicationId`、`dueDate`（复查一次性）、`dailyTimes`（服药，逗号分隔 "08:00,20:00"）、`enabled`、`completedAt`。按 `profileId` 隔离。
- `notifications` 表（`@DataClassName('NotificationRecord')` 避开 Flutter 的 Notification）：应用内通知中心 + 系统推送**共用这一份**。`category`、`title`/`body`、`scheduledFor`、`deliveredAt`、`readAt`、`channel`（local/push/in_app）。
- 迁移 `from<8`：createTable(reminders) + createTable(notifications)。`.g.dart` 已 build_runner 重新生成。

### 仓库层（`health_repository.dart`）

- 提醒 CRUD（按 `activeProfileId` 过滤）：`getActiveReminders` / `getAllSchedulableReminders`（全档案，系统通知用）/ `insertReminder` / `setReminderEnabled` / `markReminderCompleted` / `deleteReminder` / `getRecheckReminderForMetric` / `getMedicationReminder` / `setMedicationReminder`（幂等 upsert，关闭即删）/ `deleteMedicationReminder` / `restoreReminder`（备份恢复）。
- 通知：`getNotifications` / `unreadNotificationCount` / `insertNotification` / `markNotificationRead` / `markAllNotificationsRead` / `syncNotificationsFromReminders`（幂等：复查落 1 行、服药落「今天」各时间点 1 行，过时未送达的补 `deliveredAt`）。
- `exportHealthData` 加 `reminders`；`snapshot_importer._importReminders`；`clearAllHealthData` + `deletePersonProfileCascade` 都清 reminders/（成员的）reminders。

### Flutter 服务

- `lib/utils/reminder_schedule.dart`（纯逻辑，已测）：`parseDailyTimes` / `defaultMedicationTimes` / `timesPerDayCount` / `notificationIdsForReminder`（复查 id=`rid*10`，服药 `rid*10+序号`）/ `dueDescription`。
- `lib/services/notification_service.dart`：`flutter_local_notifications` + `timezone` + `flutter_timezone`。`init` / `requestPermission` / `syncAll(reminders)`（先 cancelAll 再逐条 `zonedSchedule`——复查一次性、服药 `matchDateTimeComponents: time` 每日重复）。全程 try/catch，失败只 debugPrint。
- `lib/services/push_service.dart`：远程 APNs 骨架。`PUSH_ENABLED`（`bool.fromEnvironment`，默认 false）；后端地址复用 `REPORT_API_BASE`；匿名 `installation_id`（SharedPreferences）；`MethodChannel('health_archive/push')` 拿 APNs token → `POST /api/push/device-tokens`。未启用 / 未配置时安全空转。
- `ios/Runner/AppDelegate.swift`：加 `health_archive/push` channel——`registerForRemoteNotifications` + `didRegisterForRemoteNotificationsWithDeviceToken` 回传十六进制 token。
- `lib/main.dart`：启动 `unawaited` 调 `NotificationService.init` / `PushService.init` / `syncReminders()`；`syncReminders()` = 补 notifications 行 + 用全档案可排程提醒重排系统通知，任何提醒变更后都调它。

### Flutter UI

- `lib/pages/reminders_page.dart`：复查提醒 / 服药提醒 / 最近通知三段；复查可「标记已复查」、服药有开关、都可删；「新建复查提醒」bottom sheet（预设 1/2/3/半年）。
- `lib/widgets/reminder_summary.dart`：首页概览卡下方「待办提醒」摘要（到期/7 天内复查 + 今日服药项数 + 未读数徽标），无内容时 `SizedBox.shrink()`。
- `lib/pages/metric_history_page.dart`：顶部加「设置复查提醒」卡（异常指标有提示文案），已设时显示日期 + 「取消」。
- `lib/pages/medication_page.dart`：用药编辑页加「服药提醒」`SwitchListTile` + 时间 chip（`showTimePicker` 可改、可加/删）；保存时 `setMedicationReminder`，删药时 `deleteMedicationReminder`。
- `lib/pages/profile_page.dart`：「家庭成员」下加「提醒」入口。

### FastAPI 后端

- `backend/app/push_db.py` + `models_push.py`：`device_tokens` 表用**独立小库**（`PUSH_DATABASE_URL`，默认本地 SQLite），与 `ENABLE_CLOUD_BACKUP` 无关，v1 精简模式也建表。按匿名 `installation_id` upsert。
- `backend/services/apns_service.py`：`ApnsConfig.from_env()`（`PUSH_ENABLED` / `APNS_KEY_ID` / `APNS_TEAM_ID` / `APNS_BUNDLE_ID` / `APNS_PRIVATE_KEY(_PATH)` / `APNS_USE_SANDBOX`）；`RealApnsClient`（ES256 JWT + HTTP/2）/ `MockApnsClient`；`get_apns_client()` 配置齐全用真实、否则 mock 并记日志缺哪些；`send_push_to_installation(db, installation_id, ...)`。
- `backend/app/api_push.py`：`POST/DELETE /api/push/device-tokens`、`GET /api/push/status`、`POST /api/push/test`。始终挂载；未配置时 `/test` 返回 `channel: "mock"`。
- `backend/main.py`：import + `init_push_db()` in lifespan + `include_router(push_router)`。
- `backend/.env.example`：加 `PUSH_ENABLED=false` + APNs 参数占位 + `PUSH_DATABASE_URL`。
- `backend/requirements.txt`：加 `cryptography` / `h2`，`httpx` → `httpx[http2]`。
- `backend/tests/test_push.py`：token 增删改幂等、mock 发送、`/status`、404、配置不全回落 mock、缺 token。**需要 Python 3.10+**（同 `test_v05.py`——本机系统 Python 3.9 跑不了；`apns_service` 的 config 逻辑已单独在 3.9 下验证通过）。

### 文档

- `IOS_PUSH_SETUP.md`（新）：现在能用的部分、Apple 侧要创建什么（Developer Program / App ID + Push 能力 / APNs .p8 Key / Xcode capability）、填进 `backend/.env` 的参数、编译时 `--dart-define=PUSH_ENABLED=true`、验证步骤、代码位置、后续（服务端定时下发 / App 备案 / Android FCM）。

### 验证

- `flutter analyze` 无问题；`flutter test -j 1` **63 passed**（新增 `reminder_schedule_test`×4、`reminders_test`×6，widget_test 的「我的」页测试改用 `scrollUntilVisible`）。
- 后端文件 `py_compile` 全过；`apns_service` mock/real 切换逻辑在 Python 3.9 下手工验证通过。

### 待真机验证 / 已知边界

- **本机 iOS 构建当前起不来**：`flutter_local_notifications` / `flutter_timezone` 不支持 Swift Package Manager，需要 CocoaPods，而本机系统 Ruby 2.6 装不了新版 CocoaPods（`ffi` 要 Ruby ≥3）。装 CocoaPods 后（`sudo gem install cocoapods` + 新 Ruby，或 `brew install cocoapods`）即可构建。模拟器里现装的是 B1 那版（不含 B2）。
- 本地通知实际弹出、iOS 权限弹窗、APNs token 获取都要真机验。
- 服务端「按 reminders 定时主动 push」的 scheduler 未做——目前到点提醒靠设备本地通知；见 `IOS_PUSH_SETUP.md` 第 7 节。
- `notifications` 表目前只材料化「今天」的服药条目（每次打开 App 时补），不预生成未来多天。

## 17. B3 记录页搜索 / 筛选 / 标签 —— 完成记录（2026-08-29，代码完成，待真机验证）

### 数据库（schema v9）

- `medical_reports.tags` TEXT（默认 `''`，逗号分隔，如 `体检,术前`）。迁移 `from<9`：`addColumn`。`.g.dart` 已重新生成。

### 仓库层（`health_repository.dart`）

- `HealthRepository.normalizeTags(Iterable)` / `parseTags(String?)`（静态，去空/去重/剔除含逗号项）。
- `setReportTags(reportId, List<String>)` / `getDistinctReportTags()`（当前档案，按频次降序）/ `getDistinctHospitals()`（去重排序）。
- `insertReport` 加 `List<String> tags` 参数；`exportHealthData` 的 reports 项加 `'tags'`；`snapshot_importer._importReports` 传 `tags: parseTags(...)`。

### 过滤逻辑（`lib/utils/records_filter.dart`，纯逻辑，已测）

- `RecordFilter{ query, abnormalOnly, tags, hospitals, dateRange }` + `copyWith` + `activeCount`（关键词以外的生效条件数，用于「筛选」按钮徽标）+ `isReportOnly`（标签/医院筛选生效时非报告条目一律排除）。
- `matchesReport(r, {metricNames, hasAbnormalMetric})`：日期范围 → 医院 → 标签（任意命中）→ 只看异常 → 关键词（医院/类型/rawText/标签/指标名，忽略大小写 contains）。
- `matchesEntry({title, subtitle, status, measuredAt})`：报告专属筛选生效即 false；否则日期范围 → 只看异常 → 关键词。
- `RecordDatePreset` + `presetToRange`（全部/近1月/近3月/近1年/自定义）。

### 记录页（`records_page.dart`）

- 顶部加搜索框（带清除按钮）；来源 chip 行（全部/报告/日常）横向可滚 + 右侧「筛选·N」按钮；生效条件下方用 chip 列出 + 「清除」。
- `_load` 额外算每份报告的 `metricNames` / `hasAbnormalMetric`，并拉 `getDistinctReportTags` / `getDistinctHospitals`。
- `_visibleReports` / `_filteredReal` 叠加来源 chip + `RecordFilter`。
- `_FilterSheet`（bottom sheet）：只看异常开关、时间范围（预设 chip + `showDateRangePicker` 自定义）、标签多选（有标签才显示）、医院多选（有医院才显示）、重置/应用。
- `_ReportTile`：显示标签小 chip（`# 体检`）；**长按报告卡片** → `_TagEditSheet`（当前标签可删、输入框新建、常用标签「体检/术前/复查/住院/门诊」+ 历史标签快捷添加）。

### 测试

- `test/records_filter_test.dart`（normalizeTags/parseTags、presetToRange、matchesEntry 各分支、matchesReport 用内存库建真实报告测关键词/标签/医院/异常/时间）。
- `test/report_tags_test.dart`（setReportTags 标准化、getDistinctReportTags 频次序、getDistinctHospitals、导出含 tags、按档案隔离）。
- `compile_check_test.dart` 引用 `RecordFilter`。
- `sample_data_seeder` 给 3 份报告加了 `tags`（体检/慢病随访）。
- `flutter analyze` 无问题；`flutter test -j 1` **72 passed**。

### 待真机验证 / 边界

- 同 B2：本机 iOS 构建被 CocoaPods 阻塞（`flutter_local_notifications`）。
- 身体部位筛选未做（报告的影响部位是派生值）——留到需要时再加。
- 搜索是「当前档案已加载的全部记录」上的客户端过滤，没做数据库级 FTS（个人档案量级够用）。

## 18. B4 首页 / 我的 重构 + 「给医生看的摘要」 —— 完成记录（2026-08-29，代码完成，待真机验证）

### 「给医生看的摘要」（核心）

- `lib/utils/medical_summary.dart`（纯逻辑，已测）：`buildMedicalSummary({profile, diseases, medications, metrics, reports, reportMetricCounts, now})` → `MedicalSummary`。
  - 疾病：排除「已恢复」；`名称（状态）`。
  - 用药：排除「已停用」；`名称 剂量单位 每日N次`。
  - 异常指标：按 metricId 取最新一条，`偏高/偏低/异常` 才收；与上一条比出 `↑/↓/→` + 「上次 X（日期）」；带参考范围；按日期倒序取前 12。
  - 近期报告：前 5 份（医院 / 日期 / 类型 / 指标数）。
  - `toPlainText()` 生成纯文本版；末尾固定「仅供就诊参考，不含医疗诊断」。
  - **过敏**：当前没有数据模型，v1 未包含（future）。
- `lib/pages/medical_summary_page.dart`：把摘要卡片包在 `RepaintBoundary` 里，「导出为图片并分享」= `boundary.toImage(pixelRatio:3)` → PNG → 临时目录 → `SharePlus`（纯 Dart，中文用系统字体，**不依赖 CocoaPods / `pdf` 包 / 字体资源**）；AppBar 另有「分享文字」。空档案显示引导文案。

### 我的（`profile_page.dart`）

- 设置项分组：**档案**（个人资料 / 家庭成员）、**健康记录**（疾病史 / 用药记录 / 提醒）、**就医**（给医生看的摘要）、**数据**（数据与隐私 / 关于）。
- 查看家庭成员（`activeProfileId != 1`）时，资料卡加一枚「当前查看的是家庭成员」提示标签，缓解「我的」标题歧义。

### 首页（`home_page.dart`）

- AppBar 加「搜索记录」`Icons.search` → push `RecordsPage`（复用 B3 的搜索/筛选）。
- body 结构未动：已有 `ProfileSwitcher`（B1）+ `ReminderSummary`（B2）+ 概览卡 + 健康资料主题 + 优先关注部位，层次尚可，不做高风险重排。

### 测试

- `test/medical_summary_test.dart`（空档案 isEmpty；疾病/用药过滤、异常指标趋势箭头 + 上次值、正常指标不入列、报告数、`toPlainText` 内容）。
- `compile_check_test.dart` 引用 `MedicalSummaryPage` / `buildMedicalSummary`。
- `flutter analyze` 无问题；`flutter test -j 1` **74 passed**。

### 待真机验证 / 边界

- `RepaintBoundary.toImage` 导出图片 + 分享面板需真机验（模拟器/单测不覆盖）。
- 过敏史没有录入入口和字段，摘要暂不含。
- 首页信息架构只做了加搜索入口，没有整体重排——若后续觉得首页太长，再单独收拾。
