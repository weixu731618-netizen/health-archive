import '../data/app_database.dart';

/// B2：提醒的时间点解析 / 默认值 / 系统通知 id 计算 / 到期文案——纯逻辑，便于测试。

/// 一天里的一个时间点（时:分）。
class TimeOfDayValue {
  final int hour;
  final int minute;
  const TimeOfDayValue(this.hour, this.minute);

  String get text =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is TimeOfDayValue && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => hour * 60 + minute;
}

/// 把 "08:00,20:00" 解析成时间点列表；非法项跳过，结果按时间排序去重。
List<TimeOfDayValue> parseDailyTimes(String? csv) {
  if (csv == null || csv.trim().isEmpty) return const [];
  final out = <TimeOfDayValue>[];
  for (final raw in csv.split(',')) {
    final parts = raw.trim().split(':');
    if (parts.length != 2) continue;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) continue;
    if (h < 0 || h > 23 || m < 0 || m > 59) continue;
    final v = TimeOfDayValue(h, m);
    if (!out.contains(v)) out.add(v);
  }
  out.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  return out;
}

/// 按「每日次数」给一组合理的默认服药时间点。
List<String> defaultMedicationTimes(int timesPerDay) {
  switch (timesPerDay) {
    case 1:
      return ['09:00'];
    case 2:
      return ['09:00', '21:00'];
    case 3:
      return ['08:00', '13:00', '20:00'];
    case 4:
      return ['08:00', '12:00', '16:00', '20:00'];
    default:
      if (timesPerDay <= 0) return ['09:00'];
      // 5 次及以上：08:00 起每 3 小时一次，最多到 8 次。
      final n = timesPerDay > 8 ? 8 : timesPerDay;
      return [
        for (var i = 0; i < n; i++)
          '${(8 + i * 3).toString().padLeft(2, '0')}:00',
      ];
  }
}

/// 从用药记录的 `timesPerDay` 文本里取一个次数（取第一段数字，默认 1）。
int timesPerDayCount(String? raw) {
  if (raw == null) return 1;
  final match = RegExp(r'\d+').firstMatch(raw);
  final n = match == null ? 1 : int.parse(match.group(0)!);
  return n < 1 ? 1 : n;
}

/// 一条提醒对应的系统通知 id 列表。
/// - 复查：单个 id = `reminderId * 10`
/// - 服药：每个时间点一个 id = `reminderId * 10 + 时间点序号`（序号 0..9）
List<int> notificationIdsForReminder(Reminder r) {
  final base = r.id * 10;
  if (r.kind == 'medication') {
    final times = parseDailyTimes(r.dailyTimes);
    if (times.isEmpty) return const [];
    final n = times.length > 9 ? 9 : times.length;
    return [for (var i = 0; i < n; i++) base + i];
  }
  return [base];
}

/// 到期文案："已过期 N 天" / "今天" / "明天" / "还有 N 天"。
String dueDescription(DateTime due, DateTime now) {
  final d0 = DateTime(now.year, now.month, now.day);
  final d1 = DateTime(due.year, due.month, due.day);
  final days = d1.difference(d0).inDays;
  if (days < 0) return '已过期 ${-days} 天';
  if (days == 0) return '今天';
  if (days == 1) return '明天';
  return '还有 $days 天';
}
