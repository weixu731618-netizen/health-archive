import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/image_storage.dart';
import 'report_recognition_flow.dart';

/// 报告导入页（上传）：选择化验单图片 -> 识别（走共享 [startReportRecognitionFlow]）。
class ReportImportPage extends StatefulWidget {
  const ReportImportPage({super.key});

  @override
  State<ReportImportPage> createState() => _ReportImportPageState();
}

class _ReportImportPageState extends State<ReportImportPage> {
  PickedReportImage? _image;
  String? _error;

  Future<void> _pickImage() async {
    setState(() => _error = null);
    try {
      final picked = await pickLabReportImage();
      if (mounted) setState(() => _image = picked);
    } catch (e) {
      if (mounted) {
        setState(() => _error = '无法读取该图片，请重新选择');
      }
    }
  }

  Future<void> _recognize() async {
    final img = _image;
    if (img == null) return;
    setState(() => _error = null);
    // 共享识别流程自带全屏 Loading，天然防止重复点击。
    await startReportRecognitionFlow(context, img);
  }

  void _goManual() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          const SnackBar(content: Text('可回到「添加」页使用手工录入')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '选择一张化验单图片，系统将自动识别其中的检查指标',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          // 图片预览区域
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _image == null
                  ? Column(
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 56, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        const Text('尚未选择图片',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('选择化验单图片'),
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
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _image!.fileName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _pickImage,
                              child: const Text('重新选择'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _image = null),
                              child: const Text('移除'),
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
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 20, color: AppColors.abnormal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: _goManual,
                    child: const Text('手工录入'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _image == null ? null : _recognize,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('识别报告', style: TextStyle(fontSize: 16)),
          ),
          if (_error != null && _error!.contains('识别失败'))
            const SizedBox(height: 8),
          if (_error != null && _error!.contains('识别失败'))
            Center(
              child: TextButton(
                onPressed: _recognize,
                child: const Text('重新识别'),
              ),
            ),
        ],
      ),
    );
  }
}
