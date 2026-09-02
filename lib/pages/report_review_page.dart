import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/health_repository.dart';
import '../main.dart';
import '../widgets/toast.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../widgets/ios_tap.dart';
import '../models/body_area_health.dart';
import '../models/report_models.dart';
import '../services/analytics.dart';
import '../utils/format.dart';
import '../utils/image_storage.dart' show PickedReportImage;
import '../utils/report_image_save.dart';
import '../widgets/current_profile_badge.dart';
import '../widgets/metric_selector.dart';
import 'followup_match.dart';
import 'report_profile_guard.dart';
import 'report_detail_page.dart';
import 'report_recognition_flow.dart';
import 'report_result_page.dart';

/// 报告识别结果确认页：医院/日期/类型可改，指标可编辑、可取消勾选、低置信度提示。
class ReportReviewPage extends StatefulWidget {
  final StructuredMedicalReport report;
  final Uint8List imageBytes;
  final String imageFileName;

  /// 从器官 / 系统详情页 `+` 进来时的「建议关联部位」。保存时并入从指标推导出的
  /// 部位集合一起写进 reportOrgans（即使这份报告的指标本身没落到该部位）。
  final String? initialArea;

  const ReportReviewPage({
    super.key,
    required this.report,
    required this.imageBytes,
    required this.imageFileName,
    this.initialArea,
  });

  @override
  State<ReportReviewPage> createState() => _ReportReviewPageState();
}

class _ReportReviewPageState extends State<ReportReviewPage> {
  late final StructuredMedicalReport _report = widget.report;
  bool _saving = false;
  bool _saved = false;

  /// D7：建议关联的身体部位。默认取上游带进来的 initialArea，用户可在信息卡里改。
  /// null 表示「自动」（保存时仅按指标推导）。
  late String? _area = widget.initialArea != null &&
          coreBodyAreaOrder.contains(widget.initialArea)
      ? widget.initialArea
      : null;

  int get _selectedCount => _report.metrics.where((m) => m.isSelected).length;

  bool get _hasExamContent =>
      _report.examSummary != null && _report.examSummary!.hasSubstance;

  /// 能否保存：勾了化验指标，或是**真的填了内容**的体检报告
  /// （总检结论 / 建议、一般项目数值、或填了字的各科所见）——空白体检表存不了。
  bool get _canSave => _selectedCount > 0 || _hasExamContent;

  /// 勾选保存、但没匹配上核心指标、且超出参考范围的项——存下来但不参与器官
  /// 判定，这里给个提示别让用户以为漏了。
  List<RecognizedMetric> get _nonCoreAbnormal => _report.metrics
      .where((m) =>
          m.isSelected &&
          m.matchedMetricId == null &&
          (m.status.contains('偏高') ||
              m.status.contains('偏低') ||
              m.status.contains('异常') ||
              m.status.contains('关注')))
      .toList();

  /// 「换种方式重新识别」时会把原图交给新的识别页，本页 dispose 不能删它。
  bool _handedOff = false;

  @override
  void dispose() {
    if (!_saved && !_handedOff) {
      deleteManagedReportImage(_report.sourceImagePath);
    }
    super.dispose();
  }

  /// 专用模型把项目名读串了（如读到旁边一列）——用另一条更慢但更稳的
  /// 通用OCR + DeepSeek 链路,拿原图重新识别一遍。
  void _reRecognizeWithDeepseek() {
    _handedOff = true; // 原图交给下一页,别在 dispose 里删
    startReportRecognitionFlowPagesReplacing(
      context,
      [
        PickedReportImage(
          bytes: widget.imageBytes,
          fileName: widget.imageFileName,
          path: _report.sourceImagePath,
        ),
      ],
      initialArea: widget.initialArea,
      preferDeepseek: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return Scaffold(
      appBar: AppBar(title: const Text('核对报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          const CurrentProfileBadge(),
          // 报告信息卡（医院/日期/类型/关联部位 可改）
          HealthCard(
            child: Column(
              children: [
                _InfoField(
                  label: '医院',
                  value: report.hospitalName.isEmpty
                      ? '未填写'
                      : report.hospitalName,
                  onTap: () => _editText('医院', report.hospitalName,
                      (v) => report.hospitalName = v),
                ),
                _InfoField(
                  label: '检查日期',
                  value: formatDate(report.reportDate),
                  onTap: _editDate,
                ),
                _InfoField(
                  label: '报告类型',
                  value: report.reportType.isEmpty
                      ? '未填写'
                      : report.reportType,
                  onTap: () => _editText('报告类型', report.reportType,
                      (v) => report.reportType = v),
                ),
                _InfoField(
                  label: '关联部位',
                  value: _area ?? '自动（按指标）',
                  onTap: _editArea,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 26, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '识别到 ${report.metrics.length} 项指标',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary),
                  ),
                ),
                IosButton.plain('查看原图',
                    icon: CupertinoIcons.photo, onPressed: _viewOriginal),
              ],
            ),
          ),
          for (int i = 0; i < report.metrics.length; i++) ...[
            _MetricEditTile(
              index: i,
              metric: report.metrics[i],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
          ],
          if (_nonCoreAbnormal.isNotEmpty) ...[
            const SizedBox(height: 4),
            _NonCoreAbnormalNote(metrics: _nonCoreAbnormal),
          ],
          if (_hasExamContent) ...[
            const SizedBox(height: 16),
            _ExamSummaryPreview(exam: _report.examSummary!),
          ],
          if (!_saving) ...[
            const SizedBox(height: 8),
            Center(
              child: CupertinoButton(
                onPressed: _reRecognizeWithDeepseek,
                child: const Text(
                  '项目名读得不对？换种方式重新识别（会慢一些）',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_canSave && !_saving)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _report.metrics.isEmpty
                        ? '没识别到可保存的内容，请重拍或换一页'
                        : '请至少勾选一项要保存的指标',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                )
              else if (_selectedCount == 0 && _hasExamContent && !_saving)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '未识别到化验指标，将只保存体检结论 / 各科所见 / 一般项目',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _saving || !_canSave ? null : _save,
                  child: _saving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(color: Colors.white),
                            SizedBox(width: 10),
                            Text('正在保存…', style: TextStyle(fontSize: 16)),
                          ],
                        )
                      : Text(
                          '确认并保存（将保存 $_selectedCount 项指标）',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editText(
      String label, String current, void Function(String) onSave) async {
    final ctrl = TextEditingController(text: current);
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('修改$label'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(controller: ctrl, autofocus: true),
        ),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    // D5：允许清空（保存空字符串），不再强制非空。
    if (result != null) {
      setState(() => onSave(result));
    }
  }

  Future<void> _editDate() async {
    final now = DateTime.now();
    final picked = await pickCupertinoDate(
      context,
      initial: _report.reportDate,
      minimumDate: DateTime(2000),
      maximumDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _report.reportDate = picked);
    }
  }

  /// D7：选择这份报告要关联的身体部位（或「自动」）。
  Future<void> _editArea() async {
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('关联部位'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, ''),
            child: Text(_area == null ? '✓ 自动（按指标推导）' : '自动（按指标推导）'),
          ),
          for (final a in coreBodyAreaOrder)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, a),
              child: Text(_area == a ? '✓ $a' : a),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _area = picked.isEmpty ? null : picked);
  }

  /// 放大查看原始报告图片（便于与识别结果逐项核对）。
  void _viewOriginal() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  widget.imageBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child:
                        Text('无法显示图片', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final repo = appRepository;
    if (repo == null) {
      _toast('数据库未就绪，无法保存');
      return;
    }
    // 家庭成员核对：姓名对不上当前档案则提醒；报告读到的性别/生日可补进档案资料。
    final ok = await guardReportAgainstActiveProfile(
      context,
      ocrPatientName: _report.patientName,
      ocrGender: _report.patientGender,
      ocrBirthDate: _report.patientBirthDate,
    );
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    try {
      final areas = <String>{
        if (_area != null) _area!,
      };
      final savedLines = <SavedMetricLine>[];
      // D2：报告 + 全部指标写在一个事务里，中途失败整体回滚，不留半条报告。
      final exam = _report.examSummary;
      final reportId = await repo.runInTransaction<int>(() async {
        final rid = await repo.insertReport(
          hospitalName: _report.hospitalName,
          reportDate: _report.reportDate,
          reportType: _report.reportType,
          sourceImagePath: _report.sourceImagePath,
          rawText: _report.rawText, // 存库，但不打印到日志
          examSummary: (exam != null && exam.hasSubstance)
              ? jsonEncode(exam.toJson())
              : null,
        );
        // 体检报告的一般项目（血压 / 脉搏 / 体重 / 腰围）→ 日常记录，
        // 于是身体页心血管 / 内分泌代谢也能看到。身高更新到档案资料。
        if (exam != null) {
          await _writeExamGeneral(repo, exam.general, _report.reportDate);
        }
        for (final m in _report.metrics) {
          if (!m.isSelected) continue;
          // 只有匹配上标准指标的才把这份报告关联到对应身体系统；未匹配的不关联
          // （否则会额外带出一个「其他」系统，堆一堆不认识的指标）。
          if (m.matchedMetricId != null) {
            areas.add(bodyAreaForSystem(m.bodySystem));
          }
          savedLines.add(SavedMetricLine(
            metricId: m.matchedMetricId ?? 'UNKNOWN',
            name: m.canonicalName,
            status: m.status,
            value: m.numericValue ?? m.value,
            unit: m.unit,
            bodySystem: m.bodySystem,
          ));
          await repo.insertMetric(
            metricId: m.matchedMetricId ?? 'UNKNOWN',
            metricName: m.canonicalName,
            value: m.numericValue ?? m.value,
            rawValue: _rawValueText(m),
            numericValue: m.numericValue ?? m.value,
            unit: m.unit,
            canonicalValue: m.numericValue ?? m.value,
            canonicalUnit: m.unit.isEmpty ? null : m.unit,
            referenceMin: m.referenceMin,
            referenceMax: m.referenceMax,
            referenceRangeRaw: m.referenceText.isEmpty ? null : m.referenceText,
            sourceAbnormalFlag: m.originalStatus,
            status: m.status,
            bodySystem: m.bodySystem,
            measuredAt: _report.reportDate,
            sourceType: 'report_import',
            rawName: m.rawName.isEmpty ? null : m.rawName,
            matchType: m.matchedMetricId == null ? 'unmatched' : m.matchType,
            recognitionConfidence: m.confidence,
            verificationStatus:
                m.wasEdited ? 'user_modified' : 'user_confirmed',
            notes: _buildNotes(m, rid),
            reportId: rid,
          );
        }
        // 用户确认保存成功 → 报告状态置为 confirmed
        await repo.setReportStatus(rid, 'confirmed');
        // 03：化验单的器官从指标自动推导并显式落表（多器官）。
        if (areas.isNotEmpty) {
          await repo.setReportOrgans(rid, areas);
        }
        return rid;
      });
      _saved = true;
      AnalyticsEvents.ocrCompleted(
          metricCount: savedLines.length, ok: true);
      if (!mounted) return;
      // 03（§17）：可能是某条待复查的结果 → 弹非破坏性关联确认。
      final linkedFollowup = await offerFollowUpLink(
        context,
        reportAreas: areas,
        reportDate: _report.reportDate,
      );
      if (!mounted) return;
      // §11–§12 / §30：不再直接 pop 回列表，而是进「报告整理结果页」。
      // §25：仅在有多个家庭档案时，结果页显示「已保存到：X」。
      String? profileName;
      if (await repo.countPersonProfiles() > 1) {
        profileName = (await repo.getPersonProfile(repo.activeProfileId))
            ?.displayName;
      }
      if ((await repo.getAllReports()).length == 2) {
        AnalyticsEvents.secondReportUploaded();
      }
      if (!mounted) return;
      // 0 项化验的体检报告：结果页那套「识别 N 项 / 正常 M」没意义，直接进详情页
      // （总检结论 / 各科所见 / 一般项目都在那里分块显示）。
      if (savedLines.isEmpty && exam != null && exam.hasSubstance) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ReportDetailPage(reportId: reportId),
        ));
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ReportResultPage(
          reportId: reportId,
          reportType: _report.reportType,
          reportDate: _report.reportDate,
          hospitalName: _report.hospitalName,
          metrics: savedLines,
          areas: areas,
          rawText: _report.rawText,
          dateFromOcr: _report.dateFromOcr,
          savedProfileName: profileName,
          alreadyLinkedFollowup: linkedFollowup,
        ),
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _toast('保存失败，请重试');
      }
    }
  }

  /// 组装入库备注，保留文本型结果 / 定性符号等无法用数值表达的字段。
  String _buildNotes(RecognizedMetric m, int reportId) {
    final parts = <String>[];
    if (m.textValue != null && m.textValue!.isNotEmpty) {
      parts.add('文本结果：${m.textValue}');
    }
    if (m.qualifier != null && m.qualifier!.isNotEmpty) {
      parts.add('定性符：${m.qualifier}');
    }
    if (m.notes != null && m.notes!.isNotEmpty) {
      parts.add(m.notes!);
    }
    final extra = parts.isEmpty ? '' : ' · ${parts.join('；')}';
    return '来自 $reportId 号报告导入$extra';
  }

  String _rawValueText(RecognizedMetric m) {
    if (m.originalTextValue != null && m.originalTextValue!.isNotEmpty) {
      return m.originalTextValue!;
    }
    final value = m.originalNumericValue ?? m.originalValue;
    final numText = _fmt(value);
    return m.originalUnit.isEmpty ? numText : '$numText ${m.originalUnit}';
  }

  void _toast(String msg) {
    showToast(context, msg);
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IosTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(width: 6),
            const Icon(CupertinoIcons.pencil,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// 一条可编辑的识别指标卡片（含复选框 / 低置信度提示 / 点击编辑）
class _MetricEditTile extends StatelessWidget {
  final int index;
  final RecognizedMetric metric;
  final VoidCallback onChanged;

  const _MetricEditTile({
    required this.index,
    required this.metric,
    required this.onChanged,
  });

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'[\s()\-－—_／/]'), '');

  @override
  Widget build(BuildContext context) {
    final lowConfidence = metric.confidence < 0.8;
    final unmatched = metric.matchedMetricId == null;
    final smartMatch =
        metric.matchType == 'deepseek' || metric.matchType == 'cache';
    // 匹配后改了名（智能归一化 / 别名），把报告原名亮出来让用户核对。
    final renamed = metric.matchedMetricId != null &&
        metric.rawName.trim().isNotEmpty &&
        _norm(metric.rawName) != _norm(metric.canonicalName);
    // D3：卡片默认只显示「名称 + 识别值 + 状态」；参考范围 / 所属 / 单位等
    // 细节移进编辑器。只保留会影响用户决策的两个提醒（未匹配 / 低可信度）。
    return HealthCard(
      onTap: () => _edit(context), // D6：整行可点即进编辑
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      child: Row(
        children: [
          IosTap(
            onTap: () {
              metric.isSelected = !metric.isSelected;
              onChanged();
            },
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              metric.isSelected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 24,
              color: metric.isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.canonicalName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_valuesText(metric)} · ${metric.status}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                if (renamed) ...[
                  const SizedBox(height: 3),
                  Text(
                    '报告上写「${metric.rawName.trim()}」'
                    '${smartMatch ? ' · 智能识别，请核对' : ''}',
                    style: TextStyle(
                        fontSize: 12,
                        color: smartMatch
                            ? AppColors.warning
                            : AppColors.textSecondary),
                  ),
                ],
                if (unmatched || lowConfidence) ...[
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (unmatched) '未匹配标准指标',
                      if (lowConfidence) '识别可信度较低，请核对',
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.warning),
                  ),
                ],
                if (metric.statusFromLabFlag) ...[
                  const SizedBox(height: 3),
                  const Text(
                    '按化验单标注判定（参考范围可能未读准）',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valuesText(RecognizedMetric m) {
    String raw = '';
    if (m.numericValue != null) {
      raw = '${m.qualifier ?? ''}${_fmt(m.numericValue!)}';
    } else if (m.textValue != null && m.textValue!.isNotEmpty) {
      raw = m.textValue!;
    } else {
      raw = _fmt(m.value);
    }
    final withUnit = m.unit.isEmpty ? raw : '$raw ${m.unit}';
    return withUnit;
  }

  Future<void> _edit(BuildContext context) async {
    await showMetricEditor(
      context,
      metric,
      needManualMatch: metric.matchedMetricId == null,
    );
    onChanged(); // 编辑器直接 mutate metric，这里刷新 UI
  }
}

/// 弹出指标编辑器（BottomSheet）：可改名称/数值/单位/参考范围/身体系统/勾选匹配指标。
Future<void> showMetricEditor(
  BuildContext context,
  RecognizedMetric metric, {
  required bool needManualMatch,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _MetricEditorSheet(
      metric: metric,
      needManualMatch: needManualMatch,
    ),
  );
}

class _MetricEditorSheet extends StatefulWidget {
  final RecognizedMetric metric;
  final bool needManualMatch;

  const _MetricEditorSheet(
      {required this.metric, required this.needManualMatch});

  @override
  State<_MetricEditorSheet> createState() => _MetricEditorSheetState();
}

class _MetricEditorSheetState extends State<_MetricEditorSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  RecognizedMetric get m => widget.metric;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: m.canonicalName);
    _valueCtrl = TextEditingController(text: _fmt(m.value));
    _unitCtrl = TextEditingController(text: m.unit);
    _minCtrl = TextEditingController(
        text: m.referenceMin == null ? '' : _fmt(m.referenceMin!));
    _maxCtrl = TextEditingController(
        text: m.referenceMax == null ? '' : _fmt(m.referenceMax!));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('编辑识别结果',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            // 若未匹配标准指标，先让用户选择正确指标
            if (m.matchedMetricId == null) ...[
              _smallLabel('匹配标准指标（当前未匹配）'),
              const SizedBox(height: 6),
              IosButton.tinted(
                '从标准指标中选择',
                icon: CupertinoIcons.list_bullet,
                onPressed: () async {
                  final def = await showMetricSelector(context);
                  if (def != null) {
                    setState(() {
                      m.matchedMetricId = def.metricId;
                      m.canonicalName = def.metricName;
                      m.bodySystem = def.bodySystem;
                      m.unit = def.unit;
                      m.wasEdited = true;
                      _nameCtrl.text = def.metricName;
                      _unitCtrl.text = def.unit;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
            _smallLabel('指标名称'),
            CupertinoTextField(controller: _nameCtrl),
            const SizedBox(height: 10),
            _smallLabel('数值'),
            CupertinoTextField(
              controller: _valueCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            _smallLabel('单位'),
            CupertinoTextField(controller: _unitCtrl),
            const SizedBox(height: 10),
            _smallLabel('参考下限（选填）'),
            CupertinoTextField(
              controller: _minCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            _smallLabel('参考上限（选填）'),
            CupertinoTextField(
              controller: _maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            IosButton.filled('应用修改', onPressed: _apply, expand: true),
          ],
        ),
      ),
    );
  }

  Widget _smallLabel(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(s,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      );

  void _apply() {
    final value = double.tryParse(_valueCtrl.text.trim());
    if (value == null) {
      showToast(context, '请输入有效数值');
      return;
    }
    final min = double.tryParse(_minCtrl.text.trim());
    final max = double.tryParse(_maxCtrl.text.trim());
    final newStatus =
        (min != null && max != null) ? _statusFor(value, min, max) : '未判断';

    // 直接 mutate 可变字段，保持外部引用一致
    if (_nameCtrl.text.trim().isNotEmpty) {
      m.canonicalName = _nameCtrl.text.trim();
    }
    m.value = value;
    m.numericValue = value;
    if (_unitCtrl.text.trim().isNotEmpty) {
      m.unit = _unitCtrl.text.trim();
    }
    m.referenceMin = min;
    m.referenceMax = max;
    m.status = newStatus;
    m.wasEdited = true;
    Navigator.pop(context);
  }

  String _statusFor(double v, double min, double max) {
    if (v > max) return '偏高';
    if (v < min) return '偏低';
    return '正常';
  }
}

/// 体检报告核对页：除化验指标外，还带一般项目 / 各科所见 / 总检结论——
/// 这里只读展示，让用户知道这些内容会一并存档（Layer 1 不做逐项编辑）。
class _ExamSummaryPreview extends StatelessWidget {
  final ExamSummary exam;
  const _ExamSummaryPreview({required this.exam});

  @override
  Widget build(BuildContext context) {
    final g = exam.general;
    String n(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    final generalBits = <String>[
      if (g.heightCm != null) '身高 ${n(g.heightCm!)}',
      if (g.weightKg != null) '体重 ${n(g.weightKg!)}',
      if (g.bmi != null) 'BMI ${n(g.bmi!)}',
      if (g.waistCm != null) '腰围 ${n(g.waistCm!)}',
      if (g.systolic != null && g.diastolic != null)
        '血压 ${n(g.systolic!)}/${n(g.diastolic!)}',
      if (g.pulse != null) '脉搏 ${n(g.pulse!)}',
    ];
    return HealthCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('体检报告还包含（会一并存档）',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          if (generalBits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('一般项目：${generalBits.join(' · ')}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const Text('（血压 / 脉搏 / 体重 / 腰围会记入日常记录）',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
          if (exam.departments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('各科所见：${exam.departments.length} 项',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
          if (exam.conclusion != null) ...[
            const SizedBox(height: 8),
            const Text('总检结论',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(exam.conclusion!,
                style: const TextStyle(
                    fontSize: 13, height: 1.4, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// 体检报告「一般项目」里的血压 / 脉搏 / 体重 / 腰围 → 日常记录（同一份 measuredAt）。
/// 身高 / BMI 不入日常记录（不是时间序列），留在 examSummary 里详情页展示。
Future<void> _writeExamGeneral(
    HealthRepository repo, ExamGeneralItems g, DateTime at) async {
  Future<void> add(String type, double v1, double? v2, String unit) =>
      repo.insertDaily(
          type: type, value1: v1, value2: v2, unit: unit, measuredAt: at);
  if (g.systolic != null && g.diastolic != null) {
    await add('blood_pressure', g.systolic!, g.diastolic!, 'mmHg');
  }
  if (g.pulse != null) await add('heart_rate', g.pulse!, null, '次/分');
  if (g.weightKg != null) await add('weight', g.weightKg!, null, 'kg');
  if (g.waistCm != null) await add('waist', g.waistCm!, null, 'cm');
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

/// 「另有 N 项超参考范围（非关键指标）」——默认收起，点开看清单。
class _NonCoreAbnormalNote extends StatefulWidget {
  final List<RecognizedMetric> metrics;
  const _NonCoreAbnormalNote({required this.metrics});

  @override
  State<_NonCoreAbnormalNote> createState() => _NonCoreAbnormalNoteState();
}

class _NonCoreAbnormalNoteState extends State<_NonCoreAbnormalNote> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      onTap: () => setState(() => _open = !_open),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '另有 ${widget.metrics.length} 项超出参考范围（非关键指标）',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ),
              Icon(_open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '会一并存档，可在报告详情里查看；这些项不参与器官判定。',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (_open) ...[
            const SizedBox(height: 8),
            for (final m in widget.metrics)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '· ${m.rawName.trim().isEmpty ? m.canonicalName : m.rawName.trim()}'
                  '  ${m.numericValue == null ? (m.textValue ?? '') : _fmt(m.numericValue!)}'
                  '${m.unit.isEmpty ? '' : ' ${m.unit}'} · ${m.status}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
