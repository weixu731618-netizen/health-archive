import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../pages/about_page.dart';
import '../pages/family_members_page.dart';
import '../pages/health_records_page.dart';
import '../pages/privacy_page.dart';

/// 每页右上角的头像入口（首页 / 身体 / 记录共用）。
/// 一个控件承担两件事：
///  - 切换当前健康档案人物（多人时列出所有人）
///  - 进入「健康资料 / 家庭成员 / 设置」（原来的「我的」页，不再占底部 Tab）
///
/// 点开是**从底部滑出的面板**，跟 App 里其它菜单（加数据、选器官、筛选）一致，
/// 而不是贴着图标弹的下拉框。
class ProfileSwitcher extends StatefulWidget {
  const ProfileSwitcher({super.key});

  @override
  State<ProfileSwitcher> createState() => _ProfileSwitcherState();
}

class _ProfileSwitcherState extends State<ProfileSwitcher> {
  List<PersonProfile> _people = [];

  @override
  void initState() {
    super.initState();
    activeProfileNotifier.addListener(_onProfileChanged);
    _load();
  }

  @override
  void dispose() {
    activeProfileNotifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    final people = await repo.getAllPersonProfiles();
    if (mounted) setState(() => _people = people);
  }

  String get _activeName {
    final id = appRepository?.activeProfileId ?? 1;
    for (final p in _people) {
      if (p.id == id) return p.displayName;
    }
    return '本人';
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) _load();
  }

  Future<void> _openMenu() async {
    final activeId = appRepository?.activeProfileId ?? 1;
    final result = await showModalBottomSheet<_MenuPick>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true, // 允许弹层高过默认的一半
      builder: (_) => _ProfileMenuSheet(people: _people, activeId: activeId),
    );
    if (result == null || !mounted) return;
    switch (result.kind) {
      case _PickKind.profile:
        await switchActiveProfile(result.profileId!);
      case _PickKind.records:
        await _push(const HealthRecordsPage());
      case _PickKind.family:
        await _push(const FamilyMembersPage());
      case _PickKind.privacy:
        await _push(const PrivacyPage());
      case _PickKind.about:
        await _push(const AboutPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeId = appRepository?.activeProfileId ?? 1;
    final name = _activeName;
    // 默认（看自己的档案）：右上角只有一个素头像图标，最轻。
    // 切到家人时才显示 头像 + 名字 + 箭头，提醒“现在看的不是自己”。
    final viewingOther = activeId != HealthRepository.defaultProfileId;

    return InkWell(
      onTap: _openMenu,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: viewingOther
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.14),
                    child: Text(
                      name.isNotEmpty ? name.characters.first : '我',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_down, size: 20),
                ],
              )
            : const Icon(CupertinoIcons.person_circle, size: 26),
      ),
    );
  }
}

enum _PickKind { profile, records, family, privacy, about }

class _MenuPick {
  final _PickKind kind;
  final int? profileId;
  const _MenuPick(this.kind, {this.profileId});
}

/// 底部面板内容：多档案时先列人物（勾选在右侧），再列功能项。
class _ProfileMenuSheet extends StatelessWidget {
  final List<PersonProfile> people;
  final int activeId;
  const _ProfileMenuSheet({required this.people, required this.activeId});

  @override
  Widget build(BuildContext context) {
    final multi = people.length > 1;
    // 拉高到屏幕 80%，不再是默认的半屏；内容不足时靠 minHeight 撑起，可下滑关闭。
    final minH = MediaQuery.of(context).size.height * 0.8;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minH),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text('账户',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            if (multi) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Text('当前档案',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ),
              for (final p in people)
                ListTile(
                  title: Text(p.displayName,
                      style: const TextStyle(fontSize: 16)),
                  trailing: p.id == activeId
                      ? const Icon(CupertinoIcons.check_mark, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(
                      context, _MenuPick(_PickKind.profile, profileId: p.id)),
                ),
              const Divider(height: 1),
              const SizedBox(height: 4),
            ],
            _ActionTile(
              icon: CupertinoIcons.folder,
              label: '健康资料',
              onTap: () =>
                  Navigator.pop(context, const _MenuPick(_PickKind.records)),
            ),
            _ActionTile(
              icon: CupertinoIcons.person_2,
              label: '家庭成员',
              onTap: () =>
                  Navigator.pop(context, const _MenuPick(_PickKind.family)),
            ),
            _ActionTile(
              icon: CupertinoIcons.shield,
              label: '数据与隐私',
              onTap: () =>
                  Navigator.pop(context, const _MenuPick(_PickKind.privacy)),
            ),
            _ActionTile(
              icon: CupertinoIcons.info,
              label: '关于健康档案',
              onTap: () =>
                  Navigator.pop(context, const _MenuPick(_PickKind.about)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing:
          const Icon(CupertinoIcons.chevron_forward, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
