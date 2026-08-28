import '../data/app_database.dart';
import 'metric_dictionary.dart';

const List<String> coreBodyAreaOrder = [
  '肾脏/泌尿',
  '心血管',
  '肝胆',
  '代谢',
  '甲状腺',
  '血液',
  '电解质',
  '皮肤与足部',
  '口腔牙齿',
  '眼睛',
  '耳鼻喉',
  '骨骼关节',
  '其他',
];

class BodyAreaMetricEvidence {
  final String metricId;
  final String name;
  final String valueText;
  final String status;
  final DateTime? measuredAt;
  final int? reportId;
  final double? referenceMin;
  final double? referenceMax;

  const BodyAreaMetricEvidence({
    required this.metricId,
    required this.name,
    required this.valueText,
    required this.status,
    this.measuredAt,
    this.reportId,
    this.referenceMin,
    this.referenceMax,
  });

  bool get isAbnormal => isMetricAbnormalStatus(status);
  bool get needsAttention => isAbnormal || isMetricAttentionStatus(status);
}

class BodyAreaHealthSummary {
  final String name;
  final String status;
  final List<BodyAreaMetricEvidence> metrics;

  const BodyAreaHealthSummary({
    required this.name,
    required this.status,
    required this.metrics,
  });

  int get abnormalCount => metrics.where((m) => m.isAbnormal).length;

  DateTime? get latestMeasuredAt {
    DateTime? latest;
    for (final m in metrics) {
      final d = m.measuredAt;
      if (d != null && (latest == null || d.isAfter(latest))) latest = d;
    }
    return latest;
  }

  BodyAreaMetricEvidence? get keyMetric {
    if (metrics.isEmpty) return null;
    final sorted = [...metrics]..sort(compareMetricEvidence);
    return sorted.first;
  }

  int get priorityRank {
    if (status == '异常') return 0;
    if (status == '需关注') return 1;
    if (status == '正常') return 2;
    return 3;
  }
}

class HealthTopicSummary {
  final String name;
  final int recordCount;
  final DateTime? latestMeasuredAt;
  final int pendingReviewCount;
  final int sourceFlagCount;

  const HealthTopicSummary({
    required this.name,
    required this.recordCount,
    this.latestMeasuredAt,
    this.pendingReviewCount = 0,
    this.sourceFlagCount = 0,
  });

  String get statusLabel {
    if (recordCount == 0) return '暂无资料';
    if (pendingReviewCount > 0) return '$pendingReviewCount 项待核对';
    if (sourceFlagCount > 0) return '$sourceFlagCount 项报告标记';
    return '$recordCount 份资料';
  }

  String get summaryText {
    final parts = <String>['$recordCount 份相关资料'];
    if (sourceFlagCount > 0) parts.add('$sourceFlagCount 项报告原标记');
    if (pendingReviewCount > 0) parts.add('$pendingReviewCount 项待核对');
    return parts.join(' · ');
  }
}

String bodyAreaForSystem(String system) {
  switch (system.trim()) {
    case '肾脏':
    case '尿常规':
    case '泌尿':
    case '泌尿系统':
      return '肾脏/泌尿';
    case '肝脏':
    case '肝胆':
      return '肝胆';
    case '血糖代谢':
    case '代谢':
    case '内分泌':
      return '代谢';
    case '皮肤':
    case '足部':
    case '皮肤与足部':
      return '皮肤与足部';
    case '牙齿':
    case '口腔':
    case '口腔牙齿':
      return '口腔牙齿';
    case '眼部':
    case '眼睛':
      return '眼睛';
    case '耳鼻喉':
      return '耳鼻喉';
    case '骨骼':
    case '关节':
    case '骨骼关节':
      return '骨骼关节';
    case '心血管':
    case '甲状腺':
    case '血液':
    case '电解质':
      return system.trim();
    default:
      return system.trim().isEmpty ? '其他' : system.trim();
  }
}

bool isMetricAbnormalStatus(String status) {
  return status.contains('异常') ||
      status.contains('偏高') ||
      status.contains('偏低');
}

bool isMetricAttentionStatus(String status) {
  return status.contains('关注') ||
      status.contains('上升') ||
      status.contains('下降') ||
      status.contains('轻微');
}

String normalizedBodyAreaStatus(String status) {
  if (status.contains('异常')) return '异常';
  if (isMetricAbnormalStatus(status) || isMetricAttentionStatus(status)) {
    return '需关注';
  }
  if (status.contains('正常') || status.contains('稳定')) return '正常';
  return '数据不足';
}

int compareMetricEvidence(BodyAreaMetricEvidence a, BodyAreaMetricEvidence b) {
  final aAttention = a.needsAttention ? 0 : 1;
  final bAttention = b.needsAttention ? 0 : 1;
  if (aAttention != bAttention) return aAttention.compareTo(bAttention);
  final ad = a.measuredAt;
  final bd = b.measuredAt;
  if (ad != null && bd != null) return bd.compareTo(ad);
  if (ad != null) return -1;
  if (bd != null) return 1;
  return a.name.compareTo(b.name);
}

int compareBodyAreaSummary(
  BodyAreaHealthSummary a,
  BodyAreaHealthSummary b,
) {
  final rank = a.priorityRank.compareTo(b.priorityRank);
  if (rank != 0) return rank;

  final abnormal = b.abnormalCount.compareTo(a.abnormalCount);
  if (abnormal != 0) return abnormal;

  final ad = a.latestMeasuredAt;
  final bd = b.latestMeasuredAt;
  if (ad != null && bd != null) return bd.compareTo(ad);
  if (ad != null) return -1;
  if (bd != null) return 1;

  return _bodyAreaOrder(a.name).compareTo(_bodyAreaOrder(b.name));
}

List<BodyAreaHealthSummary> buildBodyAreaHealthFromMetrics(
  List<HealthMetric> metrics, {
  bool includeEmptyCoreAreas = true,
}) {
  final latestByMetric = <String, HealthMetric>{};
  for (final m in metrics) {
    final area = bodyAreaForSystem(m.bodySystem);
    final key = '$area:${m.metricId}';
    final existing = latestByMetric[key];
    if (existing == null || m.measuredAt.isAfter(existing.measuredAt)) {
      latestByMetric[key] = m;
    }
  }

  final byArea = <String, List<BodyAreaMetricEvidence>>{};
  for (final m in latestByMetric.values) {
    final area = bodyAreaForSystem(m.bodySystem);
    byArea.putIfAbsent(area, () => []).add(
          BodyAreaMetricEvidence(
            metricId: m.metricId,
            name: m.metricName,
            valueText: '${_fmt(m.value)} ${m.unit}',
            status: m.status,
            measuredAt: m.measuredAt,
            reportId: m.reportId,
            referenceMin: m.referenceMin,
            referenceMax: m.referenceMax,
          ),
        );
  }

  if (includeEmptyCoreAreas) {
    for (final area in coreBodyAreaOrder) {
      byArea.putIfAbsent(area, () => []);
    }
  }

  final summaries = [
    for (final entry in byArea.entries)
      BodyAreaHealthSummary(
        name: entry.key,
        status: _statusFromMetrics(entry.value),
        metrics: [...entry.value]..sort(compareMetricEvidence),
      ),
  ]..sort(compareBodyAreaSummary);

  return summaries;
}

List<HealthTopicSummary> buildHealthTopicSummaries(
  List<HealthMetric> metrics, {
  bool includeEmptyCoreAreas = true,
}) {
  final byArea = <String, List<HealthMetric>>{};
  for (final m in metrics) {
    final area = bodyAreaForSystem(m.bodySystem);
    byArea.putIfAbsent(area, () => []).add(m);
  }
  if (includeEmptyCoreAreas) {
    for (final area in coreBodyAreaOrder) {
      byArea.putIfAbsent(area, () => []);
    }
  }

  final summaries = [
    for (final entry in byArea.entries)
      _buildTopicSummary(entry.key, entry.value),
  ]..sort(_compareTopicSummary);
  return summaries;
}

HealthTopicSummary _buildTopicSummary(String area, List<HealthMetric> metrics) {
  final reportIds = <int>{};
  var manualCount = 0;
  var pending = 0;
  var sourceFlags = 0;
  DateTime? latest;

  for (final m in metrics) {
    final reportId = m.reportId;
    if (reportId == null) {
      manualCount++;
    } else {
      reportIds.add(reportId);
    }
    if (m.verificationStatus != 'user_confirmed' &&
        m.verificationStatus != 'user_modified') {
      pending++;
    }
    if (m.sourceAbnormalFlag != null && m.sourceAbnormalFlag!.isNotEmpty) {
      sourceFlags++;
    }
    if (latest == null || m.measuredAt.isAfter(latest)) latest = m.measuredAt;
  }

  return HealthTopicSummary(
    name: area,
    recordCount: reportIds.length + manualCount,
    latestMeasuredAt: latest,
    pendingReviewCount: pending,
    sourceFlagCount: sourceFlags,
  );
}

int _compareTopicSummary(HealthTopicSummary a, HealthTopicSummary b) {
  final aHasData = a.recordCount > 0 ? 0 : 1;
  final bHasData = b.recordCount > 0 ? 0 : 1;
  if (aHasData != bHasData) return aHasData.compareTo(bHasData);

  final pending = b.pendingReviewCount.compareTo(a.pendingReviewCount);
  if (pending != 0) return pending;

  final flags = b.sourceFlagCount.compareTo(a.sourceFlagCount);
  if (flags != 0) return flags;

  final ad = a.latestMeasuredAt;
  final bd = b.latestMeasuredAt;
  if (ad != null && bd != null) return bd.compareTo(ad);
  if (ad != null) return -1;
  if (bd != null) return 1;

  return _bodyAreaOrder(a.name).compareTo(_bodyAreaOrder(b.name));
}

List<String> affectedBodyAreasForMetrics(Iterable<HealthMetric> metrics) {
  final areas = <String>{};
  for (final m in metrics) {
    areas.add(bodyAreaForSystem(m.bodySystem));
  }
  final list = areas.toList();
  list.sort((a, b) => _bodyAreaOrder(a).compareTo(_bodyAreaOrder(b)));
  return list;
}

List<String> affectedBodyAreasForRawMetricNames(Iterable<String> names) {
  final areas = <String>{};
  for (final name in names) {
    final def = matchMetric(name);
    areas.add(bodyAreaForSystem(def?.bodySystem ?? '其他'));
  }
  final list = areas.toList();
  list.sort((a, b) => _bodyAreaOrder(a).compareTo(_bodyAreaOrder(b)));
  return list;
}

String _statusFromMetrics(List<BodyAreaMetricEvidence> metrics) {
  if (metrics.isEmpty) return '数据不足';
  if (metrics.any((m) => m.status.contains('异常'))) return '异常';
  if (metrics.any((m) => m.needsAttention)) return '需关注';
  if (metrics.every((m) => m.status.contains('正常'))) return '正常';
  return '数据不足';
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

int _bodyAreaOrder(String area) {
  final i = coreBodyAreaOrder.indexOf(area);
  return i == -1 ? coreBodyAreaOrder.length : i;
}
