import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/report_followup.dart';

/// 03（§17-18）：刚保存完一份报告后调用。
///
/// 若能在「待复查任务」里找到器官对得上、时间也合理的一条，就弹一个
/// **非破坏性**确认框问用户是否关联为这次复查。用户点「关联」才标记完成；
/// 置信度再高也不自动确认。找不到就什么都不做。
/// 返回 true 表示用户把这份报告关联成了某条待复查（E4：结果页据此不再
/// 重复提示「设置复查提醒」）。
Future<bool> offerFollowUpLink(
  BuildContext context, {
  required Set<String> reportAreas,
  required DateTime reportDate,
}) async {
  final repo = appRepository;
  if (repo == null) return false;

  List<Reminder> reminders;
  try {
    reminders = await repo.getActiveReminders();
  } catch (_) {
    return false;
  }

  final match = findFollowUpMatch(
    reminders,
    reportAreas: reportAreas,
    reportDate: reportDate,
  );
  if (match == null || !context.mounted) return false;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('关联为这次复查？'),
      content: Text(
        '这份报告可能就是「${match.title}」的复查结果。'
        '关联后，这条待复查会标记为已完成，并进入历史对比。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('不是'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('关联'),
        ),
      ],
    ),
  );

  if (ok == true) {
    try {
      await repo.markReminderCompleted(match.id, at: reportDate);
      await syncReminders();
      return true;
    } catch (_) {
      // 关联失败不打断保存流程
    }
  }
  return false;
}
