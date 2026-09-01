import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/body_area_health.dart';
import '../models/report_models.dart';
import '../services/analytics.dart';
import '../utils/format.dart';
import '../utils/report_image_save.dart';
import '../widgets/current_profile_badge.dart';
import '../widgets/metric_selector.dart';
import 'followup_match.dart';
import 'report_profile_guard.dart';
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

  @override
  void dispose() {
    if (!_saved) {
      deleteManagedReportImage(_report.sourceImagePath);
    }
    super.dispose();
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoField(
                    label: '医院',
                    value: report.hospitalName.isEmpty
                        ? '未填写'
                        : report.hospitalName,
                    icon: Icons.local_hospital_outlined,
                    onTap: () => _editText('医院', report.hospitalName,
                        (v) => report.hospitalName = v),
                  ),
                  const Divider(height: 20),
                  _InfoField(
                    label: '检查日期',
                    value: formatDate(report.reportDate),
                    icon: Icons.calendar_today,
                    onTap: _editDate,
                  ),
                  const Divider(height: 20),
                  _InfoField(
                    label: '报告类型',
                    value: report.reportType.isEmpty
                        ? '未填写'
                        : report.reportType,
                    icon: Icons.description_outlined,
                    onTap: () => _editText('报告类型', report.reportType,
                        (v) => report.reportType = v),
                  ),
                  const Divider(height: 20),
                  _InfoField(
                    label: '关联部位',
                    value: _area ?? '自动（按指标）',
                    icon: Icons.account_tree_outlined,
                    onTap: _editArea,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '识别到 ${report.metrics.length} 项指标',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: _viewOriginal,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('查看原图'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < report.metrics.length; i++) ...[
            _MetricEditTile(
              index: i,
              metric: report.metrics[i],
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedCount == 0 && !_saving)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '请至少勾选一项要保存的指标',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              FilledButton(
                onPressed: _saving || _selectedCount == 0 ? null : _save,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                child: _saving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text('正在保存…', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Text(
                        '确认并保存（将保存 $_selectedCount 项指标）',
                        style: const TextStyle(fontSize: 16),
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
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('修改$label'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _report.reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _report.reportDate = picked);
    }
  }

  /// D7：选择这份报告要关联的身体部位（或「自动」）。
  Future<void> _editArea() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('自动（按指标推导）'),
              trailing: _area == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, ''),
            ),
            const Divider(height: 1),
            for (final a in coreBodyAreaOrder)
              ListTile(
                title: Text(a),
                trailing: _area == a ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, a),
              ),
          ],
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
                icon: const Icon(Icons.close, color: Colors.white),
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
      final reportId = await repo.runInTransaction<int>(() async {
        final rid = await repo.insertReport(
          hospitalName: _report.hospitalName,
          reportDate: _report.reportDate,
          reportType: _report.reportType,
          sourceImagePath: _report.sourceImagePath,
          rawText: _report.rawText, // 存库，但不打印到日志
        );
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _InfoField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          const Icon(Icons.edit_outlined,
              size: 18, color: AppColors.textSecondary),
        ],
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

  @override
  Widget build(BuildContext context) {
    final lowConfidence = metric.confidence < 0.8;
    final unmatched = metric.matchedMetricId == null;
    // D3：卡片默认只显示「名称 + 识别值 + 状态」；参考范围 / 所属 / 单位等
    // 细节移进编辑器。只保留会影响用户决策的两个提醒（未匹配 / 低可信度）。
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _edit(context), // D6：整行可点即进编辑
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            children: [
              Checkbox(
                value: metric.isSelected,
                onChanged: (v) {
                  metric.isSelected = v ?? false;
                  onChanged();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metric.canonicalName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_valuesText(metric)} · ${metric.status}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
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
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
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
              OutlinedButton.icon(
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
                icon: const Icon(Icons.rule),
                label: const Text('从标准指标中选择'),
              ),
              const SizedBox(height: 12),
            ],
            _smallLabel('指标名称'),
            TextField(controller: _nameCtrl),
            const SizedBox(height: 10),
            _smallLabel('数值'),
            TextField(
              controller: _valueCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            _smallLabel('单位'),
            TextField(controller: _unitCtrl),
            const SizedBox(height: 10),
            _smallLabel('参考下限（选填）'),
            TextField(
              controller: _minCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            _smallLabel('参考上限（选填）'),
            TextField(
              controller: _maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _apply,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: const Text('应用修改'),
            ),
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请输入有效数值')));
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

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
