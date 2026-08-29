import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../utils/format.dart';
import '../utils/reminder_schedule.dart';

/// B2：提醒中心。当前档案的复查提醒 + 服药提醒，可开关 / 删除 / 标记已复查；
/// 下方是最近的通知记录。系统通知（本地 + 远程 APNs）与这里共用同一份数据。
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> _reminders = [];
  List<NotificationRecord> _notifications = [];
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
    await repo.syncNotificationsFromReminders();
    final reminders = await repo.getActiveReminders(includeCompleted: true);
    final notifications = await repo.getNotifications(limit: 50);
    if (mounted) {
      setState(() {
        _reminders = reminders;
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(Reminder r, bool enabled) async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    await repo.setReminderEnabled(r.id, enabled);
    await syncReminders();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _complete(Reminder r) async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    await repo.markReminderCompleted(r.id);
    await syncReminders();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete(Reminder r) async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除提醒「${r.title}」？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    await repo.deleteReminder(r.id);
    await syncReminders();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _addRecheck() async {
    final result = await showModalBottomSheet<_NewRecheckResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _NewRecheckSheet(),
    );
    if (result == null) return;
    final repo = appRepository;
    if (repo == null) return;
    setState(() => _busy = true);
    await NotificationService.instance.requestPermission();
    await repo.insertReminder(
      kind: 'recheck',
      title: result.title,
      detail: result.note.isEmpty ? null : result.note,
      dueDate: DateTime.now().add(Duration(days: result.days)),
    );
    await syncReminders();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final rechecks =
        _reminders.where((r) => r.kind == 'recheck').toList();
    final meds = _reminders.where((r) => r.kind == 'medication').toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒'),
        actions: [
          if (_notifications.any((n) => n.readAt == null))
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
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const _SectionLabel('复查提醒'),
                if (rechecks.isEmpty)
                  const _EmptyHint('异常指标可在「指标历史」页设置复查提醒'),
                for (final r in rechecks) _reminderTile(r),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _addRecheck,
                  icon: const Icon(Icons.add_alarm_outlined),
                  label: const Text('新建复查提醒'),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
                const SizedBox(height: 16),
                const _SectionLabel('服药提醒'),
                if (meds.isEmpty)
                  const _EmptyHint('在「用药记录」里编辑药品时可开启服药提醒'),
                for (final r in meds) _reminderTile(r),
                const SizedBox(height: 16),
                const _SectionLabel('最近通知'),
                if (_notifications.isEmpty)
                  const _EmptyHint('还没有通知记录'),
                for (final n in _notifications) _notificationTile(n),
              ],
            ),
    );
  }

  Widget _reminderTile(Reminder r) {
    final isRecheck = r.kind == 'recheck';
    final done = r.completedAt != null;
    final sub = <String>[
      if (isRecheck && r.dueDate != null)
        done
            ? '已复查 ${formatDate(r.completedAt!)}'
            : '${formatDate(r.dueDate!)} · ${dueDescription(r.dueDate!, DateTime.now())}',
      if (!isRecheck)
        '每天 ${parseDailyTimes(r.dailyTimes).map((t) => t.text).join('、')}',
      if ((r.detail ?? '').isNotEmpty) r.detail!,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          r.title,
          style: TextStyle(
            fontSize: 15,
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(sub,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecheck && !done)
              IconButton(
                tooltip: '标记已复查',
                icon: const Icon(Icons.check_circle_outline,
                    color: AppColors.primary),
                onPressed: _busy ? null : () => _complete(r),
              )
            else if (!isRecheck)
              Switch(
                value: r.enabled,
                onChanged: _busy ? null : (v) => _toggle(r, v),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.abnormal),
              onPressed: _busy ? null : () => _delete(r),
            ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      );
}

class _NewRecheckResult {
  final String title;
  final int days;
  final String note;
  const _NewRecheckResult(this.title, this.days, this.note);
}

class _NewRecheckSheet extends StatefulWidget {
  const _NewRecheckSheet();
  @override
  State<_NewRecheckSheet> createState() => _NewRecheckSheetState();
}

class _NewRecheckSheetState extends State<_NewRecheckSheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  int _days = 30;

  static const _presets = {'1 个月后': 30, '2 个月后': 60, '3 个月后': 90, '半年后': 180};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新建复查提醒',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration:
                    const InputDecoration(labelText: '提醒什么（如：复查甲功）'),
              ),
              const SizedBox(height: 16),
              const Text('多久之后',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in _presets.entries)
                    ChoiceChip(
                      label: Text(e.key),
                      selected: _days == e.value,
                      onSelected: (_) => setState(() => _days = e.value),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: '备注（选填）'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final t = _titleCtrl.text.trim();
                  if (t.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                          const SnackBar(content: Text('请填写提醒内容')));
                    return;
                  }
                  Navigator.of(context).pop(
                      _NewRecheckResult(t, _days, _noteCtrl.text.trim()));
                },
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
