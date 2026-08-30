import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/body_area_health.dart';
import '../models/report_models.dart';
import '../utils/format.dart';
import '../utils/report_image_save.dart';
import '../widgets/metric_selector.dart';
import 'followup_match.dart';

/// 报告识别结果确认页：医院/日期/类型可改，指标可编辑、可取消勾选、低置信度提示。
class ReportReviewPage extends StatefulWidget {
  final StructuredMedicalReport report;
  final Uint8List imageBytes;
  final String imageFileName;

  const ReportReviewPage({
    super.key,
    required this.report,
    required this.imageBytes,
    required this.imageFileName,
  });

  @override
  State<ReportReviewPage> createState() => _ReportReviewPageState();
}

class _ReportReviewPageState extends State<ReportReviewPage> {
  late final StructuredMedicalReport _report = widget.report;
  bool _saving = false;
  bool _saved = false;

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
      appBar: AppBar(title: const Text('确认识别结果')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          // 报告信息卡（医院/日期/类型 可改）
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoField(
                    label: '医院',
                    value: report.hospitalName,
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
                    value: report.reportType,
                    icon: Icons.description_outlined,
                    onTap: () => _editText('报告类型', report.reportType,
                        (v) => report.reportType = v),
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
          child: FilledButton(
            onPressed: _saving || _selectedCount == 0 ? null : _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
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
    if (result != null && result.isNotEmpty) {
      setState(() => onSave(result));
    }
  }

  Future<void> _editDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _report.reportDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _report.reportDate = picked);
    }
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
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
    setState(() => _saving = true);
    try {
      final reportId = await repo.insertReport(
        hospitalName: _report.hospitalName,
        reportDate: _report.reportDate,
        reportType: _report.reportType,
        sourceImagePath: _report.sourceImagePath,
        rawText: _report.rawText, // 存库，但不打印到日志
      );
      final areas = <String>{};
      for (final m in _report.metrics) {
        if (!m.isSelected) continue;
        areas.add(bodyAreaForSystem(m.bodySystem));
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
          verificationStatus: m.wasEdited ? 'user_modified' : 'user_confirmed',
          notes: _buildNotes(m, reportId),
          reportId: reportId,
        );
      }
      // 用户确认保存成功 → 报告状态置为 confirmed
      await repo.setReportStatus(reportId, 'confirmed');
      // 03：化验单的器官从指标自动推导并显式落表（多器官）。
      if (areas.isNotEmpty) {
        await repo.setReportOrgans(reportId, areas);
      }
      _saved = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('保存成功')));
      // 03（§17）：可能是某条待复查的结果 → 弹非破坏性关联确认。
      await offerFollowUpLink(
        context,
        reportAreas: areas,
        reportDate: _report.reportDate,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  if (metric.rawName.isNotEmpty &&
                      metric.rawName != metric.canonicalName) ...[
                    const SizedBox(height: 2),
                    Text(
                      '原报告：${metric.rawName}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _valuesText(metric),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  Text(
                    '参考范围：${metric.referenceMin == null ? '—' : _fmt(metric.referenceMin!)} – ${metric.referenceMax == null ? '—' : _fmt(metric.referenceMax!)}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  Text(
                    '状态：${metric.status} · 所属：${metric.bodySystem}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  // 匹配状态 + 字段缺失提示
                  _matchStatusLine(metric),
                  if (metric.unit.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text('单位未识别',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.warning)),
                    ),
                  if (metric.referenceMin == null &&
                      metric.referenceMax == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text('参考范围未识别',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.warning)),
                    ),
                  if (metric.matchedMetricId == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        '未匹配标准指标',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.insufficient),
                      ),
                    ),
                  if (lowConfidence)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 15, color: AppColors.warning),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '⚠ 识别可信度较低，请核对原报告',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary),
              onPressed: () => _edit(context),
            ),
          ],
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
    return '识别结果：$withUnit';
  }

  Widget _matchStatusLine(RecognizedMetric m) {
    final String label;
    final Color color;
    switch (m.matchType) {
      case 'exact':
      case 'alias':
        label = '已匹配';
        color = AppColors.normal;
      case 'ai_suggested':
        label = '建议匹配（请核对）';
        color = AppColors.warning;
      default:
        label = '未匹配';
        color = AppColors.insufficient;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
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
