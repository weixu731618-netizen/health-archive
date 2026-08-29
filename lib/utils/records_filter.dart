import 'package:flutter/material.dart' show DateTimeRange;

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../models/body_area_health.dart';

/// B3：记录页的搜索 / 筛选条件 + 匹配判定（纯逻辑，便于测试）。
class RecordFilter {
  /// 关键词（医院名 / 报告类型 / 结论文字 / 指标名 / 标签 / 记录标题）
  final String query;

  /// 只看异常
  final bool abnormalOnly;

  /// 标签（命中任意一个即可）
  final Set<String> tags;

  /// 医院（命中任意一个即可）
  final Set<String> hospitals;

  /// 时间范围（null = 不限）
  final DateTimeRange? dateRange;

  const RecordFilter({
    this.query = '',
    this.abnormalOnly = false,
    this.tags = const {},
    this.hospitals = const {},
    this.dateRange,
  });

  RecordFilter copyWith({
    String? query,
    bool? abnormalOnly,
    Set<String>? tags,
    Set<String>? hospitals,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return RecordFilter(
      query: query ?? this.query,
      abnormalOnly: abnormalOnly ?? this.abnormalOnly,
      tags: tags ?? this.tags,
      hospitals: hospitals ?? this.hospitals,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }

  /// 除关键词外，是否还有生效的筛选条件（用于「筛选」按钮上的数字徽标）。
  int get activeCount =>
      (abnormalOnly ? 1 : 0) +
      (tags.isEmpty ? 0 : 1) +
      (hospitals.isEmpty ? 0 : 1) +
      (dateRange == null ? 0 : 1);

  bool get isReportOnly => tags.isNotEmpty || hospitals.isNotEmpty;

  bool _inRange(DateTime d) {
    final r = dateRange;
    if (r == null) return true;
    final day = DateTime(d.year, d.month, d.day);
    final start = DateTime(r.start.year, r.start.month, r.start.day);
    final end = DateTime(r.end.year, r.end.month, r.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  bool _q(Iterable<String?> haystacks) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    for (final h in haystacks) {
      if (h != null && h.toLowerCase().contains(needle)) return true;
    }
    return false;
  }

  /// 报告是否命中。[metricNames]/[hasAbnormalMetric] 由调用方按该报告的指标预先算好。
  bool matchesReport(
    MedicalReport r, {
    required List<String> metricNames,
    required bool hasAbnormalMetric,
  }) {
    if (!_inRange(r.reportDate)) return false;
    if (hospitals.isNotEmpty && !hospitals.contains(r.hospitalName.trim())) {
      return false;
    }
    final reportTags = HealthRepository.parseTags(r.tags);
    if (tags.isNotEmpty && !reportTags.any(tags.contains)) return false;
    if (abnormalOnly && !hasAbnormalMetric) return false;
    return _q([
      r.hospitalName,
      r.reportType,
      r.rawText,
      reportTags.join(' '),
      metricNames.join(' '),
    ]);
  }

  /// 手工录入 / 日常记录 条目是否命中。
  /// [title]/[subtitle]/[status]/[measuredAt] 来自记录页的 RealEntry。
  bool matchesEntry({
    required String title,
    required String subtitle,
    required String status,
    required DateTime measuredAt,
  }) {
    // 报告专属筛选（标签 / 医院）生效时，非报告条目一律不显示。
    if (isReportOnly) return false;
    if (!_inRange(measuredAt)) return false;
    if (abnormalOnly && !_isAbnormal(status)) return false;
    return _q([title, subtitle]);
  }

  static bool _isAbnormal(String status) =>
      isMetricAbnormalStatus(status) || status.contains('异常');
}

/// 常见的时间范围预设。
enum RecordDatePreset { all, month1, month3, year1, custom }

DateTimeRange? presetToRange(RecordDatePreset p, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (p) {
    case RecordDatePreset.month1:
      return DateTimeRange(
          start: today.subtract(const Duration(days: 30)), end: today);
    case RecordDatePreset.month3:
      return DateTimeRange(
          start: today.subtract(const Duration(days: 90)), end: today);
    case RecordDatePreset.year1:
      return DateTimeRange(
          start: today.subtract(const Duration(days: 365)), end: today);
    case RecordDatePreset.all:
    case RecordDatePreset.custom:
      return null;
  }
}
