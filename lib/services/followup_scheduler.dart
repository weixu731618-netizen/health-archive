import '../data/app_database.dart';
import '../models/chronic_condition_dictionary.dart';
import '../models/followup_template.dart';

/// 慢病升级 步骤4：随访计划自动排期（纯计算）。
///
/// 对每个慢病、每个随访项，算出「下次该查的日期」：
///   dueDate = 锚点 + 建议间隔
/// 锚点 = 以下里最新的一个：该项相关指标 / 日常的最近记录、上次「已复查」时间、
/// 疾病确诊日期；都没有则取 (now - 间隔)，即「现在就该查」。

class PlannedFollowUp {
  final String conditionCode;
  final String conditionName;
  final String itemKey;
  final String itemLabel;
  final String title;
  final String? detail;
  final DateTime dueDate;

  const PlannedFollowUp({
    required this.conditionCode,
    required this.conditionName,
    required this.itemKey,
    required this.itemLabel,
    required this.title,
    required this.detail,
    required this.dueDate,
  });

  /// 幂等对齐键：同 (慢病, 随访项) 只保留一条。
  String get dedupeKey => '$conditionCode|$itemKey';
}

/// 规划一个档案的全部随访项。
///
/// [lastCompletedByKey]：dedupeKey → 上次标记「已复查」的时间。
List<PlannedFollowUp> planFollowUps({
  required List<Disease> chronicDiseases,
  required List<HealthMetric> metrics,
  required List<DailyHealthRecord> daily,
  Map<String, DateTime> lastCompletedByKey = const {},
  DateTime? now,
}) {
  final ts = now ?? DateTime.now();
  final out = <PlannedFollowUp>[];
  final seen = <String>{};

  DateTime? latestMetric(List<String> ids) {
    DateTime? best;
    for (final m in metrics) {
      if (!ids.contains(m.metricId)) continue;
      if (best == null || m.measuredAt.isAfter(best)) best = m.measuredAt;
    }
    return best;
  }

  DateTime? latestDaily(List<String> types) {
    DateTime? best;
    for (final d in daily) {
      if (!types.contains(d.type)) continue;
      if (best == null || d.measuredAt.isAfter(best)) best = d.measuredAt;
    }
    return best;
  }

  for (final disease in chronicDiseases) {
    final code = disease.conditionCode;
    if (code == null) continue;
    final tpl = followUpTemplateFor(code);
    if (tpl == null) continue;
    final condName = findChronicCondition(code)?.name ?? disease.name;

    for (final item in tpl.items) {
      final key = '$code|${item.key}';
      if (!seen.add(key)) continue; // 同一档案同病去重

      final anchors = <DateTime>[
        if (latestMetric(item.metricIds) case final d?) d,
        if (latestDaily(item.dailyTypes) case final d?) d,
        if (lastCompletedByKey[key] case final d?) d,
        if (disease.foundDate case final d?) d,
      ];
      // 锚点取不到时（新记的病、没填确诊日期、也没有任何相关记录）：
      // 从「今天」起算，第一次随访排到 今天 + 间隔，不要一记病就「已到期」。
      // 只有真的过了一个间隔还没查，才会到期。
      final anchor = anchors.isEmpty
          ? ts
          : anchors.reduce((a, b) => a.isAfter(b) ? a : b);
      final due = anchor.add(item.interval);

      out.add(PlannedFollowUp(
        conditionCode: code,
        conditionName: condName,
        itemKey: item.key,
        itemLabel: item.label,
        // 标题只放复查项本身；关联的慢性病名字通过 conditionCode 在详情页体现，
        // 不在首页 / 提醒列表标题里高频重复疾病名。
        title: item.label,
        detail: item.note.isEmpty
            ? '关联长期关注：$condName · 建议${item.intervalText}检查一次'
            : '关联长期关注：$condName · 建议${item.intervalText}检查一次。${item.note}',
        dueDate: due,
      ));
    }
  }

  out.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return out;
}
