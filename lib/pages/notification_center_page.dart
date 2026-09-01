import 'package:flutter/cupertino.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_nav.dart';
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
    // 先把「当前档案未完成的提醒」补成通知行，并把已过时间的标记为已送达；
    // 再清掉 30 天前的旧通知——通知中心是「最近发生了什么」，不是永久归档。
    await repo.syncNotificationsFromReminders();
    await repo.purgeOldNotifications();
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
    return IosLargeTitleScaffold(
      title: '通知',
      onRefresh: _loading ? null : _load,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasUnread)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              onPressed: () async {
                await appRepository?.markAllNotificationsRead();
                _load();
              },
              child: const Text('全部已读', style: TextStyle(fontSize: 15)),
            ),
          if (_notifications.isNotEmpty)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
              onPressed: _clearAll,
              child: const Icon(CupertinoIcons.trash, size: 22),
            ),
        ],
      ),
      children: _loading
          ? const [
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CupertinoActivityIndicator()),
              )
            ]
          : _notifications.isEmpty
              ? const [
                  Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text('还没有通知记录',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                    ),
                  ),
                ]
              : [
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Column(children: [
                      for (final n in _notifications) _notificationTile(n),
                    ]),
                  ),
                ],
    );
  }

  Future<void> _clearAll() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('清除全部通知记录？'),
        content: const Text('只清这份通知列表，不影响你设置的提醒计划。'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('清除')),
        ],
      ),
    );
    if (ok != true) return;
    await appRepository?.clearNotifications();
    _load();
  }

  Widget _notificationTile(NotificationRecord n) {
    final unread = n.readAt == null && n.deliveredAt != null;
    return Dismissible(
      key: ValueKey('notif-${n.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        child: const Icon(CupertinoIcons.delete, color: AppColors.abnormal),
      ),
      onDismissed: (_) async {
        await appRepository?.deleteNotification(n.id);
        setState(() => _notifications.removeWhere((x) => x.id == n.id));
      },
      child: HealthRow(
        leading: Icon(
          n.category == 'medication'
              ? CupertinoIcons.capsule
              : CupertinoIcons.calendar,
          size: 20,
          color: unread ? AppColors.primary : AppColors.textSecondary,
        ),
        title: n.title,
        subtitle:
            '${formatDateCn(n.scheduledFor)} ${formatTime(n.scheduledFor)}'
            '${n.deliveredAt == null ? ' · 待提醒' : ''}',
        trailing: unread ? const Dot(AppColors.primary, size: 8) : null,
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
