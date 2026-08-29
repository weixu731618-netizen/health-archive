import '../data/app_database.dart';
import '../data/health_repository.dart';
import 'format.dart';

/// B4：「给医生看的一页纸」的数据模型 —— 从原始表数据汇总出就诊时最需要的信息。
/// 纯逻辑，便于测试；不做任何医疗判断，只按参考范围标注偏高/偏低。

class SummaryMetricLine {
  final String name;
  final String valueText; // 例如 "442 μmol/L"
  final String status; // 偏高 / 偏低 / 异常 …
  final String? referenceText; // 例如 "参考 210–420"
  final DateTime measuredAt;
  final String trend; // '↑' / '↓' / '→' / ''（与上一次比）
  final String? previousText; // 例如 "上次 508（8-01）"

  const SummaryMetricLine({
    required this.name,
    required this.valueText,
    required this.status,
    required this.referenceText,
    required this.measuredAt,
    required this.trend,
    required this.previousText,
  });
}

class SummaryReportLine {
  final DateTime date;
  final String hospital;
  final String type;
  final int metricCount;

  const SummaryReportLine({
    required this.date,
    required this.hospital,
    required this.type,
    required this.metricCount,
  });
}

class MedicalSummary {
  final String personName;
  final String? ageSexLine; // "38 岁 · 男 · 172 cm"
  final DateTime generatedAt;
  final List<String> diseases; // "2型糖尿病（确诊）"
  final List<String> medications; // "二甲双胍缓释片 0.5g 每日2次"
  final List<SummaryMetricLine> abnormalMetrics;
  final List<SummaryReportLine> recentReports;

  const MedicalSummary({
    required this.personName,
    required this.ageSexLine,
    required this.generatedAt,
    required this.diseases,
    required this.medications,
    required this.abnormalMetrics,
    required this.recentReports,
  });

  bool get isEmpty =>
      diseases.isEmpty &&
      medications.isEmpty &&
      abnormalMetrics.isEmpty &&
      recentReports.isEmpty;

  /// 纯文本版（分享文案 / 复制用）。
  String toPlainText() {
    final b = StringBuffer();
    b.writeln('健康摘要 · $personName');
    if (ageSexLine != null && ageSexLine!.isNotEmpty) b.writeln(ageSexLine);
    b.writeln('生成于 ${formatDate(generatedAt)}');
    if (diseases.isNotEmpty) {
      b.writeln('\n【疾病史】');
      for (final d in diseases) {
        b.writeln('· $d');
      }
    }
    if (medications.isNotEmpty) {
      b.writeln('\n【当前用药】');
      for (final m in medications) {
        b.writeln('· $m');
      }
    }
    if (abnormalMetrics.isNotEmpty) {
      b.writeln('\n【近期异常指标】');
      for (final m in abnormalMetrics) {
        final ref = m.referenceText == null ? '' : '（${m.referenceText}）';
        b.writeln(
            '· ${m.name} ${m.valueText} ${m.status}$ref ${m.trend} ${formatDate(m.measuredAt)}');
      }
    }
    if (recentReports.isNotEmpty) {
      b.writeln('\n【近期报告】');
      for (final r in recentReports) {
        b.writeln(
            '· ${formatDate(r.date)} ${r.hospital} ${r.type}（${r.metricCount} 项）');
      }
    }
    b.writeln('\n本摘要由「健康档案」App 生成，仅供就诊参考，不含医疗诊断。');
    return b.toString();
  }
}

String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

bool _isAbnormalStatus(String s) =>
    s.contains('偏高') || s.contains('偏低') || s.contains('异常');

/// 从原始数据汇总。metrics 需按 measuredAt 倒序（`getAllMetrics()` 已如此）。
MedicalSummary buildMedicalSummary({
  required ProfileView? profile,
  required List<Disease> diseases,
  required List<Medication> medications,
  required List<HealthMetric> metrics,
  required List<MedicalReport> reports,
  required Map<int, int> reportMetricCounts,
  DateTime? now,
  int maxAbnormalMetrics = 12,
  int maxRecentReports = 5,
}) {
  final ref = now ?? DateTime.now();

  final name = (profile?.nickname ?? '').trim().isEmpty
      ? '本人'
      : profile!.nickname.trim();

  String? ageSex;
  {
    final parts = <String>[];
    final dob = profile?.birthDate;
    if (dob != null) {
      var age = ref.year - dob.year;
      if (ref.month < dob.month ||
          (ref.month == dob.month && ref.day < dob.day)) {
        age--;
      }
      if (age >= 0 && age < 150) parts.add('$age 岁');
    }
    if ((profile?.gender ?? '').isNotEmpty) parts.add(profile!.gender);
    if (profile?.heightCm != null) {
      parts.add('${_fmtNum(profile!.heightCm!)} cm');
    }
    ageSex = parts.isEmpty ? null : parts.join(' · ');
  }

  final diseaseLines = [
    for (final d in diseases)
      if (d.status != '已恢复')
        d.status.isEmpty || d.status == '不确定'
            ? d.name
            : '${d.name}（${d.status}）',
  ];

  final medLines = <String>[];
  for (final m in medications) {
    if (m.status == '已停用') continue;
    final dose = [
      if ((m.dosage ?? '').isNotEmpty) '${m.dosage}${m.dosageUnit ?? ''}',
      if ((m.timesPerDay ?? '').isNotEmpty) '每日 ${m.timesPerDay} 次',
    ].join(' ');
    medLines.add(dose.isEmpty ? m.name : '${m.name} $dose');
  }

  // 每个 metricId 的最新一条 + 上一条
  final byMetric = <String, List<HealthMetric>>{};
  for (final m in metrics) {
    byMetric.putIfAbsent(m.metricId, () => []).add(m);
  }
  final abnormal = <SummaryMetricLine>[];
  for (final entry in byMetric.entries) {
    final list = entry.value; // 已按 measuredAt 倒序
    final latest = list.first;
    if (!_isAbnormalStatus(latest.status)) continue;
    final prev = list.length > 1 ? list[1] : null;
    var trend = '';
    String? prevText;
    if (prev != null) {
      if (latest.value > prev.value) {
        trend = '↑';
      } else if (latest.value < prev.value) {
        trend = '↓';
      } else {
        trend = '→';
      }
      prevText = '上次 ${_fmtNum(prev.value)}（${formatDate(prev.measuredAt)}）';
    }
    final ref2 = (latest.referenceMin != null && latest.referenceMax != null)
        ? '参考 ${_fmtNum(latest.referenceMin!)}–${_fmtNum(latest.referenceMax!)}'
        : (latest.referenceRangeRaw?.trim().isNotEmpty ?? false)
            ? '参考 ${latest.referenceRangeRaw!.trim()}'
            : null;
    abnormal.add(SummaryMetricLine(
      name: latest.metricName,
      valueText: '${_fmtNum(latest.value)} ${latest.unit}',
      status: latest.status,
      referenceText: ref2,
      measuredAt: latest.measuredAt,
      trend: trend,
      previousText: prevText,
    ));
  }
  abnormal.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));

  final recent = [
    for (final r in reports.take(maxRecentReports))
      SummaryReportLine(
        date: r.reportDate,
        hospital: r.hospitalName.trim().isEmpty ? '医院未知' : r.hospitalName.trim(),
        type: r.reportType.trim().isEmpty ? '报告' : r.reportType.trim(),
        metricCount: reportMetricCounts[r.id] ?? 0,
      ),
  ];

  return MedicalSummary(
    personName: name,
    ageSexLine: ageSex,
    generatedAt: ref,
    diseases: diseaseLines,
    medications: medLines,
    abnormalMetrics: abnormal.take(maxAbnormalMetrics).toList(),
    recentReports: recent,
  );
}
