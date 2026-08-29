import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../pages/family_members_page.dart';
import '../pages/profile_page.dart';

/// 每页右上角的头像入口（首页 / 身体 / 记录共用）。
/// 一个控件承担两件事：
///  - 切换当前健康档案人物（多人时列出所有人）
///  - 进入「个人中心 / 设置」（原来的「我的」页，不再占底部 Tab）
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

  @override
  Widget build(BuildContext context) {
    final activeId = appRepository?.activeProfileId ?? 1;
    final name = _activeName;
    final multi = _people.length > 1;

    return PopupMenuButton<int>(
      tooltip: '个人中心',
      onSelected: (v) {
        if (v == -1) {
          _push(const FamilyMembersPage());
        } else if (v == -2) {
          _push(const ProfilePage());
        } else {
          switchActiveProfile(v);
        }
      },
      itemBuilder: (_) => [
        if (multi) ...[
          for (final p in _people)
            CheckedPopupMenuItem<int>(
              value: p.id,
              checked: p.id == activeId,
              child: Text(p.displayName),
            ),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem<int>(value: -1, child: Text('家庭成员')),
        const PopupMenuItem<int>(value: -2, child: Text('设置')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.primary.withValues(alpha: 0.14),
              child: Text(
                name.isNotEmpty ? name.characters.first : '我',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (multi) ...[
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
            ],
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
