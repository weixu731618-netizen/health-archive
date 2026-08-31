import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/analytics.dart';
import '../services/report_ocr_service.dart';
import '../services/report_recognition_service.dart';
import '../utils/format.dart';
import '../utils/image_storage.dart';
import '../utils/report_image_save.dart';
import 'manual_metric_entry_page.dart';
import 'report_detail_page.dart';
import 'report_review_page.dart';

/// 共享的报告识别流程：拍照与上传都走这里。
///
/// 结构：
///   [startReportRecognitionFlow] 接收 [PickedReportImage]
///   → push 一个全屏 Loading 页（该页在识别期间独占，天然防止重复点击）
///   → 调真实识别（POST /api/report/recognize）→ [ReportReviewPage]
///   → 失败在 Loading 页展示错误，提供「重新识别 / 手工录入 / 返回」
Future<void> startReportRecognitionFlow(
  BuildContext context,
  PickedReportImage image, {
  String? initialArea,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _RecognizingPage(image: image, initialArea: initialArea),
    ),
  );
}

class _RecognizingPage extends StatefulWidget {
  final PickedReportImage image;

  /// 从器官详情页 `+` 进来时的「建议关联部位」，透传给 [ReportReviewPage]。
  final String? initialArea;

  const _RecognizingPage({required this.image, this.initialArea});

  @override
  State<_RecognizingPage> createState() => _RecognizingPageState();
}

enum _RecogState { loading, failed }

/// §10：识别等待期间轮播的阶段文案。不代表真实进度，只是让用户知道「在做事」。
const List<String> _stageTexts = [
  '正在识别文字',
  '正在识别检查项目',
  '正在整理异常指标',
  '正在关联身体部位',
];

class _RecognizingPageState extends State<_RecognizingPage> {
  _RecogState _state = _RecogState.loading;
  String _error = '';
  bool _transferredImageOwnership = false;

  /// OCR 失败但原件已落库时的报告 id（用于「查看原图」）。
  int? _savedFailedReportId;

  int _stage = 0;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    _startStageTicker();
    unawaited(_trackStart());
    _run();
  }

  Future<void> _trackStart() async {
    final repo = appRepository;
    final existing =
        repo == null ? 1 : (await repo.getAllReports()).length;
    if (existing == 0) {
      AnalyticsEvents.firstUploadStarted(source: 'ocr');
    } else {
      AnalyticsEvents.uploadStarted(source: 'ocr');
    }
  }

  void _startStageTicker() {
    _stageTimer?.cancel();
    _stageTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      setState(() => _stage = (_stage + 1) % _stageTexts.length);
    });
  }

  Future<void> _run() async {
    setState(() {
      _state = _RecogState.loading;
      _error = '';
      _stage = 0;
    });
    _startStageTicker();
    final img = widget.image;
    try {
      if (!RemoteOcrService.isConfigured) {
        throw StateError('真实识别后端未配置，无法从图片提取报告数据');
      }

      final report = await RemoteReportRecognitionService().recognizeReport(
        imageBytes: img.bytes,
        imagePath: img.path,
        fileName: img.fileName,
      );
      if (!mounted) return;
      _transferredImageOwnership = true;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportReviewPage(
            report: report,
            imageBytes: img.bytes,
            imageFileName: img.fileName,
            initialArea: widget.initialArea,
          ),
        ),
      );
    } catch (e) {
      // §9 / §32：识别失败也**不能丢原件**。把原始文件登记成一条
      // recognitionStatus='failed' 的报告，用户之后可重新识别或手动补充。
      await _persistUnparsed();
      // 隐私：不打印异常内部/数据内容。仅透出安全文案（如「网络连接失败」）。
      if (mounted) {
        AnalyticsEvents.ocrFailed();
        setState(() {
          _state = _RecogState.failed;
          _error =
              (e is StateError && e.message.isNotEmpty) ? e.message : '报告识别失败';
        });
      }
    }
  }

  /// 幂等：只在首次失败时登记原件（重试再失败不重复建行）。
  Future<void> _persistUnparsed() async {
    if (_savedFailedReportId != null) return;
    final repo = appRepository;
    final img = widget.image;
    if (repo == null || img.path == null) return;
    try {
      final id = await repo.insertReport(
        hospitalName: '',
        reportDate: DateTime.now(),
        reportType: img.isPdf ? 'PDF 报告' : '报告',
        sourceImagePath: img.path,
        rawText: null,
        recognitionStatus: 'failed',
      );
      _savedFailedReportId = id;
      _transferredImageOwnership = true; // 文件所有权已交给这条报告，dispose 不再删
    } catch (_) {
      // 落库失败也不崩；原件文件本身还在磁盘上。
    }
  }

  void _goManual() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
  }

  void _viewSavedOriginal() {
    final id = _savedFailedReportId;
    if (id == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportDetailPage(reportId: id)),
    );
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    if (!_transferredImageOwnership) {
      deleteManagedReportImage(widget.image.path);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('整理报告')),
      body: Center(
        child: _state == _RecogState.loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('正在整理报告',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _stageTexts[_stage],
                      key: ValueKey(_stage),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      _savedFailedReportId != null
                          ? '报告已保存，但暂时无法识别内容'
                          : _error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _savedFailedReportId != null
                          ? '原始文件已存进档案（${formatDate(DateTime.now())}）。'
                              '你可以重新识别，或手动补充信息。'
                          : '你可以重新识别，或返回使用手工录入',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _run,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新识别'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _goManual,
                      child: const Text('手动补充信息'),
                    ),
                    if (_savedFailedReportId != null)
                      TextButton(
                        onPressed: _viewSavedOriginal,
                        child: const Text('查看原图'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
