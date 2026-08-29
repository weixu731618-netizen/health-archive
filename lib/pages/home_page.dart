import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/profile_switcher.dart';
import 'notification_center_page.dart';
import 'reminders_page.dart';

/// 内容区域的最大宽度：宽屏下避免卡片无限拉宽。
const double _kContentMaxWidth = 720;

/// 首页 = 中性门厅。
/// 打开 App 的第一屏刻意不放健康数据（指标 / 疾病 / 报告），避免在别人面前一眼暴露。
/// 只放：脱敏的待办摘要（只给条数，不写药名 / 指标名）+ 今日一则。
/// 具体健康状态在「身体」，历史资料在「记录」，账户设置在右上角头像。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _unread = 0;
  int _todayTodo = 0;

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
      final reminders = await repo.getActiveReminders();
      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      var todo = 0;
      for (final r in reminders) {
        if (r.kind == 'recheck') {
          if (r.dueDate != null && !r.dueDate!.isAfter(endOfToday)) todo++;
        } else if (r.kind == 'medication' && r.enabled) {
          todo++;
        }
      }
      if (mounted) {
        setState(() {
          _unread = unread;
          _todayTodo = todo;
        });
      }
    } catch (_) {
      // 首页失败不阻塞
    }
  }

  Future<void> _openNotifications() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const NotificationCenterPage()))
      .then((_) => _load());

  Future<void> _openReminders() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const RemindersPage()))
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
              children: [
                if (_todayTodo > 0) ...[
                  _TodoCard(count: _todayTodo, onTap: _openReminders),
                  const SizedBox(height: 12),
                ],
                const HealthTipCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 脱敏待办卡：只显示"今天有 N 项健康提醒"，不透露是什么药 / 什么指标。
/// 点进去才看到具体内容。
class _TodoCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _TodoCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.checklist_rtl, color: AppColors.primary),
        title: Text(
          '今天有 $count 项健康提醒',
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        subtitle: const Text(
          '点击查看复查 / 服药安排',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
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
