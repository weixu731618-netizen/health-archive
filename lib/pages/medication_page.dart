import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../utils/format.dart';

/// 用药记录页（MVP）：真实可增删改存。
class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<Medication> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final repo = appRepository;
    if (repo != null) {
      final list = await repo.getAllMedications();
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addOrEdit([Medication? existing]) async {
    final r = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _MedicationEditPage(medication: existing)),
    );
    if (r == true) _load();
  }

  Future<void> _delete(Medication m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条用药记录？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = appRepository;
    if (repo != null) {
      await repo.deleteMedication(m.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用药记录')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('暂无用药记录，点击右下角 + 添加',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final m = _items[i];
                    final detail = [
                      if (m.dosage != null)
                        '${m.dosage}${m.dosageUnit ?? ''}'
                      else if (m.dosageUnit != null)
                        m.dosageUnit!,
                      if (m.timesPerDay != null) '每日 ${m.timesPerDay ?? ''} 次',
                      if (m.startDate != null) '起 ${formatDate(m.startDate!)}',
                      if (m.endDate != null) '止 ${formatDate(m.endDate!)}',
                    ].join(' · ');
                    return Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(m.name, style: const TextStyle(fontSize: 15)),
                        subtitle: Text(
                          '${m.status}${detail.isEmpty ? '' : ' · $detail'}'
                          '${(m.notes ?? '').isEmpty ? '' : ' · ${m.notes}'}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        onTap: () => _addOrEdit(m),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.abnormal),
                          onPressed: () => _delete(m),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _MedicationEditPage extends StatefulWidget {
  final Medication? medication;
  const _MedicationEditPage({this.medication});

  @override
  State<_MedicationEditPage> createState() => _MedicationEditPageState();
}

class _MedicationEditPageState extends State<_MedicationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _timesCtrl;
  late final TextEditingController _notesCtrl;
  late String _status = '当前使用';
  DateTime? _start;
  DateTime? _end;

  bool get _isEdit => widget.medication != null;

  static const List<String> _options = ['当前使用', '已停用'];

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _dosageCtrl = TextEditingController(text: m?.dosage ?? '');
    _unitCtrl = TextEditingController(text: m?.dosageUnit ?? '');
    _timesCtrl = TextEditingController(text: m?.timesPerDay ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _status = m?.status ?? '当前使用';
    _start = m?.startDate;
    _end = m?.endDate;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _dosageCtrl, _unitCtrl, _timesCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final repo = appRepository;
    if (repo == null) return;
    if (_isEdit) {
      final m = widget.medication!;
      final updated = m.copyWith(
        name: name,
        dosage: drift.Value(_dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim()),
        dosageUnit: drift.Value(_unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim()),
        timesPerDay: drift.Value(_timesCtrl.text.trim().isEmpty ? null : _timesCtrl.text.trim()),
        startDate: drift.Value(_start),
        endDate: drift.Value(_end),
        status: _status,
        notes: drift.Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      );
      await repo.updateMedication(updated);
    } else {
      await repo.insertMedication(
        name: name,
        dosage: _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        dosageUnit: _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        timesPerDay: _timesCtrl.text.trim().isEmpty ? null : _timesCtrl.text.trim(),
        startDate: _start,
        endDate: _end,
        status: _status,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑用药' : '新增用药')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: _input('药物名称'),
              validator: (v) => (v == null || v.trim().isEmpty) ? '请输入药物名称' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _dosageCtrl, decoration: _input('剂量'))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _unitCtrl, decoration: _input('单位'))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _timesCtrl, decoration: _input('每日次数'))),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
              title: const Text('开始日期'),
              trailing: Text(_start == null ? '未填' : formatDate(_start!),
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              onTap: () async {
                final p = await showDatePicker(
                    context: context,
                    initialDate: _start ?? DateTime.now(),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                if (p != null) setState(() => _start = p);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy, color: AppColors.textSecondary),
              title: const Text('结束日期（选填）'),
              trailing: Text(_end == null ? '未填' : formatDate(_end!),
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              onTap: () async {
                final p = await showDatePicker(
                    context: context,
                    initialDate: _end ?? _start ?? DateTime.now(),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)));
                if (p != null) setState(() => _end = p);
              },
            ),
            TextFormField(controller: _notesCtrl, maxLines: 2, decoration: _input('备注（选填）')),
            const SizedBox(height: 12),
            const Text('用药状态',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final o in _options)
                  ChoiceChip(
                    label: Text(o),
                    selected: _status == o,
                    onSelected: (_) => setState(() => _status = o),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
