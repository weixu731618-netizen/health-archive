import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../data/app_database.dart';
import '../main.dart';
import '../utils/format.dart';

enum DailyEntryType {
  weight('weight', '体重', Icons.monitor_weight_outlined, 'kg'),
  waist('waist', '腰围', Icons.straighten, 'cm'),
  bloodPressure('blood_pressure', '血压', Icons.speed, 'mmHg'),
  bloodGlucose('blood_glucose', '血糖', Icons.water_drop_outlined, 'mmol/L'),
  heartRate('heart_rate', '心率', Icons.favorite_border, 'bpm');

  final String dbType;
  final String label;
  final IconData icon;
  final String defaultUnit;

  const DailyEntryType(this.dbType, this.label, this.icon, this.defaultUnit);
}

/// 日常健康记录入口：四个大按钮，点击进入对应表单。
class DailyHealthEntryPage extends StatelessWidget {
  const DailyHealthEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日常记录')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              '记录体重、腰围、血压、血糖和心率',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          for (final type in DailyEntryType.values) ...[
            _EntryCard(
              type: type,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DailyEntryFormPage(type: type),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final DailyEntryType type;
  final VoidCallback onTap;

  const _EntryCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  type.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单类型日常记录表单
class DailyEntryFormPage extends StatefulWidget {
  final DailyEntryType type;

  const DailyEntryFormPage({super.key, required this.type});

  @override
  State<DailyEntryFormPage> createState() => _DailyEntryFormPageState();
}

class _DailyEntryFormPageState extends State<DailyEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _value1Ctrl = TextEditingController();
  final _value2Ctrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  String _glucoseStatus = '空腹';
  bool _saving = false;
  final List<String> _glucoseOptions = ['空腹', '餐前', '餐后', '睡前', '随机'];

  DailyEntryType get _type => widget.type;

  @override
  void dispose() {
    _value1Ctrl.dispose();
    _value2Ctrl.dispose();
    _hrCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_type.label}记录')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _field(
              label: _type.label == '血压' ? '收缩压' : _type.label,
              unit: _type.defaultUnit,
              controller: _value1Ctrl,
            ),
            if (_type == DailyEntryType.bloodPressure) ...[
              const SizedBox(height: 12),
              _field(
                label: '舒张压',
                unit: 'mmHg',
                controller: _value2Ctrl,
              ),
              const SizedBox(height: 12),
              _field(
                label: '心率（选填）',
                unit: 'bpm',
                controller: _hrCtrl,
              ),
            ],
            if (_type == DailyEntryType.bloodGlucose) ...[
              const SizedBox(height: 12),
              const Text(
                '测量状态',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final opt in _glucoseOptions)
                    ChoiceChip(
                      label: Text(opt),
                      selected: _glucoseStatus == opt,
                      onSelected: (_) => setState(() => _glucoseStatus = opt),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today,
                  color: AppColors.textSecondary),
              title: const Text('测量日期',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              trailing: Text(
                formatDate(_date),
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.access_time, color: AppColors.textSecondary),
              title: const Text('测量时间',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              trailing: Text(
                '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              onTap: _pickTime,
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
              child: const Text('保存记录', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _toDateTime(DateTime date, TimeOfDay t) {
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  Widget _field({
    required String label,
    required String unit,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: '$label（$unit）',
        hintText: '请输入数值',
        suffixText: unit,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        final d = double.tryParse((v ?? '').trim());
        if (d == null) return '请输入有效数字';
        if (d <= 0) return '请输入大于 0 的数值';
        return null;
      },
    );
  }

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return; // 防止重复提交
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = appRepository!;
      final DateTime measured = _toDateTime(_date, _time);

      switch (_type) {
        case DailyEntryType.bloodPressure:
          final hr = int.tryParse(_hrCtrl.text.trim());
          await repo.insertDaily(
            type: _type.dbType,
            value1: double.parse(_value1Ctrl.text.trim()),
            value2: double.parse(_value2Ctrl.text.trim()),
            unit: 'mmHg',
            context: hr == null ? null : '心率 $hr bpm',
            measuredAt: measured,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
        case DailyEntryType.bloodGlucose:
          await repo.insertDaily(
            type: _type.dbType,
            value1: double.parse(_value1Ctrl.text.trim()),
            unit: 'mmol/L',
            context: _glucoseStatus,
            measuredAt: measured,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
        case DailyEntryType.weight:
        case DailyEntryType.waist:
        case DailyEntryType.heartRate:
          await repo.insertDaily(
            type: _type.dbType,
            value1: double.parse(_value1Ctrl.text.trim()),
            unit: _type.defaultUnit,
            measuredAt: measured,
            notes:
                _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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

/// 编辑某条日常记录
class DailyEditPage extends StatefulWidget {
  final DailyHealthRecord record;
  const DailyEditPage({super.key, required this.record});

  @override
  State<DailyEditPage> createState() => _DailyEditPageState();
}

class _DailyEditPageState extends State<DailyEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _value1Ctrl;
  late final TextEditingController _value2Ctrl;
  late final TextEditingController _notesCtrl;
  late DateTime _date;
  late TimeOfDay _time;
  bool _saving = false;

  DailyHealthRecord get _r => widget.record;

  @override
  void initState() {
    super.initState();
    _value1Ctrl = TextEditingController(text: _r.value1.toString());
    _value2Ctrl = TextEditingController(
        text: _r.value2 == null ? '' : _r.value2.toString());
    _notesCtrl = TextEditingController(text: _r.notes ?? '');
    _date = _r.measuredAt;
    _time = TimeOfDay.fromDateTime(_r.measuredAt);
  }

  @override
  void dispose() {
    _value1Ctrl.dispose();
    _value2Ctrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _label {
    switch (_r.type) {
      case 'blood_pressure':
        return '血压';
      case 'blood_glucose':
        return '血糖';
      case 'weight':
        return '体重';
      case 'waist':
        return '腰围';
      case 'heart_rate':
        return '心率';
      default:
        return '日常记录';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBp = _r.type == 'blood_pressure';
    return Scaffold(
      appBar: AppBar(title: Text('编辑$_label')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            TextFormField(
              controller: _value1Ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isBp ? '收缩压（$_unit）' : '$_label（$_unit）',
                suffixText: _unit,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                final d = double.tryParse((v ?? '').trim());
                if (d == null) return '请输入有效数字';
                if (d <= 0) return '请输入大于 0 的数值';
                return null;
              },
            ),
            if (isBp) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _value2Ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '舒张压（$_unit）',
                  suffixText: _r.unit,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  final d = double.tryParse((v ?? '').trim());
                  if (d == null) return '请输入有效数字';
                  if (d <= 0) return '请输入大于 0 的数值';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today,
                  color: AppColors.textSecondary),
              title: const Text('测量日期',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              trailing: Text(formatDate(_date),
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary)),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.access_time, color: AppColors.textSecondary),
              title: const Text('测量时间',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              trailing: Text(
                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary)),
              onTap: _pickTime,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: _input('备注（选填）', '补充说明，可留空'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String get _unit {
    switch (_r.type) {
      case 'blood_glucose':
        return 'mmol/L';
      case 'blood_pressure':
        return 'mmHg';
      case 'weight':
        return 'kg';
      case 'heart_rate':
        return 'bpm';
      default:
        return _r.unit;
    }
  }

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_saving) return; // 防止重复提交
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = appRepository!;
      final dt = DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute);
      final updated = _r.copyWith(
        value1: double.parse(_value1Ctrl.text.trim()),
        value2: _r.type == 'blood_pressure'
            ? drift.Value(double.parse(_value2Ctrl.text.trim()))
            : drift.Value(_r.value2),
        measuredAt: dt,
        notes: drift.Value(
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      );
      await repo.updateDaily(updated);
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
