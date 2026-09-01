import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../widgets/ios_nav.dart';
import '../widgets/toast.dart';
import '../widgets/health_ui.dart';
import '../utils/format.dart';
import '../utils/report_image_save.dart';

/// B1：家庭成员管理。列出「本人 + 家庭成员」，可切换当前档案、新增 / 编辑 / 删除成员。
///
/// UI 走经典 iOS「分组内嵌列表」：点行切换档案，行尾 ⓘ 进编辑页；
/// 新增 / 编辑是整页推入的分组表单（对齐 iOS 通讯录编辑联系人），
/// 删除成员放在编辑页底部的红色行里，不再用安卓式的三点溢出菜单。
class FamilyMembersPage extends StatefulWidget {
  const FamilyMembersPage({super.key});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

/// 关系可选项（「本人」固定，不在此列）。存的就是这里的中文。
/// 关系是「选填」：不选时存空串，界面上不显示那行小字。
const List<String> kMemberRelationships = [
  '配偶',
  '父亲',
  '母亲',
  '儿子',
  '女儿',
  '兄弟姐妹',
  '其他',
];

/// 判断某个 relationship 值是否是一个「可显示的关系标签」。
/// 空串、旧的英文哨兵值（'self' / 'other'）都当作「没有关系」。
bool _hasRelationshipLabel(String r) =>
    r.isNotEmpty && r != 'self' && r != 'other';

/// 由出生日期算周岁，用于列表副标题。
String _ageText(DateTime birth) {
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    age--;
  }
  return age >= 0 ? '$age 岁' : '';
}

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
    if (_busy || p.id == _activeId) return;
    await switchActiveProfile(p.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _addMember() async {
    final data = await Navigator.of(context).push<_MemberFormResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _MemberEditPage(),
      ),
    );
    if (data == null || data.delete) return;
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
    final data = await Navigator.of(context).push<_MemberFormResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _MemberEditPage(existing: p),
      ),
    );
    if (data == null) return;
    if (data.delete) {
      await _deleteMember(p);
      return;
    }
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
    showToast(context, s);
  }

  /// 列表副标题：关系 · 性别 · 年龄（关系为空、或与名字相同则省略）。
  String _subtitleFor(PersonProfile p) {
    final isSelf = p.id == HealthRepository.defaultProfileId;
    final relLabel = isSelf ? '本人' : p.relationship;
    final parts = <String>[
      if ((isSelf || _hasRelationshipLabel(p.relationship)) &&
          relLabel != p.displayName)
        relLabel,
      if ((p.sex ?? '').isNotEmpty) p.sex!,
      if (p.dateOfBirth != null) _ageText(p.dateOfBirth!),
    ]..removeWhere((s) => s.isEmpty);
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return IosLargeTitleScaffold(
      title: '家庭成员',
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: _loading
          ? const [
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CupertinoActivityIndicator()),
              )
            ]
          : [
              for (final p in _people) ...[
                _memberCard(p),
                const SizedBox(height: 12),
              ],
              _AddMemberCard(onTap: _busy ? null : _addMember),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 14, 4, 4),
                child: Text(
                  '每个成员的报告和健康数据相互独立。点选一个成员即可切换当前查看的档案。',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
    );
  }

  Widget _memberCard(PersonProfile p) {
    final isActive = p.id == _activeId;
    final subtitle = _subtitleFor(p);
    return HealthCard(
      onTap: _busy ? null : () => _switchTo(p),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          _Avatar(name: p.displayName, active: isActive),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(p.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary)),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      const Text('当前',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: _busy ? null : () => _editMember(p),
            child: const Icon(CupertinoIcons.slider_horizontal_3,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }
}

class _AddMemberCard extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddMemberCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.add,
                size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          const Text('添加家庭成员',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final bool active;
  const _Avatar({required this.name, required this.active});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: active
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: TextStyle(
          fontSize: 14,
          color: active ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
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

  /// 编辑页点了「删除成员」时回传，其余字段无意义。
  final bool delete;

  const _MemberFormResult(
    this.name,
    this.relationship,
    this.sex,
    this.birth,
    this.heightCm,
  ) : delete = false;

  const _MemberFormResult.remove()
      : name = '',
        relationship = '',
        sex = null,
        birth = null,
        heightCm = null,
        delete = true;
}

/// 新增 / 编辑成员：整页推入的 iOS 分组表单。
class _MemberEditPage extends StatefulWidget {
  final PersonProfile? existing;
  const _MemberEditPage({this.existing});

  @override
  State<_MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<_MemberEditPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _heightCtrl;
  String _relationship = '';
  String _sex = '';
  DateTime? _birth;
  bool _canSave = false;

  bool get _isSelf => widget.existing?.id == HealthRepository.defaultProfileId;
  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.displayName ?? '')
      ..addListener(_recomputeCanSave);
    _heightCtrl = TextEditingController(
        text: e?.heightCm == null ? '' : _fmtHeight(e!.heightCm!));
    _relationship = (e != null && _hasRelationshipLabel(e.relationship))
        ? e.relationship
        : '';
    _sex = e?.sex ?? '';
    _birth = e?.dateOfBirth;
    _canSave = _nameCtrl.text.trim().isNotEmpty;
  }

  void _recomputeCanSave() {
    final next = _nameCtrl.text.trim().isNotEmpty;
    if (next != _canSave) setState(() => _canSave = next);
  }

  static String _fmtHeight(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String get _title {
    if (_isNew) return '添加家庭成员';
    return _isSelf ? '编辑「本人」资料' : '编辑资料';
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(_MemberFormResult(
      name,
      _relationship,
      _sex.isEmpty ? null : _sex,
      _birth,
      double.tryParse(_heightCtrl.text.trim()),
    ));
  }

  Future<void> _pickRelationship() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _RelationshipPickerPage(selected: _relationship),
      ),
    );
    if (picked == null) return; // 返回但没选，保持不变
    setState(() => _relationship = picked == _kNoRelationship ? '' : picked);
  }

  Future<void> _pickBirth() async {
    FocusScope.of(context).unfocus();
    final initial = _birth ?? DateTime(1990, 1, 1);
    DateTime temp = initial;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx, temp),
                    child: const Text('完成'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _birth = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        automaticallyImplyLeading: false,
        leadingWidth: 76,
        leading: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _canSave ? _submit : null,
            child: Text('完成',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _canSave
                        ? AppColors.primary
                        : AppColors.textSecondary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          HealthCard(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              children: [
                HealthFieldRow(
                  label: '姓名',
                  child: CupertinoTextField.borderless(
                    controller: _nameCtrl,
                    placeholder: '称呼 / 姓名',
                    padding: EdgeInsets.zero,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                if (!_isSelf)
                  HealthFieldRow(
                    label: '关系',
                    onTap: _pickRelationship,
                    child: _valueText(
                        _relationship.isEmpty ? '未设置' : _relationship,
                        muted: _relationship.isEmpty),
                  ),
                HealthFieldRow(
                  label: '性别',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ChoicePills(
                      options: const ['男', '女'],
                      value: _sex.isEmpty ? null : _sex,
                      onChanged: (v) => setState(() => _sex = v ?? ''),
                    ),
                  ),
                ),
                HealthFieldRow(
                  label: '出生日期',
                  onTap: _pickBirth,
                  child: _valueText(
                      _birth == null ? '未设置' : formatDate(_birth!),
                      muted: _birth == null),
                ),
                HealthFieldRow(
                  label: '身高',
                  child: CupertinoTextField.borderless(
                    controller: _heightCtrl,
                    placeholder: '选填 (cm)',
                    padding: EdgeInsets.zero,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ),
          if (!_isNew && !_isSelf) ...[
            const SizedBox(height: 14),
            HealthCard(
              onTap: _confirmDelete,
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: const Center(
                child: Text('删除成员',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.abnormal)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _valueText(String v, {required bool muted}) => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 15,
                      color: muted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary)),
            ),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_forward,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      );

  Future<void> _confirmDelete() async {
    final name = widget.existing?.displayName ?? '';
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('删除「$name」'),
        content: const Text(
            '将删除该成员的全部报告、指标、日常记录、疾病史和用药记录，且无法恢复。是否继续？'),
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
    if (ok == true && mounted) {
      Navigator.of(context).pop(const _MemberFormResult.remove());
    }
  }
}

const String _kNoRelationship = '__none__';

/// 关系选择子页：一张卡片装选项行 + 打勾，含「不设置」。
class _RelationshipPickerPage extends StatelessWidget {
  final String selected;
  const _RelationshipPickerPage({required this.selected});

  @override
  Widget build(BuildContext context) {
    final options = <String>[_kNoRelationship, ...kMemberRelationships];
    return Scaffold(
      appBar: AppBar(title: const Text('关系')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          HealthCard(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: Column(
              children: [
                for (final o in options)
                  HealthRow(
                    title: o == _kNoRelationship ? '不设置' : o,
                    trailing: (o == _kNoRelationship
                            ? selected.isEmpty
                            : selected == o)
                        ? const Icon(CupertinoIcons.checkmark_alt,
                            color: AppColors.primary, size: 20)
                        : null,
                    onTap: () => Navigator.of(context).pop(o),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
