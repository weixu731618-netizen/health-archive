import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../utils/format.dart';

/// 疾病史页（MVP）：真实可增删改存。
class ConditionPage extends StatefulWidget {
  const ConditionPage({super.key});

  @override
  State<ConditionPage> createState() => _ConditionPageState();
}

class _ConditionPageState extends State<ConditionPage> {
  List<Disease> _diseases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (mounted) setState(() => _loading = true);
    if (repo != null) {
      final list = await repo.getAllDiseases();
      if (mounted) {
        setState(() {
          _diseases = list;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addOrEdit([Disease? existing]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _DiseaseEditPage(disease: existing)),
    );
    if (result == true) _load();
  }

  Future<void> _delete(Disease d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条疾病史？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = appRepository;
    if (repo != null) {
      await repo.deleteDisease(d.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('疾病史')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _diseases.isEmpty
              ? const Center(
                  child: Text('暂无疾病史，点击右下角 + 添加',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: _diseases.length,
                  itemBuilder: (_, i) {
                    final d = _diseases[i];
                    return Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(d.name, style: const TextStyle(fontSize: 15)),
                        subtitle: Text(
                          '状态：${d.status}'
                          '${d.foundDate == null ? '' : ' · 发现于 ${formatDate(d.foundDate!)}'}'
                          '${(d.notes ?? '').isEmpty ? '' : ' · ${d.notes}'}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        onTap: () => _addOrEdit(d),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.abnormal),
                          onPressed: () => _delete(d),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _DiseaseEditPage extends StatefulWidget {
  final Disease? disease;
  const _DiseaseEditPage({this.disease});

  @override
  State<_DiseaseEditPage> createState() => _DiseaseEditPageState();
}

class _DiseaseEditPageState extends State<_DiseaseEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late String _status = '不确定';
  DateTime? _foundDate;

  bool get _isEdit => widget.disease != null;

  static const List<String> _options = ['当前存在', '已恢复', '不确定'];

  @override
  void initState() {
    super.initState();
    final d = widget.disease;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _notesCtrl = TextEditingController(text: d?.notes ?? '');
    _status = d?.status ?? '不确定';
    _foundDate = d?.foundDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final repo = appRepository;
    if (repo == null) return;
    if (_isEdit) {
      final d = widget.disease!;
      final updated = d.copyWith(
        name: name,
        foundDate: drift.Value(_foundDate),
        status: _status,
        notes: drift.Value(_notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim()),
      );
      await repo.updateDisease(updated);
    } else {
      await repo.insertDisease(
        name: name,
        foundDate: _foundDate,
        status: _status,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑疾病' : '新增疾病')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: _input('疾病名称'),
              validator: (v) => (v == null || v.trim().isEmpty) ? '请输入疾病名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: _input('备注（选填）'),
            ),
            const SizedBox(height: 12),
            const Text('当前状态',
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
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
              title: const Text('首次发现日期'),
              trailing: Text(
                _foundDate == null ? '未填' : formatDate(_foundDate!),
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _foundDate ?? DateTime.now(),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _foundDate = picked);
              },
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
