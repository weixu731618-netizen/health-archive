# 健康档案 · 识别后端（V0.4B）

最小识别后端：`POST /api/report/recognize`，接收一张化验单图片，返回统一 JSON。
调用链：**Flutter App → 本后端 → 百度智能云 OCR → DeepSeek 结构化 → 统一 JSON → Flutter**。

接口契约/统一 JSON 说明见 `docs/backend_api.md`。

## 目录
```
backend/
├─ main.py             # FastAPI 应用（唯一接口）
├─ requirements.txt    # Python 依赖
└─ README.md           # 本文档
```

## 运行

```bash
cd backend
pip install -r requirements.txt

# 设置环境变量（绝不写进代码库 / Flutter 客户端）
export BAIDU_API_KEY=你的百度APIKey
export BAIDU_SECRET_KEY=你的百度SecretKey
export DEEPSEEK_API_KEY=你的DeepSeekKey

uvicorn main:app --host 0.0.0.0 --port 8000
```

> Windows PowerShell 用 `setx` 或 `$env:变量=值`。
> 部署到国内云服务器时，把后端地址配给 Flutter 侧（通过 `REPORT_API_BASE` 编译期变量或后端下发），不要硬编码到客户端里写死。

## 环境变量

| 变量 | 必填 | 说明 |
| --- | --- | --- |
| `BAIDU_API_KEY` | 是 | 百度智能云「文字识别」应用的 API Key |
| `BAIDU_SECRET_KEY` | 是 | 配套 Secret Key（用于换 access_token） |
| `DEEPSEEK_API_KEY` | 是 | DeepSeek 平台 API Key |
| `DEEPSEEK_BASE` | 否 | 默认 `https://api.deepseek.com` |
| `DEEPSEEK_MODEL` | 否 | 默认 `deepseek-chat` |
| `BAIDU_OCR_URL` | 否 | 百度 OCR 接口地址（默认通用文字识别 general） |

## 请求 / 响应

- `POST /api/report/recognize`，`multipart/form-data` 字段 `file`（JPG/JPEG/PNG，≤8MB）。
- 200：统一识别 JSON（见 `docs/backend_api.md` 第二节）。
- 4xx/5xx：`{"detail": "..."}`（FastAPI 默认错误体）或 `{"error": {...}}`。

## 隐私与安全（必须遵守）

- **所有 Key / Secret 只放后端环境变量**，不进入 Flutter App（App 可被反编译）。
- 日志只记录 `recognize success / metrics count / duration ms`，**绝不打印**患者姓名、报告全文、OCR 文本、图片内容。
- 百度 OCR 会上传报告图片、DeepSeek 会收到 OCR 文字 —— 请确认你认可这两家作为第三方处理你的报告数据。
- AI 只把文字转成结构，不做诊断 / 用药 / 治疗方案判断，不补全缺失的参考范围/单位/日期。

## 说明
- 本实现用「百度通用文字识别 + DeepSeek」。若日后换服务商，只需改本文件 `baidu_ocr_text` / `deepseek_structured` 两处，接口与 Flutter 端零改动。
- 部署需你自行申请百度「文字识别」与 DeepSeek 的 Key（百度需实名/企业认证、DeepSeek 需注册并按量计费）。
