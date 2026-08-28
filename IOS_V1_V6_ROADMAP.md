# Health Archive iOS V1–V6 开发交接与路线图

> 更新日期：2026-08-28  
> 用途：下次继续开发时快速恢复上下文。  
> 原则：优先跑通关键路径，不重复做低价值的细碎测试。

## 1. 当前结论

- V1「iPhone 真机稳定运行」已完成。
- V2「清除假数据并完善本地功能」的核心代码已完成，已通过静态检查和 31 项 Flutter 测试，新 Release 包已覆盖安装到真机。
- V2 只剩一次快速人工验收：确认首页、记录页和身体页不再显示演示数值/假报告。
- 下一条关键路径是 V3 真实 OCR，生产方案需要 HTTPS。

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
