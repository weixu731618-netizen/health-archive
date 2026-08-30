import '../data/app_database.dart';
import 'body_area_health.dart';

/// 03：复查任务来源 → 展示文案。优先级 医生 > 报告 > 用户 > 系统。
String recheckSourceLabel(String sourceType) {
  switch (sourceType) {
    case 'doctor':
      return '医生建议';
    case 'report':
      return '报告建议';
    case 'system':
      return '系统参考';
    case 'user':
    default:
      return '自己设置';
  }
}

/// 03：系统默认复查间隔选项（天）。只是「参考」，用户必须能确认 / 改 / 关。
const Map<String, int> kRecheckIntervalOptions = {
  '1 个月后': 30,
  '2 个月后': 60,
  '3 个月后': 90,
  '半年后': 180,
  '1 年后': 365,
};

/// 03（§17）：新报告与「待复查任务」的匹配。
///
/// 规则（保守，宁可不匹配也不误配）：
///  - 只看未完成、带到期日的 recheck / followup 提醒
///  - 器官要对得上：提醒的 areaName 命中报告部位，或提醒标题里出现某个报告部位名
///  - 时间要合理：报告日期与提醒到期日相差不超过 [windowDays] 天
///  - 命中多个时，取到期日与报告日期最接近的一个
///
/// 返回 null 表示不提示关联。绝不自动关联——调用方需弹确认。
Reminder? findFollowUpMatch(
  Iterable<Reminder> reminders, {
  required Set<String> reportAreas,
  required DateTime reportDate,
  int windowDays = 120,
}) {
  Reminder? best;
  int? bestDist;
  for (final r in reminders) {
    if (r.kind != 'recheck' && r.kind != 'followup') continue;
    if (r.completedAt != null) continue;
    final due = r.dueDate;
    if (due == null) continue;

    final dist = (due.difference(reportDate).inDays).abs();
    if (dist > windowDays) continue;

    final areaHit = (r.areaName != null && reportAreas.contains(r.areaName)) ||
        reportAreas.any((a) => a.split('/').any((seg) =>
            seg.trim().isNotEmpty && r.title.contains(seg.trim())));
    if (!areaHit) continue;

    if (bestDist == null || dist < bestDist) {
      best = r;
      bestDist = dist;
    }
  }
  return best;
}

/// 03（§19）：同一指标相邻两次记录的差值行。中性措辞，
/// **禁止**出现「好转 / 恶化 / 恢复」这类结论。
String? metricDeltaLine(double current, double? previous, String unit) {
  if (previous == null) return null;
  final d = current - previous;
  if (d.abs() < 1e-9) return '较上次持平';
  final arrow = d > 0 ? '↑' : '↓';
  final mag = d.abs();
  final magText = mag == mag.roundToDouble()
      ? mag.toStringAsFixed(0)
      : mag.toStringAsFixed(mag < 1 ? 2 : 1);
  final u = unit.trim().isEmpty ? '' : ' $unit';
  return '较上次 $arrow $magText$u';
}

/// 一组指标（同一份报告）涉及的身体部位。
Set<String> areasForMetrics(Iterable<HealthMetric> metrics) =>
    {for (final m in metrics) bodyAreaForSystem(m.bodySystem)};
