import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/profile_switcher.dart';
import 'notification_center_page.dart';

/// 内容区域的最大宽度：宽屏下避免卡片无限拉宽。
const double _kContentMaxWidth = 720;

/// 首页：AppBar 一个通知铃铛（有未读带红点）+ 档案切换器；正文只有「今日一则」。
/// 健康状况看板在「身体」tab；铃铛进入「通知中心」（只看实际产生的通知），
/// 提醒的管理（复查 / 服药计划）在「我的 → 提醒」。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = appRepository;
      if (repo == null) return;
      await repo.syncNotificationsFromReminders();
      final unread = await repo.unreadNotificationCount();
      if (mounted) setState(() => _unread = unread);
    } catch (_) {
      // 首页失败不阻塞
    }
  }

  Future<void> _openNotifications() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const NotificationCenterPage()))
      .then((_) => _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          _BellAction(unread: _unread, onTap: _openNotifications),
          const ProfileSwitcher(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: const [
                HealthTipCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BellAction extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;
  const _BellAction({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: '通知',
          icon: const Icon(Icons.notifications_none),
          onPressed: onTap,
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppColors.abnormal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
