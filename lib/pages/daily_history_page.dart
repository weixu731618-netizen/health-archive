import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../widgets/health_ui.dart';
import '../main.dart';
import '../utils/format.dart';
import 'daily_health_entry_page.dart';

/// 日常记录（血压 / 血糖 / 体重 / 心率）的历史页：当前值 + 趋势折线图 + 按日期的全部记录。
/// 从「记录」页点某条日常记录进入。样式对齐化验指标的历史页，但不画参考区间线
/// （日常记录没有存参考范围，且血糖有空腹 / 随机之分，硬画一条线容易误导）。
class DailyHistoryPage extends StatefulWidget {
  /// weight / blood_pressure / blood_glucose / heart_rate
  final String type;

  const DailyHistoryPage({super.key, required this.type});

  @override
  State<DailyHistoryPage> createState() => _DailyHistoryPageState();
}

class _DailyHistoryPageState extends State<DailyHistoryPage> {
  List<DailyHealthRecord> _records = [];
  bool _loading = true;
  String? _error;

  bool get _isBp => widget.type == 'blood_pressure';

  String get _title {
    switch (widget.type) {
      case 'blood_pressure':
        return '血压';
      case 'blood_glucose':
        return '血糖';
      case 'weight':
        return '体重';
      case 'waist':
        return '腰围';
      case 'heart_rate':
        return '心率';
      default:
        return '日常记录';
    }
  }

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
        if (mounted) {
          setState(() {
            _records = const [];
            _loading = false;
            _error = null;
          });
        }
        return;
      }
      final list = await repo.getDailyRecordsByType(widget.type);
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

  DailyHealthRecord? get _latest => _records.isEmpty ? null : _records.first;

  String _valueText(DailyHealthRecord r) {
    if (_isBp) {
      return '${_fmt(r.value1)} / ${_fmt(r.value2 ?? 0)} ${r.unit}';
    }
    return '${_fmt(r.value1)} ${r.unit}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_title · 历史')),
      body: RefreshIndicator.adaptive(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    _latest == null ? '暂无记录' : _valueText(_latest!),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.textPrimary),
                  ),
                  if (_latest != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '最新：${formatDateCn(_latest!.measuredAt)}'
                      '${(_latest!.context ?? '').isEmpty ? '' : ' · ${_latest!.context}'}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!_loading && _error == null && _records.length >= 2)
              HealthCard(child: _buildChart()),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
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
            else ...[
              const HealthSectionHeader('全部记录'),
              HealthCard(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                child: Column(
                  children: [
                    for (final r in _records)
                      HealthRow(
                        title: _valueText(r),
                        subtitle: '${formatDate(r.measuredAt)}'
                            '${(r.context ?? '').isEmpty ? '' : ' · ${r.context}'}'
                            '${(r.notes ?? '').isEmpty ? '' : ' · ${r.notes}'}',
                        onTap: () => _edit(r),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_records.length < 2) return const SizedBox.shrink();
    final points = _records.reversed.toList(); // 时间正序

    final ys = <double>[
      for (final p in points) p.value1,
      if (_isBp)
        for (final p in points) (p.value2 ?? p.value1),
    ];
    var lo = ys.reduce((a, b) => a < b ? a : b);
    var hi = ys.reduce((a, b) => a > b ? a : b);
    final span = hi - lo;
    final pad = span <= 0 ? (hi.abs() * 0.1 + 1) : span * 0.2;
    final minY = lo - pad;
    final maxY = hi + pad;
    final labelStep = (points.length / 5).ceil().clamp(1, 1000);

    List<FlSpot> spots(double Function(DailyHealthRecord) sel) => [
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), sel(points[i])),
        ];

    final bars = <LineChartBarData>[
      LineChartBarData(
        spots: spots((r) => r.value1),
        isCurved: false,
        color: AppColors.primary,
        barWidth: 2,
        dotData: const FlDotData(show: true),
      ),
      if (_isBp)
        LineChartBarData(
          spots: spots((r) => r.value2 ?? r.value1),
          isCurved: false,
          color: AppColors.textSecondary,
          barWidth: 2,
          dotData: const FlDotData(show: true),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
      child: Column(
          children: [
            if (_isBp)
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  children: [
                    _LegendDot(color: AppColors.primary, text: '收缩压'),
                    SizedBox(width: 16),
                    _LegendDot(color: AppColors.textSecondary, text: '舒张压'),
                  ],
                ),
              ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
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
                                  fontSize: 10,
                                  color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem(
                            '${_fmt(s.y)}\n'
                            '${formatDate(points[s.x.toInt()].measuredAt)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: bars,
                ),
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _edit(DailyHealthRecord r) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DailyEditPage(record: r)),
    );
    if (ok == true && mounted) _load();
  }

}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
