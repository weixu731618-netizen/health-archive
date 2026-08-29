import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../utils/format.dart';

/// 通知中心（§2-15）：首页铃铛进入。
/// 只展示「实际产生的通知 / 提醒」历史——复查提醒到期、服药提醒到点等，
/// 数据来自 `notifications` 表（本地定时通知与远程 APNs 共用同一份）。
/// 提醒的「管理」（新建复查提醒、服药计划、开关、时间）在「我的 → 提醒」，
/// 两者刻意分开，不混在一页。
class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  List<NotificationRecord> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    // 先把「当前档案未完成的提醒」补成通知行，并把已过时间的标记为已送达。
    await repo.syncNotificationsFromReminders();
    final notifications = await repo.getNotifications(limit: 50);
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => n.readAt == null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () async {
                await appRepository?.markAllNotificationsRead();
                _load();
              },
              child: const Text('全部已读'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (_notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          '还没有通知记录',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  for (final n in _notifications) _notificationTile(n),
                ],
              ),
            ),
    );
  }

  Widget _notificationTile(NotificationRecord n) {
    final unread = n.readAt == null && n.deliveredAt != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          n.category == 'medication'
              ? Icons.medication_outlined
              : Icons.event_available_outlined,
          color: unread ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(n.title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: unread ? FontWeight.w600 : FontWeight.w400)),
        subtitle: Text(
          '${formatDateCn(n.scheduledFor)} ${formatTime(n.scheduledFor)}'
          '${n.deliveredAt == null ? ' · 待提醒' : ''}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        onTap: () async {
          if (unread) {
            await appRepository?.markNotificationRead(n.id);
            _load();
          }
        },
      ),
    );
  }
}
