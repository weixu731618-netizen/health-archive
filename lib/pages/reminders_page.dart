import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../utils/format.dart';
import '../utils/reminder_schedule.dart';

/// B2 / §2-15：提醒管理页。「我的 → 提醒」进入。
/// 只管理当前档案的复查提醒 + 服药提醒（新建 / 开关 / 删除 / 标记已复查）。
/// 实际产生的通知历史在首页铃铛的「通知中心」，两者分开、不混在一页。
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> _reminders = [];
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
    // 提醒有增删改后同步通知表，让「通知中心」拿到最新数据。
    await repo.syncNotificationsFromReminders();
    final reminders = await repo.getActiveReminders(includeCompleted: true);
    if (mounted) {
      setState(() {
        _reminders = reminders;
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

  /// 点圆圈：未完成 → 打勾完成；已完成 → 撤销回待办。
  Future<void> _toggleDone(Reminder r) async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    if (r.completedAt == null) {
      await repo.markReminderCompleted(r.id);
    } else {
      await repo.unmarkReminderCompleted(r.id);
    }
    await syncReminders();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  /// 左滑永久删除（confirmDismiss 已弹过确认）。
  Future<void> _remove(Reminder r) async {
    final repo = appRepository;
    if (repo == null) return;
    await repo.deleteReminder(r.id);
    await syncReminders();
    await _load();
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
    final rechecks = _reminders.where((r) => r.kind == 'recheck').toList();
    final meds = _reminders.where((r) => r.kind == 'medication').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('提醒')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const _SectionLabel('复查提醒'),
                if (rechecks.isEmpty) const _EmptyHint('异常指标可在「指标历史」页设置复查提醒'),
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
                if (meds.isEmpty) const _EmptyHint('在「用药记录」里编辑药品时可开启服药提醒'),
                for (final r in meds) _reminderTile(r),
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
    return Dismissible(
      key: ValueKey('rem-${r.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24, bottom: 10),
        child: const Icon(Icons.delete_outline, color: AppColors.abnormal),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('移除提醒「${r.title}」？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('移除')),
          ],
        ),
      ),
      onDismissed: (_) => _remove(r),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: isRecheck
              ? IconButton(
                  tooltip: done ? '撤销完成' : '标记已完成',
                  icon: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? AppColors.primary : AppColors.textSecondary,
                  ),
                  onPressed: _busy ? null : () => _toggleDone(r),
                )
              : null,
          title: Text(
            r.title,
            style: TextStyle(
              fontSize: 15,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(sub,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          trailing: isRecheck
              ? null
              : Switch(
                  value: r.enabled,
                  onChanged: _busy ? null : (v) => _toggle(r, v),
                ),
        ),
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新建复查提醒',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: '提醒什么（如：复查甲功）'),
              ),
              const SizedBox(height: 16),
              const Text('多久之后',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
                      ..showSnackBar(const SnackBar(content: Text('请填写提醒内容')));
                    return;
                  }
                  Navigator.of(context)
                      .pop(_NewRecheckResult(t, _days, _noteCtrl.text.trim()));
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
