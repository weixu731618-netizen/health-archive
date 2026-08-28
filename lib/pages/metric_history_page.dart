import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import 'manual_metric_entry_page.dart';
import 'report_detail_page.dart';

/// 某个指标的历史记录页：显示当前值 + 按日期排序的历史列表。
class MetricHistoryPage extends StatefulWidget {
  final String metricId;
  final String metricName;
  final String unit;

  const MetricHistoryPage({
    super.key,
    required this.metricId,
    required this.metricName,
    required this.unit,
  });

  @override
  State<MetricHistoryPage> createState() => _MetricHistoryPageState();
}

class _MetricHistoryPageState extends State<MetricHistoryPage> {
  List<HealthMetric> _records = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = appRepository;
      if (repo == null) {
        // 无数据库（如测试/预览环境）：不报错，展示空历史
        if (mounted) {
          setState(() {
            _records = const [];
            _loading = false;
            _error = null;
          });
        }
        return;
      }
      final list = await repo.getMetricHistory(widget.metricId);
      if (mounted) {
        setState(() {
          _records = list;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败：$e';
        });
      }
    }
  }

  HealthMetric? get _latest => _records.isEmpty ? null : _records.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _load();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // 顶部：指标名 + 当前值
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.metricName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _latest == null
                          ? '暂无记录'
                          : '${_latest!.value} ${_latest!.unit}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    if (_latest != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '最新：${formatDateCn(_latest!.measuredAt)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_loading && _error == null) _buildChart(),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(_error!,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else if (_records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('暂无历史记录',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else
              for (final r in _records) ...[
                Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      '${fmtLocal(r.value)} ${r.unit}',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      _historySubtitle(r),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    trailing: r.reportId == null
                        ? null
                        : const Icon(Icons.receipt_long_outlined,
                            color: AppColors.textSecondary),
                    onTap: () => _openRecord(r),
                    onLongPress: () => _editRecord(r),
                  ),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  /// 趋势折线图：按时间正序排列，每个点按当时状态着色；
  /// 若最新记录有参考范围，用虚线标出正常区间上下限。
  Widget _buildChart() {
    if (_records.length < 2) return const SizedBox.shrink();
    final points = _records.reversed.toList(); // 转成按时间正序

    final values = [for (final p in points) p.value];
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    final refMin = _latest?.referenceMin;
    final refMax = _latest?.referenceMax;
    final hasRange = refMin != null && refMax != null;
    if (hasRange) {
      lo = lo < refMin ? lo : refMin;
      hi = hi > refMax ? hi : refMax;
    }
    final span = hi - lo;
    final pad = span <= 0 ? (hi.abs() * 0.1 + 1) : span * 0.2;
    final minY = lo - pad;
    final maxY = hi + pad;
    final labelStep = (points.length / 5).ceil().clamp(1, 1000);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= points.length) {
                        return const SizedBox.shrink();
                      }
                      if (i % labelStep != 0 && i != points.length - 1) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          formatDateShort(points[i].measuredAt),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: !hasRange
                  ? const ExtraLinesData()
                  : ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: refMin,
                        color: AppColors.textSecondary,
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                      HorizontalLine(
                        y: refMax,
                        color: AppColors.textSecondary,
                        strokeWidth: 1,
                        dashArray: const [4, 4],
                      ),
                    ]),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      LineTooltipItem(
                        '${fmtLocal(points[s.x.toInt()].value)} ${widget.unit}\n'
                        '${formatDate(points[s.x.toInt()].measuredAt)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), points[i].value),
                  ],
                  isCurved: false,
                  color: AppColors.primary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: valueStatusColor(points[index].status),
                      strokeColor: Colors.white,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editRecord(HealthMetric m) async {
    final repo = appRepository;
    if (repo == null) return;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('操作'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('编辑'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('删除'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (!mounted) return;

    if (result) {
      // 编辑
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ManualMetricEntryPage(metric: m)),
      );
      if (!mounted) return;
    } else {
      // 删除（二次确认）
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('确定删除这条健康记录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirm == true) {
        await repo.deleteMetric(m.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('已删除')));
      }
    }
    if (mounted) _load();
  }

  Future<void> _openRecord(HealthMetric m) async {
    final reportId = m.reportId;
    if (reportId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReportDetailPage(reportId: reportId)),
      );
      if (mounted) _load();
      return;
    }
    await _editRecord(m);
  }

  String _historySubtitle(HealthMetric r) {
    final parts = <String>[
      formatDate(r.measuredAt),
      r.status,
    ];
    if (r.referenceRangeRaw != null && r.referenceRangeRaw!.isNotEmpty) {
      parts.add('参考 ${r.referenceRangeRaw}');
    } else if (r.referenceMin != null || r.referenceMax != null) {
      parts.add(
        '参考 ${r.referenceMin == null ? '—' : fmtLocal(r.referenceMin!)}'
        '-${r.referenceMax == null ? '—' : fmtLocal(r.referenceMax!)}',
      );
    }
    if (r.sourceAbnormalFlag != null && r.sourceAbnormalFlag!.isNotEmpty) {
      parts.add('报告标记 ${r.sourceAbnormalFlag}');
    }
    parts.add(_verificationLabel(r.verificationStatus));
    if (r.reportId != null) parts.add('来源报告 #${r.reportId}');
    return parts.join(' · ');
  }

  String _verificationLabel(String status) {
    switch (status) {
      case 'user_modified':
        return '用户已修改';
      case 'user_confirmed':
        return '用户已确认';
      default:
        return '待核对';
    }
  }
}

String fmtLocal(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
