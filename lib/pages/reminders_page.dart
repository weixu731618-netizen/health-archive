import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../widgets/ios_tap.dart';
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
    // 慢病升级 步骤4：进页面先按随访模板重算一遍自动复查提醒。
    try {
      await repo.regenerateFollowUpsForAllProfiles();
    } catch (_) {}
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
    final followups = _reminders.where((r) => r.kind == 'followup').toList()
      ..sort((a, b) => (a.dueDate ?? DateTime(9999))
          .compareTo(b.dueDate ?? DateTime(9999)));
    return Scaffold(
      appBar: AppBar(title: const Text('提醒')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              children: [
                if (followups.isNotEmpty) ...[
                  const HealthSectionHeader('随访计划',
                      padding: EdgeInsets.fromLTRB(4, 8, 4, 10)),
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Column(
                        children: [for (final r in followups) _reminderTile(r)]),
                  ),
                ],
                const HealthSectionHeader('复查提醒'),
                if (rechecks.isEmpty)
                  const _EmptyHint('异常指标可在「指标历史」页设置复查提醒')
                else
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Column(
                        children: [for (final r in rechecks) _reminderTile(r)]),
                  ),
                const SizedBox(height: 12),
                IosButton.tinted('新建复查提醒',
                    icon: CupertinoIcons.alarm,
                    onPressed: _busy ? null : _addRecheck,
                    expand: true),
                const HealthSectionHeader('服药提醒'),
                if (meds.isEmpty)
                  const _EmptyHint('在「用药记录」里编辑药品时可开启服药提醒')
                else
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Column(
                        children: [for (final r in meds) _reminderTile(r)]),
                  ),
              ],
            ),
    );
  }

  Widget _reminderTile(Reminder r) {
    final isRecheck = r.kind == 'recheck' || r.kind == 'followup';
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
        padding: const EdgeInsets.only(right: 12),
        child: const Icon(CupertinoIcons.delete, color: AppColors.abnormal),
      ),
      confirmDismiss: (_) => showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('移除提醒「${r.title}」？'),
          actions: [
            CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消')),
            CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('移除')),
          ],
        ),
      ),
      onDismissed: (_) => _remove(r),
      child: HealthRow(
        leading: isRecheck
            ? IosTap(
                onTap: _busy ? null : () => _toggleDone(r),
                child: Icon(
                  done
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.circle,
                  size: 22,
                  color: done ? AppColors.primary : AppColors.insufficient,
                ),
              )
            : null,
        title: r.title,
        subtitle: sub,
        trailing: isRecheck
            ? null
            : CupertinoSwitch(
                value: r.enabled,
                onChanged: _busy ? null : (v) => _toggle(r, v),
              ),
      ),
    );
  }
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              CupertinoTextField(
                controller: _titleCtrl,
                placeholder: '提醒什么（如：复查甲功）',
              ),
              const SizedBox(height: 14),
              const Text('多久之后',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _presets.entries)
                    ChoicePill(
                      label: e.key,
                      selected: _days == e.value,
                      onTap: () => setState(() => _days = e.value),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              CupertinoTextField(
                controller: _noteCtrl,
                placeholder: '备注（选填）',
              ),
              const SizedBox(height: 18),
              CupertinoButton.filled(
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
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
