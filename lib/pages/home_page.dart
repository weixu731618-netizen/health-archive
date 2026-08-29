import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/profile_switcher.dart';
import 'reminders_page.dart';

/// 内容区域的最大宽度：宽屏下避免卡片无限拉宽。
const double _kContentMaxWidth = 720;

/// 首页：只保留「待办提醒」+「健康冷知识」。
/// 健康状况看板在「身体」tab；这里不展示姓名 / 指标 / 需关注列表。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Reminder> _reminders = [];
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
      final reminders = await repo.getActiveReminders();
      final unread = await repo.unreadNotificationCount();
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _unread = unread;
        });
      }
    } catch (_) {
      // 首页失败不阻塞：只是提醒/冷知识
    }
  }

  int get _medReminderCount =>
      _reminders.where((r) => r.kind == 'medication' && r.enabled).length;

  int get _recheckDueCount {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    return _reminders
        .where((r) =>
            r.kind == 'recheck' &&
            r.enabled &&
            r.completedAt == null &&
            r.dueDate != null &&
            !r.dueDate!.isAfter(d0.add(const Duration(days: 1))))
        .length;
  }

  Future<void> _openReminders() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const RemindersPage()))
      .then((_) => _load());

  @override
  Widget build(BuildContext context) {
    final medCount = _medReminderCount;
    final recheckDue = _recheckDueCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          _BellAction(unread: _unread, onTap: _openReminders),
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
                _TodoCard(
                  medCount: medCount,
                  recheckDue: recheckDue,
                  onTap: _openReminders,
                ),
                const SizedBox(height: 12),
                const HealthTipCard(),
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
          tooltip: '提醒',
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

class _TodoCard extends StatelessWidget {
  final int medCount;
  final int recheckDue;
  final VoidCallback onTap;

  const _TodoCard({
    required this.medCount,
    required this.recheckDue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasTodo = medCount > 0 || recheckDue > 0;
    final parts = <String>[
      if (medCount > 0) '$medCount 项服药',
      if (recheckDue > 0) '$recheckDue 项复查到期',
    ];
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                hasTodo
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none,
                size: 20,
                color: hasTodo ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasTodo ? '今天：${parts.join(' · ')}' : '今天没有待办提醒',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: hasTodo ? FontWeight.w600 : FontWeight.w400,
                    color: hasTodo
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
