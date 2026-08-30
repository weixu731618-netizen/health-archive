import '../data/app_database.dart';

/// 「检查驱动」的一面:你该定期做的检查项目,做到没做到。
///
/// 与「慢病随访」互补——随访是有病的人的复查清单;这里是**所有人**的
/// 「体检有没有跟上」。既能当提醒用(哪些该查了),也能当完成度看(覆盖了几项)。
class CheckupAspect {
  final String key;
  final String label;
  final Duration cycle;

  /// 命中这些化验指标 id 就算「查过」。
  final List<String> metricIds;

  /// 命中这些日常记录类型就算「查过」。
  final List<String> dailyTypes;

  /// 报告类型里包含这些子串就算「查过」。
  final List<String> reportTypeKeys;

  /// true = 任意一份报告都算(用于「年度体检」)。
  final bool anyReport;

  const CheckupAspect({
    required this.key,
    required this.label,
    required this.cycle,
    this.metricIds = const [],
    this.dailyTypes = const [],
    this.reportTypeKeys = const [],
    this.anyReport = false,
  });

  String get cycleText {
    final d = cycle.inDays;
    if (d <= 200) return '建议每半年';
    if (d <= 400) return '建议每年';
    return '建议每 ${(d / 365).round()} 年';
  }
}

// ignore: constant_identifier_names
const List<CheckupAspect> CHECKUP_ASPECTS = [
  CheckupAspect(
      key: 'physical', label: '年度体检', cycle: Duration(days: 365),
      anyReport: true),
  CheckupAspect(
      key: 'bp', label: '血压', cycle: Duration(days: 365),
      dailyTypes: ['blood_pressure']),
  CheckupAspect(
      key: 'glucose', label: '血糖 / 糖化', cycle: Duration(days: 365),
      metricIds: ['FPG', 'HBA1C', 'GA'], dailyTypes: ['blood_glucose']),
  CheckupAspect(
      key: 'lipid', label: '血脂', cycle: Duration(days: 365),
      metricIds: ['TC', 'TG', 'LDLC', 'HDLC']),
  CheckupAspect(
      key: 'liver_kidney', label: '肝肾功能', cycle: Duration(days: 365),
      metricIds: ['ALT', 'AST', 'GGT', 'CREA', 'EGFR', 'BUN', 'UA']),
  CheckupAspect(
      key: 'blood_routine', label: '血常规', cycle: Duration(days: 365),
      metricIds: ['WBC', 'RBC', 'HGB', 'PLT']),
  CheckupAspect(
      key: 'thyroid', label: '甲状腺', cycle: Duration(days: 730),
      metricIds: ['TSH', 'FT3', 'FT4'], reportTypeKeys: ['甲状腺']),
  CheckupAspect(
      key: 'abdominal_us', label: '腹部超声', cycle: Duration(days: 730),
      reportTypeKeys: ['B超', '超声', '彩超']),
  CheckupAspect(
      key: 'chest', label: '胸部影像', cycle: Duration(days: 730),
      reportTypeKeys: ['CT', 'X光', 'DR', '胸片']),
  CheckupAspect(
      key: 'eye', label: '眼睛', cycle: Duration(days: 730),
      reportTypeKeys: ['眼', '视力', '眼底']),
  CheckupAspect(
      key: 'oral', label: '口腔', cycle: Duration(days: 365),
      reportTypeKeys: ['口腔', '牙']),
];

class AspectStatus {
  final CheckupAspect aspect;
  final DateTime? lastDone;
  final bool overdue;

  const AspectStatus(this.aspect, this.lastDone, this.overdue);

  bool get neverDone => lastDone == null;
  bool get covered => lastDone != null && !overdue;
  bool get due => neverDone || overdue;

  /// 逾期天数(从没查过按一个很大的数,排最前)。
  int overdueDays(DateTime now) {
    if (lastDone == null) return 1 << 30;
    return now.difference(lastDone!).inDays - aspect.cycle.inDays;
  }
}

class CoverageOverview {
  final List<AspectStatus> aspects;
  final DateTime now;

  const CoverageOverview(this.aspects, this.now);

  int get total => aspects.length;
  int get coveredCount => aspects.where((a) => a.covered).length;
  double get ratio => total == 0 ? 0 : coveredCount / total;
  int get percent => (ratio * 100).round();

  /// 该做的(逾期 + 从没查过),逾期越久越靠前。
  List<AspectStatus> get dueList {
    final list = aspects.where((a) => a.due).toList()
      ..sort((a, b) => b.overdueDays(now).compareTo(a.overdueDays(now)));
    return list;
  }

  String get headline => '健康档案完成度 $percent%';
}

CoverageOverview buildCheckupCoverage({
  required List<HealthMetric> metrics,
  required List<MedicalReport> reports,
  required List<DailyHealthRecord> daily,
  DateTime? now,
}) {
  final ts = now ?? DateTime.now();

  DateTime? newestMetric(List<String> ids) {
    DateTime? best;
    for (final m in metrics) {
      if (!ids.contains(m.metricId)) continue;
      if (best == null || m.measuredAt.isAfter(best)) best = m.measuredAt;
    }
    return best;
  }

  DateTime? newestDaily(List<String> types) {
    DateTime? best;
    for (final d in daily) {
      if (!types.contains(d.type)) continue;
      if (best == null || d.measuredAt.isAfter(best)) best = d.measuredAt;
    }
    return best;
  }

  DateTime? newestReport(CheckupAspect a) {
    DateTime? best;
    for (final r in reports) {
      final hit = a.anyReport ||
          a.reportTypeKeys.any((k) => r.reportType.contains(k));
      if (!hit) continue;
      if (best == null || r.reportDate.isAfter(best)) best = r.reportDate;
    }
    return best;
  }

  final out = <AspectStatus>[];
  for (final a in CHECKUP_ASPECTS) {
    final candidates = <DateTime>[
      if (newestMetric(a.metricIds) case final d?) d,
      if (newestDaily(a.dailyTypes) case final d?) d,
      if (newestReport(a) case final d?) d,
    ];
    final last = candidates.isEmpty
        ? null
        : candidates.reduce((x, y) => x.isAfter(y) ? x : y);
    final overdue = last != null && ts.difference(last) > a.cycle;
    out.add(AspectStatus(a, last, overdue));
  }
  return CoverageOverview(out, ts);
}
