import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/metric_dictionary.dart';
import '../utils/format.dart';
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
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      '手动添加化验或检查指标',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  // 选择指标（编辑模式禁止更换指标类型，避免数据错乱）
                  _SelectionTile(
                    label: '指标',
                    value: _definition == null
                        ? '请选择'
                        : '${_definition!.metricName}  （${_definition!.bodySystem} · ${_definition!.unit}）',
                    onTap: _isEditing ? _pickMetricBlocked : _pickMetric,
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
                  // 检查日期
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary),
                    title: const Text('检查日期',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textPrimary)),
                    trailing: Text(
                      formatDate(_date),
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textPrimary),
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: _input('备注（选填）', '补充说明，可留空'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : () => _save(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('保存记录',
                        style: TextStyle(fontSize: 16)),
                  ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _pickMetric() async {
    final def = await showMetricSelector(context);
    if (def != null) {
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
          notes: drift.Value(_notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim()),
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

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('保存成功')));
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
