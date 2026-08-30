import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../utils/format.dart';

/// 慢病升级 步骤5：过敏史页（独立字段，不再塞进疾病史备注）。
class AllergyPage extends StatefulWidget {
  const AllergyPage({super.key});

  @override
  State<AllergyPage> createState() => _AllergyPageState();
}

class _AllergyPageState extends State<AllergyPage> {
  List<Allergy> _items = [];
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
      final list = await repo.getAllAllergies();
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

  Future<void> _addOrEdit([Allergy? existing]) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _AllergyEditPage(allergy: existing)),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(Allergy a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除「${a.substance}」这条过敏记录？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    await appRepository?.deleteAllergy(a.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('过敏史')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('暂无过敏史，点击右下角 + 添加',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final a = _items[i];
                    final sub = <String>[
                      a.category,
                      if ((a.reaction ?? '').isNotEmpty) '表现：${a.reaction}',
                      '严重度：${a.severity}',
                      if (a.notedDate != null)
                        '记录于 ${formatDate(a.notedDate!)}',
                      if ((a.notes ?? '').isNotEmpty) a.notes!,
                    ].join(' · ');
                    return Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        leading: Icon(
                          Icons.warning_amber_outlined,
                          color: a.severity == '重'
                              ? AppColors.abnormal
                              : AppColors.warning,
                        ),
                        title: Text(a.substance,
                            style: const TextStyle(fontSize: 15)),
                        subtitle: Text(sub,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        onTap: () => _addOrEdit(a),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.abnormal),
                          onPressed: () => _delete(a),
                        ),
                        isThreeLine: sub.length > 26,
                      ),
                    );
                  },
                ),
    );
  }
}

class _AllergyEditPage extends StatefulWidget {
  final Allergy? allergy;
  const _AllergyEditPage({this.allergy});

  @override
  State<_AllergyEditPage> createState() => _AllergyEditPageState();
}

class _AllergyEditPageState extends State<_AllergyEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _substanceCtrl;
  late final TextEditingController _reactionCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late String _severity;
  DateTime? _notedDate;

  bool get _isEdit => widget.allergy != null;

  static const _categories = ['药物', '食物', '环境', '其他'];
  static const _severities = ['轻', '中', '重', '不确定'];

  @override
  void initState() {
    super.initState();
    final a = widget.allergy;
    _substanceCtrl = TextEditingController(text: a?.substance ?? '');
    _reactionCtrl = TextEditingController(text: a?.reaction ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _category = a?.category ?? '药物';
    _severity = a?.severity ?? '不确定';
    _notedDate = a?.notedDate;
  }

  @override
  void dispose() {
    _substanceCtrl.dispose();
    _reactionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = appRepository;
    if (repo == null) return;
    final substance = _substanceCtrl.text.trim();
    final reaction =
        _reactionCtrl.text.trim().isEmpty ? null : _reactionCtrl.text.trim();
    final notes =
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    if (_isEdit) {
      await repo.updateAllergy(widget.allergy!.copyWith(
        substance: substance,
        category: _category,
        reaction: drift.Value(reaction),
        severity: _severity,
        notedDate: drift.Value(_notedDate),
        notes: drift.Value(notes),
      ));
    } else {
      await repo.insertAllergy(
        substance: substance,
        category: _category,
        reaction: reaction,
        severity: _severity,
        notedDate: _notedDate,
        notes: notes,
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑过敏史' : '新增过敏史')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _substanceCtrl,
              decoration: _input('过敏原（如：青霉素、海鲜、花粉）'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入过敏原' : null,
            ),
            const SizedBox(height: 12),
            const Text('类别',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final c in _categories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reactionCtrl,
              decoration: _input('过敏表现（如：皮疹、呼吸困难）（选填）'),
            ),
            const SizedBox(height: 12),
            const Text('严重程度',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final s in _severities)
                  ChoiceChip(
                    label: Text(s),
                    selected: _severity == s,
                    onSelected: (_) => setState(() => _severity = s),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today,
                  color: AppColors.textSecondary),
              title: const Text('记录日期（选填）'),
              trailing: Text(
                _notedDate == null ? '未填' : formatDate(_notedDate!),
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _notedDate ?? DateTime.now(),
                  firstDate: DateTime(1980),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _notedDate = picked);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: _input('备注（选填）'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
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
