import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/ios_button.dart';
import '../models/report_models.dart';
import '../services/analytics.dart';
import '../services/report_ocr_service.dart';
import '../services/report_recognition_service.dart';
import '../utils/image_storage.dart';
import '../utils/report_image_save.dart';
import 'imaging_report_page.dart';
import 'manual_metric_entry_page.dart';
import 'report_review_page.dart';

/// 共享的报告识别流程：拍照 / 扫描 / 上传都走这里。
///
/// 结构：
///   接收 1..N 页 [PickedReportImage]（单页拍照/单图，或多页扫描/多页 PDF）
///   → push 一个全屏 Loading 页（识别期间独占，天然防重复点击）
///   → **逐页**调真实识别（POST /api/report/recognize），再合并成一份
///   → 有指标 → [ReportReviewPage]；无指标但像图文 → [ImagingReportPage]；
///     没有实质内容 → 提示重拍
Future<void> startReportRecognitionFlow(
  BuildContext context,
  PickedReportImage image, {
  String? initialArea,
}) =>
    startReportRecognitionFlowPages(context, [image], initialArea: initialArea);

Future<void> startReportRecognitionFlowPages(
  BuildContext context,
  List<PickedReportImage> pages, {
  String? initialArea,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _RecognizingPage(pages: pages, initialArea: initialArea),
    ),
  );
}

class _RecognizingPage extends StatefulWidget {
  /// 按顺序的报告页（至少一页）。
  final List<PickedReportImage> pages;

  /// 从器官详情页 `+` 进来时的「建议关联部位」，透传给下游页。
  final String? initialArea;

  const _RecognizingPage({required this.pages, this.initialArea});

  @override
  State<_RecognizingPage> createState() => _RecognizingPageState();
}

enum _RecogState { loading, failed, classify }

/// §10：识别等待期间轮播的阶段文案。不代表真实进度，只是让用户知道「在做事」。
const List<String> _stageTexts = [
  '正在识别文字',
  '正在识别检查项目',
  '正在整理异常指标',
  '正在关联身体部位',
];

class _RecognizingPageState extends State<_RecognizingPage> {
  _RecogState _state = _RecogState.loading;
  bool _transferredImageOwnership = false;

  /// classify 状态下暂存的识别结果（供人工确认页的几个动作用）。
  StructuredMedicalReport? _pendingReport;

  /// 多页识别时的进度文案（"第 2 / 3 页"）；单页为空。
  String _pageProgress = '';

  /// 后端没配置时，重试必然再失败 —— 失败页就不显示「重新识别」。
  bool get _canRetry => RemoteOcrService.isConfigured;

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
    // C3：按阶段往前走，走到最后一句就停住，不循环重播（会显得像假进度）。
    _stageTimer = Timer.periodic(const Duration(milliseconds: 1600), (t) {
      if (!mounted) return;
      if (_stage >= _stageTexts.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _stage++);
    });
  }

  Future<void> _run() async {
    setState(() {
      _state = _RecogState.loading;
      _stage = 0;
    });
    _startStageTicker();
    final pages = widget.pages;
    final first = pages.first;
    try {
      if (!RemoteOcrService.isConfigured) {
        throw StateError('真实识别后端未配置，无法从图片提取报告数据');
      }

      // 逐页识别；多页时 loading 文案带进度。任一页联网失败则整份失败。
      final svc = RemoteReportRecognitionService();
      final perPage = <StructuredMedicalReport>[];
      for (var i = 0; i < pages.length; i++) {
        if (mounted && pages.length > 1) {
          setState(() => _pageProgress = '第 ${i + 1} / ${pages.length} 页');
        }
        perPage.add(await svc.recognizeReport(
          imageBytes: pages[i].bytes,
          imagePath: i == 0 ? first.path : null,
          fileName: pages[i].fileName,
        ));
      }
      final report = perPage.length == 1
          ? perPage.first
          : mergeStructuredReports(perPage, sourceImagePath: first.path);
      if (!mounted) return;
      // 分流（从严到宽，全按后端 / DeepSeek 的结构化答案走，不靠客户端关键词猜）：
      //   ① 抽到化验指标        → 核对页（报告单）
      //   ② imagingType 有值    → 图文报告页（影像），类型已定
      //   ③ isMedical=否 / 无文字 → 无法读取，不存
      //   ④ 其余（是医疗内容但不属于任何已知类型）→ 人工确认页
      if (report.metrics.isNotEmpty) {
        _transferredImageOwnership = true;
        await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ReportReviewPage(
            report: report,
            imageBytes: first.bytes,
            imageFileName: first.fileName,
            initialArea: widget.initialArea,
          ),
        ));
        return;
      }
      if (report.imagingType.isNotEmpty) {
        _transferredImageOwnership = true;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => _buildImagingPage(report)),
        );
        return;
      }
      if (!report.isMedical || report.rawText.trim().isEmpty) {
        AnalyticsEvents.ocrFailed();
        setState(() => _state = _RecogState.failed);
        return;
      }
      // ④ 人工确认
      _pendingReport = report;
      AnalyticsEvents.ocrFailed();
      setState(() => _state = _RecogState.classify);
    } catch (_) {
      // 识别失败不建任何报告记录：失败的空报告只会让档案列表变冗余（用户反馈）。
      // 原图归 dispose 清理（_transferredImageOwnership 仍为 false）。用户可重新识别或手工录入。
      // 隐私：不打印异常内部/数据内容。仅透出安全文案。
      if (mounted) {
        AnalyticsEvents.ocrFailed();
        setState(() {
          _state = _RecogState.failed;
        });
      }
    }
  }

  void _goManual() {
    // C4：普通 push（不替换本页），用户在手动录入页返回时回到失败页，不丢层级。
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
  }

  ImagingReportPage _buildImagingPage(StructuredMedicalReport report,
      {String? typeOverride}) {
    return ImagingReportPage.prefilled(
      image: widget.pages.first,
      ocrText: report.rawText,
      patientName: report.patientName,
      patientGender: report.patientGender,
      patientBirthDate: report.patientBirthDate,
      reportDate: report.dateFromOcr ? report.reportDate : null,
      hospitalName: report.hospitalName,
      reportType: typeOverride ?? report.imagingType,
      initialArea: widget.initialArea,
    );
  }

  // —— 人工确认页的四个动作 ——

  /// 选一个影像类型 → 进图文报告页（影像）。
  Future<void> _classifyPickImaging() async {
    final report = _pendingReport;
    if (report == null) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('这是哪一类？',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final t in kImagingReportTypes)
              ListTile(title: Text(t), onTap: () => Navigator.pop(context, t)),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    _transferredImageOwnership = true;
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => _buildImagingPage(report, typeOverride: picked),
    ));
  }

  /// 「这是化验单」→ 手动录入（DeepSeek 连指标都没抽出来的残件）。
  void _classifyAsLab() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
  }

  /// 存为「未关联记录」：原图 + OCR 文字 + 时间，不挂指标、不关联器官。
  Future<void> _classifySaveUnlinked() async {
    final report = _pendingReport;
    final repo = appRepository;
    if (report == null || repo == null) return;
    try {
      await repo.insertReport(
        hospitalName: report.hospitalName,
        reportDate: report.dateFromOcr ? report.reportDate : DateTime.now(),
        reportType: kUnlinkedReportType,
        sourceImagePath: widget.pages.first.path,
        rawText: report.rawText.trim().isEmpty ? null : report.rawText.trim(),
        recognitionStatus: 'confirmed',
      );
      _transferredImageOwnership = true;
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('已存为未关联记录')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('保存失败：$e')));
      }
    }
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    if (!_transferredImageOwnership) {
      for (final pg in widget.pages) {
        deleteManagedReportImage(pg.path);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('识别报告')),
      body: Center(
        child: _state == _RecogState.loading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                      _pageProgress.isEmpty
                          ? '正在识别报告'
                          : '正在识别报告 · $_pageProgress',
                      style: const TextStyle(
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
            : _state == _RecogState.classify
                ? _ClassifyView(
                    imageBytes: widget.pages.first.bytes,
                    ocrText: _pendingReport?.rawText ?? '',
                    onPickImaging: _classifyPickImaging,
                    onAsLab: _classifyAsLab,
                    onSaveUnlinked: _classifySaveUnlinked,
                    onDiscard: () => Navigator.of(context).pop(),
                  )
                : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text(
                      '这张读不出内容',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '没识别到可用文字，也不像检查报告（可能拍糊了、拍到封面页或无关内容）。'
                      '换报告正文${_canRetry ? '重新识别' : ''}，或返回手工录入。',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    if (_canRetry) ...[
                      IosButton.filled('重新识别',
                          icon: CupertinoIcons.refresh, onPressed: _run),
                      const SizedBox(height: 8),
                    ],
                    IosButton.plain(
                      '手动补充信息',
                      onPressed: _goManual,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// 人工确认页：识别出是医疗内容，但不属于化验单、也匹配不上任何已知影像类型。
/// 显示原图 + 识别文字，用户四选一。
class _ClassifyView extends StatelessWidget {
  final Uint8List imageBytes;
  final String ocrText;
  final VoidCallback onPickImaging;
  final VoidCallback onAsLab;
  final VoidCallback onSaveUnlinked;
  final VoidCallback onDiscard;

  const _ClassifyView({
    required this.imageBytes,
    required this.ocrText,
    required this.onPickImaging,
    required this.onAsLab,
    required this.onSaveUnlinked,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Text('这份不在已知类型里',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('识别出是医疗相关内容，但不是化验单、也匹配不到影像/病历类型。你来定怎么处理。',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(imageBytes,
              height: 200, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        ),
        if (ocrText.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ocrText.trim(),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
        const SizedBox(height: 20),
        IosButton.filled('选一个类型，存为影像/病历',
            icon: CupertinoIcons.doc_text, onPressed: onPickImaging, expand: true),
        const SizedBox(height: 8),
        IosButton.tinted('存为「未关联记录」（原图 + 文字）',
            icon: CupertinoIcons.archivebox,
            onPressed: onSaveUnlinked,
            expand: true),
        const SizedBox(height: 8),
        IosButton.plain('这是化验单 · 转手动录入', onPressed: onAsLab),
        IosButton.plain('丢弃', onPressed: onDiscard, destructive: true),
      ],
    );
  }
}
