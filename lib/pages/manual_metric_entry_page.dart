import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/metric_dictionary.dart';
import '../utils/format.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../widgets/metric_selector.dart';

/// 手工录入（新增 / 编辑）一条检查指标。
/// - 新增：不传 [metric]
/// - 编辑：传入 [metric]
class ManualMetricEntryPage extends StatefulWidget {
  final HealthMetric? metric;

  const ManualMetricEntryPage({super.key, this.metric});

  @override
  State<ManualMetricEntryPage> createState() => _ManualMetricEntryPageState();
}

class _ManualMetricEntryPageState extends State<ManualMetricEntryPage> {
  final _formKey = GlobalKey<FormState>();

  // 当前选中的指标定义（编辑时从字典反查）
  MetricDefinition? _definition;
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.metric != null;

  @override
  void initState() {
    super.initState();
    final m = widget.metric;
    if (m != null) {
      _definition = findMetricDefinition(m.metricId) ??
          MetricDefinition(
            metricId: m.metricId,
            metricName: m.metricName,
            unit: m.unit,
            bodySystem: m.bodySystem,
          );
      _valueCtrl.text = _fmtNum(m.value);
      _unitCtrl.text = m.unit;
      _minCtrl.text = m.referenceMin == null ? '' : _fmtNum(m.referenceMin!);
      _maxCtrl.text = m.referenceMax == null ? '' : _fmtNum(m.referenceMax!);
      _notesCtrl.text = m.notes ?? '';
      _date = m.measuredAt;
    }
  }

  static String _fmtNum(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HealthRepository? repo = appRepository;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑指标' : '手工录入')),
      body: repo == null
          ? const Center(child: Text('数据库未就绪'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: HealthFieldRow(
                      label: '指标',
                      onTap: _isEditing ? _pickMetricBlocked : _pickMetric,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _definition == null
                                    ? '请选择'
                                    : _definition!.metricName,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: _definition == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_forward,
                                size: 15, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!_isEditing)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        minimumSize: const Size(0, 40),
                        onPressed: _createCustomMetric,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.add_circled, size: 18),
                            SizedBox(width: 6),
                            Text('字典里没有，新增自定义指标'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valueCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _input('检查结果', '例如 6.8'),
                    validator: (v) {
                      final double? d = double.tryParse((v ?? '').trim());
                      if (d == null) return '请输入有效数字';
                      if (d <= 0) return '请输入大于 0 的数值';
                      _lastValue = d;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitCtrl,
                          decoration: _input('单位（可修改）', '例如 %'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _minCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _input('参考下限（选填）', '例如 4.0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _maxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _input('参考上限（选填）', '例如 6.0'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: HealthFieldRow(
                      label: '检查日期',
                      onTap: _pickDate,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(formatDate(_date),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_forward,
                                size: 15, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: _input('备注（选填）', '补充说明，可留空'),
                  ),
                  const SizedBox(height: 24),
                  IosButton.filled('保存记录',
                      onPressed: _saving ? null : () => _save(context),
                      expand: true),
                ],
              ),
            ),
    );
  }

  double? _lastValue;

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F3F5),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickMetric() async {
    final def = await showMetricSelector(context);
    if (def != null) {
      _applyMetricDefinition(def);
    }
  }

  void _applyMetricDefinition(MetricDefinition def) {
    setState(() {
      _definition = def;
      _unitCtrl.text = def.unit;
      if (_minCtrl.text.isEmpty && def.typicalRange.min != null) {
        _minCtrl.text = _fmtNum(def.typicalRange.min!);
      }
      if (_maxCtrl.text.isEmpty && def.typicalRange.max != null) {
        _maxCtrl.text = _fmtNum(def.typicalRange.max!);
      }
    });
  }

  Future<void> _createCustomMetric() async {
    final def = await showDialog<MetricDefinition>(
      context: context,
      builder: (_) => const _CustomMetricDialog(),
    );

    if (def != null) {
      _applyMetricDefinition(def);
    }
  }

  /// 编辑模式下点击指标选择项的提示：不允许更换指标类型
  void _pickMetricBlocked() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('编辑时不支持更换指标类型，请删除后重新新增')),
      );
  }

  Future<void> _pickDate() async {
    final picked = await pickCupertinoDate(context, initial: _date, minimumDate: DateTime(2015), maximumDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return; // 防止重复提交
    if (_definition == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('请先选择指标')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = appRepository!;
      final double value = _lastValue!;
      final double? min = double.tryParse(_minCtrl.text.trim());
      final double? max = double.tryParse(_maxCtrl.text.trim());
      final range = (min != null && max != null)
          ? ReferenceRange(min: min, max: max)
          : null;
      final status = computeStatus(value, range);

      final metrics = _isEditing ? widget.metric! : null;
      if (metrics != null) {
        // 编辑
        final updated = metrics.copyWith(
          value: value,
          unit: _unitCtrl.text.trim().isEmpty
              ? metrics.unit
              : _unitCtrl.text.trim(),
          referenceMin: drift.Value(min),
          referenceMax: drift.Value(max),
          status: status,
          measuredAt: _date,
          notes: drift.Value(
              _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        );
        await repo.updateMetric(updated);
      } else {
        // 新增
        await repo.insertMetric(
          metricId: _definition!.metricId,
          metricName: _definition!.metricName,
          value: value,
          unit: _unitCtrl.text.trim().isEmpty
              ? _definition!.unit
              : _unitCtrl.text.trim(),
          referenceMin: min,
          referenceMax: max,
          status: status,
          bodySystem: _definition!.bodySystem,
          measuredAt: _date,
          sourceType: 'manual',
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('保存成功')));
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CustomMetricDialog extends StatefulWidget {
  const _CustomMetricDialog();

  @override
  State<_CustomMetricDialog> createState() => _CustomMetricDialogState();
}

class _CustomMetricDialogState extends State<_CustomMetricDialog> {
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _systemCtrl = TextEditingController(text: '其他');
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _systemCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入指标名称');
      return;
    }
    if (_systemCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入分类');
      return;
    }
    Navigator.pop(
      context,
      MetricDefinition(
        metricId: 'CUSTOM_${DateTime.now().microsecondsSinceEpoch}',
        metricName: _nameCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        bodySystem: _systemCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('新增自定义指标'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          CupertinoTextField(controller: _nameCtrl, placeholder: '指标名称（如 C反应蛋白）'),
          const SizedBox(height: 8),
          CupertinoTextField(controller: _unitCtrl, placeholder: '单位（如 mg/L，可留空）'),
          const SizedBox(height: 8),
          CupertinoTextField(controller: _systemCtrl, placeholder: '分类（如 炎症、肾脏、其他）'),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!,
                style: const TextStyle(
                    fontSize: 12, color: CupertinoColors.destructiveRed)),
          ],
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _submit,
          child: const Text('添加'),
        ),
      ],
    );
  }
}
