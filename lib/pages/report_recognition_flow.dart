import 'package:flutter/material.dart';

import '../main.dart';
import '../models/report_models.dart';
import '../services/report_ocr_service.dart';
import '../services/report_recognition_service.dart';
import '../utils/image_storage.dart';
import 'ocr_debug_page.dart';
import 'report_review_page.dart';

/// 共享的报告识别流程：拍照与上传都走这里。
///
/// 结构：
///   [startReportRecognitionFlow] 接收 [PickedReportImage]
///   → push 一个全屏 Loading 页（该页在识别期间独占，天然防止重复点击）
///   → 若配置了后端：调 OCR（POST /api/report/ocr）→ 成功进入 [OcrDebugPage]（开发阶段）
///   → 否则（离线/Mock）：走 [ReportRecognitionService] 结构化 → [ReportReviewPage]（仍须确认）
///   → 失败在 Loading 页展示错误，提供「重新识别 / 手工录入 / 返回」
Future<void> startReportRecognitionFlow(
  BuildContext context,
  PickedReportImage image,
) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _RecognizingPage(image: image),
    ),
  );
}

class _RecognizingPage extends StatefulWidget {
  final PickedReportImage image;
  const _RecognizingPage({required this.image});

  @override
  State<_RecognizingPage> createState() => _RecognizingPageState();
}

enum _RecogState { loading, failed }

class _RecognizingPageState extends State<_RecognizingPage> {
  _RecogState _state = _RecogState.loading;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _state = _RecogState.loading;
      _error = '';
    });
    final img = widget.image;
    try {
      // V0.4C-1：若配置了后端，先展示真实 OCR 结果（开发阶段进入 OcrDebugPage）。
      if (RemoteOcrService.isConfigured) {
        final lines = await reportOcrService.ocrImage(
          imageBytes: img.bytes,
          fileName: img.fileName,
        );
        if (!mounted) return;
        if (lines.isEmpty) {
          throw StateError('未识别到文字，请确认图片是否清晰');
        }
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OcrDebugPage(lines: lines, imageBytes: img.bytes),
          ),
        );
      } else {
        // 离线 / Mock：走结构化 → 确认页。
        final report = await reportRecognitionService.recognizeReport(
          imageBytes: img.bytes,
          imagePath: img.path,
          fileName: img.fileName,
        );
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReportReviewPage(
              report: report,
              imageBytes: img.bytes,
              imageFileName: img.fileName,
            ),
          ),
        );
      }
    } catch (e) {
      // 隐私：不打印异常内部/数据内容。仅透出安全文案（如「网络连接失败」）。
      if (mounted) {
        setState(() {
          _state = _RecogState.failed;
          _error = (e is StateError && e.message.isNotEmpty)
              ? e.message
              : '报告识别失败';
        });
      }
    }
  }

  void _goManual() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('识别报告')),
      body: Center(
        child: _state == _RecogState.loading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在识别报告，请稍候',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textSecondary)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.abnormal),
                    const SizedBox(height: 12),
                    Text(_error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('你可以重新识别，或返回使用手工录入',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _run,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新识别'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _goManual,
                      child: const Text('手工录入'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
