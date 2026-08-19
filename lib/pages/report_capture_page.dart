import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/image_storage.dart';
import 'report_recognition_flow.dart';

/// 拍摄检查报告页（V0.4B）。
/// 拍摄一张化验单图片 → 预览 → 重新拍摄 / 使用照片 → 走共享识别流程。
class ReportCapturePage extends StatefulWidget {
  const ReportCapturePage({super.key});

  @override
  State<ReportCapturePage> createState() => _ReportCapturePageState();
}

class _ReportCapturePageState extends State<ReportCapturePage> {
  PickedReportImage? _image;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 进入页面即尝试拍照
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final img = await captureLabReportImage();
      if (mounted) setState(() => _image = img);
    } catch (_) {
      if (mounted) {
        setState(() => _error = '无法读取该图片，请重新拍摄');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _usePhoto() async {
    final img = _image;
    if (img == null) return;
    // 与「上传」完全相同的识别流程
    await startReportRecognitionFlow(context, img);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍摄检查报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '对准化验单拍照，确保文字清晰',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _image == null
                  ? Column(
                      children: [
                        if (_busy) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                        ] else ...[
                          const Icon(Icons.photo_camera_outlined,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          const Text('尚未拍摄',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _busy ? null : _capture,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('拍摄'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _image!.bytes,
                            height: 320,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _busy ? null : _capture,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重新拍摄'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _usePhoto,
                              icon: const Icon(Icons.check),
                              label: const Text('使用照片'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.abnormal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
            ),
          ],
        ],
      ),
    );
  }
}
