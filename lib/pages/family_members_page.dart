import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../utils/format.dart';
import '../utils/report_image_save.dart';

/// B1：家庭成员管理。列出「本人 + 家庭成员」，可切换当前档案、新增 / 编辑 / 删除成员。
class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

/// 关系可选项（「本人」固定，不在此列）。存的就是这里的中文。
const List<String> kMemberRelationships = [
  '配偶',
  '父亲',
  '母亲',
  '儿子',
  '女儿',
  '其他',
];

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  List<PersonProfile> _people = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) {
      setState(() => _loading = false);
      return;
    }
    final people = await repo.getAllPersonProfiles();
    if (mounted) {
      setState(() {
        _people = people;
        _loading = false;
      });
    }
  }

  int get _activeId => appRepository?.activeProfileId ?? 1;

  Future<void> _switchTo(PersonProfile p) async {
    if (_busy) return;
    await switchActiveProfile(p.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _addMember() async {
    final data = await showModalBottomSheet<_MemberFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MemberFormSheet(),
    );
    if (data == null) return;
    final repo = appRepository;
    if (repo == null) return;
    setState(() => _busy = true);
    try {
      await repo.insertPersonProfile(
        displayName: data.name,
        relationship: data.relationship,
        sex: data.sex,
        dateOfBirth: data.birth,
        heightCm: data.heightCm,
      );
      await _load();
      if (mounted) _toast('已添加');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editMember(PersonProfile p) async {
    final data = await showModalBottomSheet<_MemberFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MemberFormSheet(existing: p),
    );
    if (data == null) return;
    final repo = appRepository;
    if (repo == null) return;
    setState(() => _busy = true);
    try {
      await repo.updatePersonProfileFields(
        p.id,
        displayName: data.name,
        relationship: p.id == HealthRepository.defaultProfileId
            ? null
            : data.relationship,
        sex: data.sex,
        dateOfBirth: data.birth,
        heightCm: data.heightCm,
      );
      await _load();
      // 改的是当前档案时，通知各页面刷新显示的名字。
      if (p.id == _activeId) activeProfileNotifier.value = _activeId;
      if (mounted) _toast('已保存');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteMember(PersonProfile p) async {
    final repo = appRepository;
    if (repo == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除「${p.displayName}」'),
        content: const Text('将删除该成员的全部报告、指标、日常记录、疾病史和用药记录，且无法恢复。是否继续？'),
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
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      // 先收集该成员报告原图路径，级联删除后清理磁盘文件。
      final imagePaths = await repo.listReportImagePathsForProfile(p.id);
      await repo.deletePersonProfileCascade(p.id);
      for (final path in imagePaths) {
        await deleteManagedReportImage(path);
      }
      // 删的可能是当前档案：仓库已回落到「本人」，同步通知 UI。
      activeProfileNotifier.value = repo.activeProfileId;
      await _load();
      if (mounted) _toast('已删除');
    } catch (e) {
      if (mounted) _toast('删除失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  String _relationshipLabel(PersonProfile p) =>
      p.id == HealthRepository.defaultProfileId ? '本人' : p.relationship;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家庭成员')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '每个成员的报告和健康数据相互独立。点选一个成员即可切换当前查看的档案。',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                for (final p in _people) _memberTile(p),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _addMember,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('添加家庭成员'),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ],
            ),
    );
  }

  Widget _memberTile(PersonProfile p) {
    final isActive = p.id == _activeId;
    final isSelf = p.id == HealthRepository.defaultProfileId;
    final subtitleParts = <String>[
      _relationshipLabel(p),
      if ((p.sex ?? '').isNotEmpty) p.sex!,
      if (p.dateOfBirth != null) formatDate(p.dateOfBirth!),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: _busy ? null : () => _switchTo(p),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            p.displayName.isNotEmpty ? p.displayName.characters.first : '?',
            style: TextStyle(
                color: isActive ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
        ),
        title: Row(
          children: [
            Flexible(
                child: Text(p.displayName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600))),
            if (isActive) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  size: 18, color: AppColors.primary),
            ],
          ],
        ),
        subtitle: Text(subtitleParts.join(' · '),
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _editMember(p);
            if (v == 'delete') _deleteMember(p);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑资料')),
            if (!isSelf)
              const PopupMenuItem(value: 'delete', child: Text('删除该成员')),
          ],
        ),
      ),
    );
  }
}

class _MemberFormResult {
  final String name;
  final String relationship;
  final String? sex;
  final DateTime? birth;
  final double? heightCm;
  const _MemberFormResult(
      this.name, this.relationship, this.sex, this.birth, this.heightCm);
}

class _MemberFormSheet extends StatefulWidget {
  final PersonProfile? existing;
  const _MemberFormSheet({this.existing});

  @override
  State<_MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<_MemberFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _heightCtrl;
  late String _relationship;
  String _sex = '';
  DateTime? _birth;

  bool get _isSelf => widget.existing?.id == HealthRepository.defaultProfileId;

  static const List<String> _sexes = ['男', '女'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.displayName ?? '');
    _heightCtrl = TextEditingController(
        text: e?.heightCm == null ? '' : _fmtHeight(e!.heightCm!));
    _relationship = e == null || e.id == HealthRepository.defaultProfileId
        ? kMemberRelationships.first
        : (kMemberRelationships.contains(e.relationship)
            ? e.relationship
            : kMemberRelationships.last);
    _sex = e?.sex ?? '';
    _birth = e?.dateOfBirth;
  }

  static String _fmtHeight(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.existing == null ? '添加家庭成员' : (_isSelf ? '编辑「本人」资料' : '编辑成员资料');
    return Padding(
      // 键盘弹起时把内容整体上推，避免遮挡输入框。
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '称呼 / 姓名'),
              ),
              if (!_isSelf) ...[
                const SizedBox(height: 16),
                const Text('关系',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final r in kMemberRelationships)
                      ChoiceChip(
                        label: Text(r),
                        selected: _relationship == r,
                        onSelected: (_) => setState(() => _relationship = r),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Text('性别',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in _sexes)
                    ChoiceChip(
                      label: Text(s),
                      selected: _sex == s,
                      onSelected: (v) => setState(() => _sex = v ? s : ''),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cake_outlined,
                    color: AppColors.textSecondary),
                title: const Text('出生日期'),
                trailing: Text(_birth == null ? '未填' : formatDate(_birth!),
                    style: const TextStyle(fontSize: 15)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birth ?? DateTime(1990),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birth = picked);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _heightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '身高（选填）',
                  suffixText: 'cm',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                          const SnackBar(content: Text('请填写称呼 / 姓名')));
                    return;
                  }
                  Navigator.of(context).pop(_MemberFormResult(
                    name,
                    _relationship,
                    _sex.isEmpty ? null : _sex,
                    _birth,
                    double.tryParse(_heightCtrl.text.trim()),
                  ));
                },
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
