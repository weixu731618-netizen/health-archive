import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../pages/family_members_page.dart';

/// B1：档案切换器。放在首页 AppBar，显示当前档案名，点开可切换家庭成员或进入管理页。
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

  Future<void> _openManage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FamilyMembersPage()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final activeId = appRepository?.activeProfileId ?? 1;
    // 只有「本人」时不显示切换器，避免单人场景多一个没意义的控件。
    if (_people.length <= 1) return const SizedBox.shrink();

    return PopupMenuButton<int>(
      tooltip: '切换档案',
      onSelected: (v) {
        if (v == -1) {
          _openManage();
        } else {
          switchActiveProfile(v);
        }
      },
      itemBuilder: (_) => [
        for (final p in _people)
          CheckedPopupMenuItem<int>(
            value: p.id,
            checked: p.id == activeId,
            child: Text(p.displayName),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(value: -1, child: Text('管理家庭成员')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_alt_outlined, size: 18),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                _activeName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
