import 'package:drift/drift.dart' as drift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
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
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('删除「${a.substance}」这条过敏记录？'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          CupertinoDialogAction(
              isDestructiveAction: true,
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
      appBar: AppBar(
        title: const Text('过敏史'),
        actions: [
          IconButton(
            tooltip: '新增',
            icon: const Icon(CupertinoIcons.add),
            onPressed: () => _addOrEdit(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('暂无过敏史，点右上角 + 添加',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    for (final a in _items) ...[
                      _allergyCard(a),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
    );
  }

  Widget _allergyCard(Allergy a) {
    final sub = <String>[
      a.category,
      if ((a.reaction ?? '').isNotEmpty) '表现：${a.reaction}',
      '严重度：${a.severity}',
      if (a.notedDate != null) '记录于 ${formatDate(a.notedDate!)}',
      if ((a.notes ?? '').isNotEmpty) a.notes!,
    ].join(' · ');
    return HealthCard(
      onTap: () => _addOrEdit(a),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle,
              size: 22,
              color:
                  a.severity == '重' ? AppColors.abnormal : AppColors.warning),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.substance,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(0, 0),
            onPressed: () => _delete(a),
            child: const Icon(CupertinoIcons.delete,
                size: 20, color: AppColors.abnormal),
          ),
        ],
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            HealthCard(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                children: [
                  HealthFieldRow(
                    label: '过敏原',
                    child: TextFormField(
                      controller: _substanceCtrl,
                      decoration: _input('青霉素、海鲜、花粉…'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入过敏原' : null,
                    ),
                  ),
                  HealthFieldRow(
                    label: '表现',
                    child: TextFormField(
                      controller: _reactionCtrl,
                      decoration: _input('皮疹、呼吸困难…（选填）'),
                    ),
                  ),
                  HealthFieldRow(
                    label: '记录日期',
                    onTap: _pickDate,
                    child: _rowValue(
                        _notedDate == null ? '未填' : formatDate(_notedDate!)),
                  ),
                  HealthFieldRow(
                    label: '备注',
                    child: TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: _input('选填'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _MiniLabel('类别'),
            ChoicePills(
              options: _categories,
              value: _category,
              toggle: false,
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 14),
            const _MiniLabel('严重程度'),
            ChoicePills(
              options: _severities,
              value: _severity,
              toggle: false,
              onChanged: (v) => setState(() => _severity = v ?? _severity),
            ),
            const SizedBox(height: 24),
            IosButton.filled('保存', onPressed: _save, expand: true),
          ],
        ),
      ),
    );
  }

  Widget _rowValue(String v) => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(v,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_forward,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      );

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await pickCupertinoDate(context, initial: _notedDate ?? DateTime.now(), minimumDate: DateTime(1980), maximumDate: DateTime.now(),
    );
    if (picked != null) setState(() => _notedDate = picked);
  }

  InputDecoration _input(String hint) => InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      );
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      );
}
