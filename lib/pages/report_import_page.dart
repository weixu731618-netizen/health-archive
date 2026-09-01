import 'package:flutter/material.dart';

import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/image_storage.dart';
import '../widgets/current_profile_badge.dart';
import '../widgets/error_note.dart';
import '../widgets/privacy_note.dart';
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
  /// 选中的报告页（图片 1 页；PDF 每页一项）。预览展示第 1 页。
  List<PickedReportImage> _pages = const [];
  PickedReportImage? get _image => _pages.isEmpty ? null : _pages.first;
  String? _error;

  Future<void> _pickFromGallery() =>
      _pick(() async => [await pickReportImageFromGallery()]);
  Future<void> _pickFromFile() => _pick(pickLabReportPages);

  Future<void> _pick(
      Future<List<PickedReportImage>> Function() picker) async {
    setState(() => _error = null);
    try {
      final picked = await picker();
      if (mounted) setState(() => _pages = picked);
    } on PickCancelled {
      // 用户取消，什么都不做
    } on StateError catch (e) {
      // 「未选择图片 / 未选择文件」是取消，不是错误 —— 静默。
      if (e.message.contains('未选择')) return;
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = '无法读取该文件，请重新选择');
    }
  }

  bool _recognizing = false;

  Future<void> _recognize() async {
    if (_pages.isEmpty || _recognizing) return;
    setState(() {
      _error = null;
      _recognizing = true;
    });
    try {
      await startReportRecognitionFlowPages(context, _pages,
          initialArea: widget.initialArea);
    } finally {
      if (mounted) setState(() => _recognizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.initialArea;
    return Scaffold(
      appBar: AppBar(title: const Text('导入报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const CurrentProfileBadge(),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '选择一张报告图片或 PDF —— 化验单、影像、病历、处方都可以。系统自动识别：'
              '有检查指标的进逐项核对，没有指标的（影像/病历等）存成图文报告（PDF 只识别第一页）。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          if (area != null && coreBodyAreaOrder.contains(area))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('将关联到：$area',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
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
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pages.length > 1
                              ? '${_image!.fileName}（共 ${_pages.length} 页）'
                              : _image!.fileName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _pickFromGallery,
                              icon:
                                  const Icon(Icons.photo_library_outlined),
                              label: const Text('相册'),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _pickFromFile,
                              icon:
                                  const Icon(Icons.folder_open_outlined),
                              label: const Text('PDF / 文件'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            // 这条路只处理图片/PDF，手工录入在这里没意义（PDF 没法手录），只展示错误。
            ErrorNote(message: _error!),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _image == null || _recognizing ? null : _recognize,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('识别报告', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
