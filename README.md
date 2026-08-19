# 健康档案 HealthArchive — MVP UI 原型 V0.1

面向中国成年用户的个人健康管理 App。当前为 V0.3：具备「手工录入检查指标 + 日常记录 + 本地保存 + 查看 + 编辑 + 删除」的真实健康数据能力。

技术栈：Flutter + Dart + Material 3（浅色），支持 Android / iOS / Web。
本地持久化：drift（基于 SQLite，跨 Android/iOS/Web）。不接后端、不接登录、不接云。

---

## 项目结构

```
D:\健康ios项目mvp-20260819
├─ pubspec.yaml               # 项目配置（drift 本地数据库等依赖）
├─ analysis_options.yaml      # 代码规范配置
├─ README.md                  # 本说明文件
├─ lib/
│  ├─ main.dart               # 应用入口 + 全局主题 + 底部 5 个 Tab + 数据库初始化
│  ├─ data/
│  │  ├─ app_database.dart        # drift 数据库定义（两张表）
│  │  ├─ app_database.g.dart      # drift 生成的代码（勿手改）
│  │  └─ health_repository.dart   # 数据访问层（增删改查）
│  ├─ models/
│  │  ├─ fake_data.dart           # V0.2 假数据（保留，用于示例展示）
│  │  └─ metric_dictionary.dart   # 标准指标字典 + 状态计算
│  ├─ utils/
│  │  └─ format.dart              # 日期时间格式化
│  ├─ widgets/
│  │  ├─ section_title.dart          # 页面模块标题
│  │  ├─ health_status_card.dart     # 通用状态卡片 + 状态颜色
│  │  ├─ record_tile.dart            # 健康记录卡片
│  │  └─ metric_selector.dart        # 指标选择底部面板（按身体系统分组 + 搜索）
│  └─ pages/
│     ├─ home_page.dart            # 首页
│     ├─ body_page.dart            # 身体（真实数据优先 + 系统详情）
│     ├─ records_page.dart         # 记录（真实数据 + 假数据示例）
│     ├─ add_page.dart             # 添加
│     ├─ profile_page.dart         # 我的
│     ├─ manual_metric_entry_page.dart   # 手工录入 / 编辑检查指标 ★V0.3
│     ├─ daily_health_entry_page.dart    # 日常记录（体重/血压/血糖/心率）★V0.3
│     ├─ metric_history_page.dart        # 指标历史（查看/编辑/删除）★V0.3
│     ├─ kidney_detail_page.dart   # 肾脏详情
│     ├─ report_detail_page.dart   # 检查详情
│     └─ placeholder_page.dart     # 通用占位页
├─ web/
│  ├─ sqlite3.wasm            # drift 在 Web 上运行 SQLite 所需（勿删）
│  ├─ drift_worker.js         # drift 在 Web 上使用的后台 Worker（勿删）
│  └─ drift_worker.dart       # 编译上述 Worker 的源文件（不用手写）
└─ test/
   ├─ widget_test.dart        # UI 冒烟测试
   ├─ repository_test.dart    # 数据层 CRUD 闭环测试
   ├─ e2e_flow_test.dart      # 录入→记录页→身体页→删除 端到端接线测试
   └─ compile_check_test.dart # 编译校验
```

---

## V0.3 说明

- **手工录入**：添加页「手工录入」→ 选择指标（按身体系统分组、可搜索）→ 输入结果/单位/参考范围/日期/备注 → 保存。
- **日常记录**：添加页「日常记录」→ 体重 / 血压 / 血糖 / 心率 四类。
- **本地保存**：使用 drift（SQLite），关闭 App 再打开数据仍在。
- **状态判断**：填写完整参考范围才判断（偏高/偏低/正常），否则显示「未判断」，不使用任何 AI。
- **真实数据优先**：首页/身体/记录页优先显示用户录入的最新真实数据；没有真实数据时才显示 V0.2 假数据。
- **查看/编辑/删除**：点真实记录进入详情，可编辑或删除（删除需二次确认）。
- **Web 注意事项**：drift 在浏览器里运行 SQLite 需要 `web/sqlite3.wasm` 和 `web/drift_worker.js`（已内置）。在 `flutter run -d chrome` 下如遇浏览器安全限制（COOP/COEP），drift 会自动降级，仍能展示 UI。

### 数据库代码如何维护（重要）

drift 的 `app_database.g.dart` 是自动生成的文件，**当且仅当修改了 `app_database.dart` 里的表结构时**才需要重新生成。
由于你的项目路径包含中文（`健康ios项目mvp`），本机不能直接在项目里跑 `dart run build_runner`（会报错）。
解决办法：在纯英文临时目录复制 `app_database.dart` 跑生成，再拷回。或委托维护人处理。

### 常用命令

```
flutter pub get
flutter test
flutter run -d chrome      # 浏览器预览
flutter run                # 连接手机后运行（Android/iOS 持久化正常）
```

---

## 一、如何创建 Flutter 项目

### 第 1 步：安装 Flutter SDK（只需要做一次）

1. 打开 https://docs.flutter.dev/get-started/install/windows
2. 下载 Flutter SDK 压缩包（Windows 版）
3. 解压到一个不容易动到的目录，例如 `D:\flutter`
4. 把 `D:\flutter\bin` 加入系统环境变量 PATH（解压后 `D:\flutter\bin\flutter.bat` 里运行 `flutter` 命令）
5. 打开终端（按 `Win + R`，输入 `cmd`，回车），运行：

   ```
   flutter doctor
   ```

   检查结果中 `[✓]` 表示正常，`[!]` 或 `[x]` 表示还缺东西（通常是 Android Studio / Xcode，按提示安装即可）。
   国内网络慢的话，先看文末「常见问题」第 2 条设置镜像。

### 第 2 步：生成平台文件夹（只需要执行一次）

本项目的代码我已经全部写好并放在这个文件夹里了。你只需要在终端里执行：

```
cd D:\健康ios项目mvp-20260819
flutter create --project-name health_archive .
flutter pub get
```

说明：

- `flutter create .` 只负责补全 `android/`、`ios/`、`web/` 等平台文件夹，
  **不会覆盖我已经写好的 `lib/` 里的代码和 `pubspec.yaml`**（Flutter 官方行为：只重建缺失的文件）。
- 执行后会多出一些文件夹，不用管它们。

---

## 二、需要创建的文件

所有文件都已在上面「项目结构」中列好并创建完毕。你不需要手动创建任何文件。

---

## 三、完整代码

每个文件都是完整、可运行的代码，直接打开查看即可：

| 文件 | 作用 |
| --- | --- |
| `lib/main.dart` | 应用入口、全局主题（医疗蓝绿主色、浅灰白背景、状态颜色）、底部 5 个 Tab |
| `lib/models/fake_data.dart` | 首页指标、身体系统、肾脏指标、历史趋势、记录时间线、检查指标等全部假数据 |
| `lib/widgets/section_title.dart` | 模块标题，如「近期关注」 |
| `lib/widgets/health_status_card.dart` | 通用状态卡片；状态颜色规则（正常绿 / 需要关注橙 / 偏高红 / 数据不足灰，始终同时显示文字） |
| `lib/widgets/record_tile.dart` | 健康记录卡片 |
| `lib/pages/home_page.dart` | 首页：问候卡片、近期关注 3 张卡、身体系统 6 宫格、最近记录 2 条 |
| `lib/pages/body_page.dart` | 身体：6 个身体系统卡片，点击「肾脏」进入肾脏详情 |
| `lib/pages/kidney_detail_page.dart` | 肾脏详情：最近检查、3 个关键指标、历史趋势（自定义布局，无图表库）、相关检查记录 |
| `lib/pages/records_page.dart` | 记录：全部 / 医院检查 / 日常记录 筛选标签（仅 UI）+ 时间线，点医院记录进检查详情 |
| `lib/pages/report_detail_page.dart` | 检查详情：医院信息、4 个检查指标、原始报告灰色占位卡 |
| `lib/pages/add_page.dart` | 添加：4 个大按钮，点击弹出「该功能将在下一阶段开发」 |
| `lib/pages/profile_page.dart` | 我的：个人资料卡 + 5 项设置列表，点击进入占位页 |
| `lib/pages/placeholder_page.dart` | 通用占位页 |
| `test/widget_test.dart` | 自动化冒烟测试（可选） |

> 想改任何展示内容（名字、数值、日期），只需要改 `lib/models/fake_data.dart` 一个文件。

---

## 四、如何运行

### 方式 1：Android 手机（推荐，最简单）

1. 手机开启「开发者选项」→「USB 调试」，用数据线连电脑
2. 终端运行：

   ```
   flutter devices
   ```

   能看到手机后，运行：

   ```
   flutter run
   ```

### 方式 2：Android 模拟器

1. 安装并打开 Android Studio，选择「Device Manager」启动一个模拟器
2. 终端运行 `flutter run`

### 方式 3：iOS（需要 Mac + Xcode）

1. 打开 `ios/Runner.xcworkspace`，或直接在终端运行：

   ```
   flutter run
   ```

   然后选择模拟器即可

### 方式 4：先快速看效果（Windows 电脑上也可以）

```
flutter run -d chrome
```

会在浏览器里打开网页版预览（仅预览用，正式发布仍是 Android / iOS）。

常用命令：

```
flutter run          # 运行
flutter test         # 运行自动化测试
flutter analyze      # 静态检查代码（可选）
```

---

## 五、正常运行后你应该看到什么

底部固定 5 个 Tab：**首页 / 身体 / 记录 / 添加 / 我的**。

- **首页**：顶部问候卡片（下午好，徐先生 / 上次更新：2026年8月18日）；
  「近期关注」3 张卡片（糖化血红蛋白 6.8% 持续上升、尿酸 480 μmol/L 偏高、LDL-C 3.6 mmol/L 需要关注）；
  「身体系统」两列 6 宫格（心血管、血糖代谢、肝脏、肾脏、甲状腺、血液，各带状态）；
  「最近记录」2 条记录。
- **身体**：6 个身体系统卡片，每个可点击；点「肾脏」进入肾脏详情页
  （最近检查、肌酐 / eGFR / 尿酸 三个指标、历史趋势 2024→2026 上升、相关检查记录）。
- **记录**：顶部「全部 / 医院检查 / 日常记录」筛选标签（可切换，暂不真正筛选）；
  3 条时间线记录，点医院检查记录进入「检查详情」页（ALT、AST、尿酸、LDL-C 指标 + 原始报告占位图）。
- **添加**：4 个大按钮（拍摄检查报告 / 上传报告 / 手工录入 / 日常记录），点击弹出提示「该功能将在下一阶段开发」。
- **我的**：个人资料卡（徐先生、36岁、138\*\*\*\*8888）+ 设置列表
  （个人资料、疾病史 3条、用药记录 2种正在使用、数据与隐私、关于健康档案），点击进入占位页。

整体风格：浅色、大量留白、圆角卡片、医疗蓝绿主色，状态同时用颜色 + 文字表达。

---

## 常见问题

**1. 提示「flutter 不是内部或外部命令」**
   说明 PATH 没配置好。把 `D:\flutter\bin` 加入系统环境变量后，重新打开终端再试。

**2. `flutter pub get` 很慢或失败（国内网络）**
   在终端先执行下面两行，再重新运行 `flutter pub get`：

   ```
   set PUB_HOSTED_URL=https://pub.flutter-io.cn
   set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   ```

**3. 报错找不到 `CardThemeData` 或 `withValues`（说明 Flutter 版本比较旧）**
   本项目需要 Flutter ≥ 3.27（Dart ≥ 3.6）。升级 Flutter 到最新稳定版即可：
   在 SDK 目录运行 `flutter upgrade`。
   如果暂时无法升级，可以把 `lib/main.dart` 里的 `CardThemeData` 改成 `CardTheme`，
   并把代码里所有 `.withValues(alpha: …)` 改成 `.withOpacity(…)`。

**5. 运行时想看有哪些设备**
   运行 `flutter devices`；真机记得开启 USB 调试。

---

## V0.4A：报告导入（Mock 识别）

新增「上传报告」闭环：选化验单图片 → Mock 识别 → 用户确认/编辑 → 批量写入 Drift → 记录页与身体系统自动出现，并保留原始图片。

### V0.4A 涉及的新文件
```
lib/models/report_models.dart            # RecognizedMetric / StructuredMedicalReport / 指标别名匹配
lib/services/report_recognition_service.dart  # 抽象接口 + Mock + Remote(TODO)
lib/pages/report_import_page.dart        # 上传报告：选图/预览/识别/loading/错误
lib/pages/report_review_page.dart        # 确认页：医院/日期/类型可改、指标编辑、复选、低置信度提示、确认保存
lib/utils/image_storage.dart             # 选图（file_picker）
lib/utils/report_image_save(.io/web).dart    # 移动端落盘 / Web 不落盘（条件导入）
lib/utils/file_image(.io/web).dart           # 原图显示（条件导入，避免 web 编译 dart:io 报错）
```

### V0.4A 数据库变化（⚠️ 需要 migration）
- 新增表 `medical_reports`（id/hospitalName/reportDate/reportType/sourceImagePath/rawText/createdAt）
- `health_metrics` 增加可空字段 `reportId`（手工录入为 null，报告导入为对应报告 id）
- `schemaVersion` 1 → **2**；`onUpgrade` 处理 from<2（createTable + addColumn）。
- 说明：`.g.dart` 已重新生成好提交在本仓库；若你本地已有旧数据库，`AppDatabase` 启动会自动执行上面迁移。若你之后要**再次修改 app_database.dart 的表结构**，需在纯英文临时目录重跑 build_runner（原因同 V0.3 中文路径限制）。

### 识别服务
- `MockReportRecognitionService`：不调任何真实 OCR/AI，返回一组预设指标，跑通闭环。
- `RemoteReportRecognitionService`：TODO 占位，接真实服务商时实现（不写死任何 API Key）。
- 页面只依赖 `ReportRecognitionService` 抽象，不依赖具体提供商。

### 隐私约定
- 不在日志打印完整健康数据 / 报告全文；识别服务与 UI 解耦；图片与 rawText 仅存本地库，不发送到任何云。

### 尚未完成 / TODO
- `RemoteReportRecognitionService` 接真实 OCR/AI（等确认服务商）。
- 相机「拍摄检查报告」暂未接入本识别流程（可在稳定后用同一套服务接上）。
- PDF 报告暂不支持。

---

## V0.4B：真实识别（拍照 + 后端接入）

把 V0.4A 的「Mock 识别」升级为可接真实服务，并新增相机拍照入口。识别仍必须经过用户确认才入库。

### 新增/涉及的文件
```
backend/main.py                 # 最小后端：百度 OCR + DeepSeek → 统一 JSON（Key 仅后端）
backend/requirements.txt        # fastapi / uvicorn / requests
backend/README.md               # 部署 + 环境变量 + 隐私说明
docs/backend_api.md             # 接口契约 / 统一 JSON / 硬性约束
lib/pages/report_recognition_flow.dart  # 共享识别流程（拍照与上传共用；全屏 Loading 防重复点击）
lib/pages/report_capture_page.dart      # 拍照入口（预览/重新拍摄/使用照片）
lib/utils/image_storage.dart            # 新增 captureLabReportImage()
lib/services/report_recognition_service.dart  # Remote 真实实现（上传图片→本地匹配+计算状态）
lib/data/app_database.dart + .g.dart    # medical_reports 增 recognitionStatus（schemaVersion 2→3）
lib/data/health_repository.dart         # insertReport 支持识别状态；新增 setReportStatus
lib/models/report_models.dart           # RecognizedMetric 增 originalStatus
pubspec.yaml                            # +image_picker +http
```

### 真实识别如何开启（需先部署后端）
1. 搭好 `backend/`（填好 `BAIDU_API_KEY`/`BAIDU_SECRET_KEY`/`DEEPSEEK_API_KEY` 环境变量并启动）。
2. 用编译期变量指定后端地址与 Remote 模式运行（仅 Debug）：
   ```
   flutter run --dart-define=REPORT_AI=remote --dart-define=REPORT_API_BASE=https://你的后端
   ```
3. 不配置时默认用 `MockReportRecognitionService`，可离线跑通全流程。普通用户构建不含 Remote 开关。

### 隐私与安全
- 所有第三方 API Key 只存放后端环境变量，Flutter App 与代码库均不含。
- App 只访问自有后端；后端日志只记 `metrics count / duration`，不记姓名/全文/图片。
- AI 只做「文字→结构」，不做诊断/用药建议；App 按报告参考范围本地计算偏高/偏低/正常，不信任 AI 状态。

### 本版数据库 migration
`schemaVersion` **2 → 3**：`medical_reports` 增加 `recognitionStatus`（pending/review/confirmed 等）。`.g.dart` 已重新生成并提交。

### TODO / 边界
- 真实 OCR/AI 需你在百度与 DeepSeek 申请 Key 并部署 `backend/` 后才能联调（我没法替你在本机拿到 Key）。
- 拍摄入口在 Web 上不调用相机（按约定移动端为主）。
- PDF、CT/MRI/病理等仍不支持。
