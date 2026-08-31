import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/image_storage.dart';
import '../widgets/privacy_note.dart';
import 'manual_metric_entry_page.dart';
import 'report_recognition_flow.dart';

/// 报告导入页（上传）：选择化验单图片或 PDF -> 识别（走共享 [startReportRecognitionFlow]）。
class ReportImportPage extends StatefulWidget {
  /// 从某个器官 / 系统详情页的 `+` 进来时传入该部位名，识别核对页会作为
  /// 「建议关联部位」默认带上。
  final String? initialArea;

  const ReportImportPage({super.key, this.initialArea});

  @override
  State<ReportImportPage> createState() => _ReportImportPageState();
}

class _ReportImportPageState extends State<ReportImportPage> {
  PickedReportImage? _image;
  String? _error;

  Future<void> _pickFromGallery() => _pick(pickReportImageFromGallery);
  Future<void> _pickFromFile() => _pick(pickLabReportImage);

  Future<void> _pick(Future<PickedReportImage> Function() picker) async {
    setState(() => _error = null);
    try {
      final picked = await picker();
      if (mounted) setState(() => _image = picked);
    } catch (e) {
      if (mounted) {
        final msg = e is StateError && e.message.isNotEmpty
            ? e.message
            : '无法读取该文件，请重新选择';
        setState(() => _error = msg);
      }
    }
  }

  Future<void> _recognize() async {
    final img = _image;
    if (img == null) return;
    setState(() => _error = null);
    // 共享识别流程自带全屏 Loading，天然防止重复点击。
    await startReportRecognitionFlow(context, img,
        initialArea: widget.initialArea);
  }

  void _goManual() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
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
              '选择一张报告图片或 PDF，系统将自动识别其中的检查指标（PDF 按首页识别）',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const PrivacyNote(),
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
                        const Text('从相册选截图，或从文件选 PDF',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('相册'),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _pickFromFile,
                              icon: const Icon(Icons.folder_open_outlined),
                              label: const Text('PDF / 文件'),
                            ),
                          ],
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
                              onPressed: _pickFromGallery,
                              child: const Text('相册'),
                            ),
                            TextButton(
                              onPressed: _pickFromFile,
                              child: const Text('PDF / 文件'),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _image = null),
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
