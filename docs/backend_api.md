# V0.4B — 最小识别后端接口契约

本阶段只做一个接口，用于把「图片」转成「结构化报告 JSON」。
Flutter App 不直接调用任何 OCR / AI 服务商，App 只访问**自己的后端**，
由后端负责调用选定的 OCR / AI 服务商（并保管 API Key / Secret）。

```
Flutter App
  │  POST /api/report/recognize  (图片)
  ▼
本后端
  │
  ├─ OCR 层：把图片读成原始文字（如 PaddleOCR / 百度 / 腾讯 / 阿里）
  ├─ AI 层：把原始文字结构化成本报告定义的 JSON（可选：大模型）
  │
  └─ 返回统一 JSON
      ▼
  Flutter App（ReportRecognitionService）
      ▼
  ReportReviewPage（用户确认）
      ▼
  Drift 入库
```

## 1. 接口

- 方法：`POST`
- 路径：`/api/report/recognize`
- 请求体：`multipart/form-data`，字段名 `file`，值为一张图片（JPG/JPEG/PNG）。
- 成功响应：HTTP 200，`application/json`，body 为本报告第二节的「统一识别结果 JSON」。
- 失败响应：HTTP 4xx/5xx，body 形如：
  ```json
  { "error": { "code": "UPSTREAM_ERROR", "message": "..." } }
  ```

## 2. 统一识别结果 JSON（服务端返回）

```json
{
  "hospitalName": "深圳XX医院",     // 识别不到给 null/空
  "reportDate": "2026-08-18",       // 识别不到给 null
  "reportType": "生化检查",
  "patientName": null,              // 仅供用户核对，不作为身份判断
  "metrics": [
    {
      "rawName": "尿酸",
      "value": 480,
      "unit": "μmol/L",
      "referenceMin": 210,          // 报告里没有就给 null
      "referenceMax": 420,          // 报告里没有就给 null
      "referenceText": "210-420",
      "originalStatus": "H",        // 报告上的异常标记；没有就给 null
      "confidence": 0.96
    }
  ]
}
```

### 硬性约束（服务端实现必须遵守）
- **绝不补全**：参考范围 / 单位 / 日期等，报告里没有就是 `null`，不许用模型医学知识去猜。
- **AI 只读不改**：AI 层只做「文字 → 结构」，不做疾病/用药/治疗方案判断。
- **严格 JSON**：AI 输出必须是本 schema 的 JSON，不要 Markdown、不要解释性段落、不要"根据您的报告……"。
  AI 返回无法解析时，整个任务标记失败，由前端提示重试，绝不把脏数据写库。
- 服务端不得把完整健康数据写进日志（可记录：`recognize success`, `metrics count`, `duration ms`）。

## 3. Flutter 侧对接

`RemoteReportRecognitionService`（`lib/services/report_recognition_service.dart`）实现 `recognizeReport(...)` 时：
1. 把图片 `multipart/form-data` POST 到后端地址（地址由后端配置传回，不在代码里写死）。
2. 设置合理网络超时（例如 30s）。超时/失败 → 抛异常，由共享流程显示「报告识别失败 / 网络连接失败」。
3. 解析统一 JSON → `StructuredMedicalReport`（端点后处理：用本地指标字典匹配 `metricId`，用本地 `computeStatus` 计算偏高/偏低/正常）。
4. 不做任何疾病判断。

## 4. 后端技术选型推荐

由于本项目是个人健康 App 的最小后端，**推荐 Python + FastAPI**，理由：
- 单文件即可起服务，部署/维护最简单，适合「最小后端」定位。
- 与主流 Python OCR（PaddleOCR）和大模型 SDK 生态契合，后续接服务商方便。
- 异步、易加超时与限流。
- 相比 Django/Spring：无重框架、无默认项目结构，符合"不要引入大型后端框架"。

（若后续你对技术栈有偏好，可替换为任意能实现该接口的语言，接口契约不变。）

## 4.1 已选方案（V0.4B）

经确认采用：
- **OCR 层**：百度智能云「文字识别」（通用文字识别）。
- **结构化层**：DeepSeek（`deepseek-chat`，OpenAI 兼容 Chat API，强制 JSON）。
- **后端**：Python + FastAPI，实现在 `backend/`。

Key / Secret 只存后端环境变量：`BAIDU_API_KEY`、`BAIDU_SECRET_KEY`、`DEEPSEEK_API_KEY`（详见 `backend/README.md`）。Flutter App 仅上传图片到自有后端地址（`REPORT_API_BASE`），**不保存任何第三方 API Key**。

## 5. 尚未接入

- 真实 OCR / AI 服务商**尚未选定**：见 README 与「V0.4B 服务商选择」讨论。
- `RemoteReportRecognitionService` 在服务商选定并搭出后端接口后才落地。
- 当前共用 `MockReportRecognitionService` 跑通全流程。
