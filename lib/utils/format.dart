/// 轻量时间格式化工具，避免为此引入第三方 intl 依赖。
library;

/// 格式化为 yyyy-MM-dd，例如 2026-08-19
String formatDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// 格式化为 yyyy年M月d日，例如 2026年8月19日
String formatDateCn(DateTime d) => '${d.year}年${d.month}月${d.day}日';

/// 格式化为 HH:mm，例如 08:30
String formatTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// 格式化为 M-d，用于图表横轴等空间有限的场景，例如 8-19
String formatDateShort(DateTime d) => '${d.month}-${d.day}';
