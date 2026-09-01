import 'package:flutter/cupertino.dart';

import '../main.dart';

/// G3：报告核对 / 结果 / 详情页顶部的「当前档案：X」小字。
///
/// 只在存在多个家庭档案时显示 —— 单人使用不打扰。用来防止用户切错档案后
/// 把报告导到别人名下却毫无察觉。
class CurrentProfileBadge extends StatefulWidget {
  const CurrentProfileBadge({super.key});

  @override
  State<CurrentProfileBadge> createState() => _CurrentProfileBadgeState();
}

class _CurrentProfileBadgeState extends State<CurrentProfileBadge> {
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    try {
      if (await repo.countPersonProfiles() <= 1) return;
      final p = await repo.getPersonProfile(repo.activeProfileId);
      if (mounted) setState(() => _name = p?.displayName);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = _name;
    if (name == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(CupertinoIcons.folder,
              size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('当前档案：$name',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
