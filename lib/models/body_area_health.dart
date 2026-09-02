import '../data/app_database.dart';
import 'metric_dictionary.dart';

/// 身体页一级导航 = 器官 / 身体系统，全部同一层级。
/// 指标分类（血糖 / 血脂 / 电解质 / 肝功能 / 肾功能 / 肿瘤标志物…）不进这一层，
/// 它们下沉到所属器官 / 系统内部，见 [metricGroupLabelForSystem]。
const List<String> coreBodyAreaOrder = [
  '心血管',
  '呼吸系统',
  '消化系统',
  '肝胆',
  '胰腺',
  '肾脏/泌尿',
  '内分泌/代谢',
  '血液系统',
  '眼睛',
  '耳鼻喉',
  '口腔牙齿',
  '骨骼关节',
  '皮肤与足部',
  '生殖系统',
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

  /// 匹配上了核心指标词典（metricId != 'UNKNOWN'）。false = 只收录展示，
  /// 不参与器官判定 / 趋势 / 需关注。
  final bool standardized;

  /// 仅提示、不报警（肿瘤标志物 / 急性指标）。不参与器官判定 / 需关注，
  /// 但仍在详情页显示。
  final bool advisoryOnly;

  const BodyAreaMetricEvidence({
    required this.metricId,
    required this.name,
    required this.valueText,
    required this.status,
    this.measuredAt,
    this.reportId,
    this.referenceMin,
    this.referenceMax,
    this.standardized = true,
    this.advisoryOnly = false,
  });

  /// 参与器官判定 / 趋势 / 首页需关注的指标。
  bool get counts => standardized && !advisoryOnly;

  bool get isAbnormal => isMetricAbnormalStatus(status);
  bool get needsAttention => isAbnormal || isMetricAttentionStatus(status);

  /// 详情页里所属的「指标分类」小标题（血糖 / 电解质 / 肝功能…）。
  String get groupLabel {
    final def = findMetricDefinition(metricId);
    return metricGroupLabelForSystem(def?.bodySystem ?? '');
  }
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

  int get abnormalCount =>
      metrics.where((m) => m.isAbnormal && m.counts).length;

  DateTime? get latestMeasuredAt {
    DateTime? latest;
    for (final m in metrics) {
      final d = m.measuredAt;
      if (d != null && (latest == null || d.isAfter(latest))) latest = d;
    }
    return latest;
  }

  BodyAreaMetricEvidence? get keyMetric {
    final pool = metrics.where((m) => m.counts).toList();
    if (pool.isEmpty) return null;
    pool.sort(compareMetricEvidence);
    return pool.first;
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

/// 指标字典里的 `bodySystem` → 身体页一级器官 / 系统。
/// 指标分类级别的值（血糖代谢 / 电解质 / 甲状腺 / 肿瘤标志物…）在这里被归并进
/// 所属器官 / 系统，不再单独成为一级节点。未知值一律落到「其他」。
String bodyAreaForSystem(String system) {
  switch (system.trim()) {
    case '肾脏':
    case '尿常规':
    case '泌尿':
    case '泌尿系统':
    case '电解质': // 电解质随肾脏/泌尿一起看
      return '肾脏/泌尿';
    case '肝脏':
    case '肝胆':
    case '胆囊':
      return '肝胆';
    case '胰腺':
      return '胰腺';
    case '血糖代谢':
    case '代谢':
    case '内分泌':
    case '甲状腺': // 甲状腺归入内分泌/代谢
      return '内分泌/代谢';
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
    case '呼吸':
    case '呼吸系统':
    case '肺':
      return '呼吸系统';
    case '消化':
    case '消化系统':
    case '胃肠':
      return '消化系统';
    case '生殖':
    case '生殖系统':
    case '前列腺':
    case '妇科':
      return '生殖系统';
    case '心血管':
      return '心血管';
    case '血液':
    case '血液系统':
    case '凝血': // 凝血功能随血液系统一起看
      return '血液系统';
    default:
      return '其他';
  }
}

/// 器官 / 系统详情页里，把指标再按「指标分类」分组显示时用的小标题。
/// 入参是指标字典的 `bodySystem`。返回 null 表示不额外分组（归到「其他指标」）。
String metricGroupLabelForSystem(String system) {
  switch (system.trim()) {
    case '血糖代谢':
      return '血糖';
    case '甲状腺':
      return '甲状腺';
    case '电解质':
      return '电解质';
    case '肾脏':
      return '肾功能';
    case '尿常规':
      return '尿液';
    case '肝脏':
      return '肝功能';
    case '心血管':
      return '血脂 / 心血管';
    case '血液':
      return '血常规';
    case '骨骼':
      return '骨代谢';
    case '肿瘤标志物':
      return '肿瘤标志物';
    default:
      return '其他指标';
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
  List<HealthMetric> rawMetrics, {
  bool includeEmptyCoreAreas = true,
}) {
  // Round 3b：未匹配核心词典的（metricId='UNKNOWN'）不再直接丢掉——它们进器官
  // 详情页的「其他指标」区照实展示，但 `standardized=false`，不参与器官判定 /
  // 趋势 / 首页需关注（见 BodyAreaMetricEvidence.counts）。
  // 用 metricId 而非 matchType 判断：入库时 metricId = matchedMetricId ?? 'UNKNOWN'，
  // 比 matchType 可靠（历史数据里 matchType 一度未被正确写入）。
  final latestByMetric = <String, HealthMetric>{};
  for (final m in rawMetrics) {
    final area = bodyAreaForSystem(m.bodySystem);
    // 未标准化的按 (area, 名字) 去重（同一 UNKNOWN 指标 id 都一样，不能用 id）。
    final key = m.metricId == 'UNKNOWN'
        ? '$area:UNKNOWN:${m.metricName}'
        : '$area:${m.metricId}';
    final existing = latestByMetric[key];
    if (existing == null || m.measuredAt.isAfter(existing.measuredAt)) {
      latestByMetric[key] = m;
    }
  }

  final byArea = <String, List<BodyAreaMetricEvidence>>{};
  for (final m in latestByMetric.values) {
    final area = bodyAreaForSystem(m.bodySystem);
    final def = m.metricId == 'UNKNOWN' ? null : findMetricDefinition(m.metricId);
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
            standardized: m.metricId != 'UNKNOWN',
            advisoryOnly: def?.advisoryOnly ?? false,
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
    final area = bodyAreaForSystem(m.bodySystem);
    // 未匹配核心词典的指标只有落到某个真实器官时才算「关联」；
    // 归不出（'其他'）的不把报告拽进「其他」器官。
    if (m.metricId == 'UNKNOWN' && area == '其他') continue;
    areas.add(area);
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

/// 日常记录类型（血压 / 血糖 / 体重 / 心率 / 腰围）→ 一级器官 / 系统。
Set<String> areasForDailyType(String type) {
  switch (type) {
    case 'blood_pressure':
    case 'heart_rate':
      return const {'心血管'};
    case 'blood_glucose':
    case 'weight':
    case 'waist':
      return const {'内分泌/代谢'};
    default:
      return const {};
  }
}

/// 某类日常记录在器官卡 / 概览行里的一句话（如「血压 138/88」）。
String dailyReadingHint(String type, double value1, double? value2) {
  String n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  switch (type) {
    case 'blood_pressure':
      return '血压 ${n(value1)}/${value2 == null ? '' : n(value2)}';
    case 'blood_glucose':
      return '血糖 ${n(value1)}';
    case 'weight':
      return '体重 ${n(value1)}';
    case 'heart_rate':
      return '心率 ${n(value1)}';
    case 'waist':
      return '腰围 ${n(value1)}';
    default:
      return n(value1);
  }
}

String _statusFromMetrics(List<BodyAreaMetricEvidence> metrics) {
  // 只有核心指标（standardized 且非 advisoryOnly）参与器官判定。
  final judged = metrics.where((m) => m.counts).toList();
  if (judged.isEmpty) return '数据不足';
  if (judged.any((m) => m.status.contains('异常'))) return '异常';
  if (judged.any((m) => m.needsAttention)) return '需关注';
  if (judged.every((m) => m.status.contains('正常'))) return '正常';
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
