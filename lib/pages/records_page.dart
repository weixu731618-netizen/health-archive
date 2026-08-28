import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import 'daily_health_entry_page.dart';
import 'manual_metric_entry_page.dart';
import 'report_detail_page.dart';

/// 记录页面：仅展示用户实际录入或导入的数据。
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  int _filterIndex = 0;
  static const List<String> _filters = ['全部来源', '报告', '日常记录'];

  List<RealEntry> _real = [];
  List<MedicalReport> _reports = [];
  Map<int, int> _reportMetricCounts = {};
  Map<int, List<String>> _reportAffectedAreas = {};
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
      if (repo != null) {
        final metrics = await repo.getAllMetrics();
        final dailies = await repo.getAllDailyRecords();
        final reports = await repo.getAllReports();
        final entries = <RealEntry>[
          for (final m in metrics) RealEntry.metric(m),
          for (final d in dailies) RealEntry.daily(d),
        ];
        entries.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
        // 计算每份报告的指标数量
        final counts = <int, int>{};
        final affectedAreas = <int, List<String>>{};
        for (final r in reports) {
          final reportMetrics = await repo.getMetricsByReport(r.id);
          counts[r.id] = reportMetrics.length;
          affectedAreas[r.id] = affectedBodyAreasForMetrics(reportMetrics);
        }
        if (mounted) {
          setState(() {
            _real = entries;
            _reports = reports;
            _reportMetricCounts = counts;
            _reportAffectedAreas = affectedAreas;
            _loading = false;
            _error = null;
          });
        }
      } else {
        // 无数据库（如测试/预览环境）：当作空数据，不注入演示内容。
        if (mounted) {
          setState(() {
            _real = const [];
            _loading = false;
            _error = null;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('资料来源')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // 底部多留一点空间，避免最后一项被悬浮的"添加"按钮挡住。
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                '报告、手工录入和日常记录作为身体状态的来源证据保留在这里。',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            Row(
              children: [
                for (int i = 0; i < _filters.length; i++) ...[
                  ChoiceChip(
                    label: Text(_filters[i]),
                    selected: _filterIndex == i,
                    onSelected: (_) => setState(() => _filterIndex = i),
                  ),
                  if (i < _filters.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              )
            else if (_filteredReal.isEmpty && _visibleReports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '还没有录入数据，去「添加」页手动录入或记录日常健康吧',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              )
            else ...[
              for (final r in _visibleReports) ...[
                _ReportTile(
                  report: r,
                  metricCount: _reportMetricCounts[r.id] ?? 0,
                  affectedAreas: _reportAffectedAreas[r.id] ?? const [],
                  onTap: () => _openReport(context, r),
                ),
                const SizedBox(height: 12),
              ],
              if (_visibleReports.isNotEmpty) const SizedBox(height: 8),
              for (final entry in _filteredReal) ...[
                _RealTile(
                  entry: entry,
                  onTap: () => _openReal(context, entry),
                  onLongPress: () => _openReal(context, entry),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// 根据当前筛选条件过滤后的真实数据列表
  List<RealEntry> get _filteredReal {
    switch (_filterIndex) {
      case 1: // 报告
        return _real.where((e) => e.source == '报告导入').toList();
      case 2: // 日常记录
        return _real.where((e) => e.source == '日常记录').toList();
      default: // 全部
        return _real;
    }
  }

  /// 根据当前筛选条件过滤后的报告列表（报告属于医院检查性质）
  List<MedicalReport> get _visibleReports {
    if (_filterIndex == 2) return const []; // 日常记录筛选下不显示报告
    return _reports;
  }

  Future<void> _openReport(BuildContext context, MedicalReport report) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailPage(reportId: report.id),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _openReal(BuildContext context, RealEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EntryDetailPage(entry: entry)),
    );
    if (mounted) _load();
  }
}

/// 记录页里的一条真实数据（手工录入 或 日常记录）
class RealEntry {
  final int? metricId;
  final int? dailyId;
  final String title;
  final String subtitle;
  final String status;
  final String source; // 手工录入 / 日常记录
  final DateTime measuredAt;

  RealEntry.metric(HealthMetric m)
      : metricId = m.id,
        dailyId = null,
        title = m.metricName,
        subtitle = _valueText(m.value, m.unit) +
            (m.referenceMin == null || m.referenceMax == null
                ? ''
                : '  (参考 ${fmtNum(m.referenceMin!)}–${fmtNum(m.referenceMax!)} ${m.unit})'),
        status = m.status,
        source = sourceTypeLabel(m.sourceType),
        measuredAt = m.measuredAt;

  RealEntry.daily(DailyHealthRecord d)
      : metricId = null,
        dailyId = d.id,
        title = _dailyTitle(d),
        subtitle = _dailySubtitle(d),
        status = '',
        source = '日常记录',
        measuredAt = d.measuredAt;

  static String _dailyTitle(DailyHealthRecord d) {
    switch (d.type) {
      case 'blood_pressure':
        return '血压';
      case 'blood_glucose':
        return '血糖';
      case 'weight':
        return '体重';
      case 'heart_rate':
        return '心率';
      default:
        return '日常记录';
    }
  }

  static String _dailySubtitle(DailyHealthRecord d) {
    switch (d.type) {
      case 'blood_pressure':
        return '${fmtNum(d.value1)} / ${fmtNum(d.value2!)} ${d.unit}${d.context == null ? '' : '  ${d.context}'}';
      case 'blood_glucose':
        return '${fmtNum(d.value1)} ${d.unit}${d.context == null ? '' : '（${d.context}）'}';
      case 'weight':
      case 'heart_rate':
        return '${fmtNum(d.value1)} ${d.unit}';
      default:
        return '${fmtNum(d.value1)} ${d.unit}';
    }
  }
}

String fmtNum(num v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

String _valueText(double value, String unit) => '${fmtNum(value)} $unit';

/// 根据数据来源类型返回展示文案。
/// 目前只使用 manual / daily；future_ocr / future_hospital 为未来扩展保留占位分支。
String sourceTypeLabel(String sourceType) {
  switch (sourceType) {
    case 'manual':
      return '手工录入';
    case 'report_import':
      return '报告导入';
    case 'daily':
      return '日常记录';
    case 'future_ocr':
      return '拍摄识别';
    case 'future_hospital':
      return '医院同步';
    default:
      return '手工录入';
  }
}

/// 一份导入报告的时间线卡片
class _ReportTile extends StatelessWidget {
  final MedicalReport report;
  final int metricCount;
  final List<String> affectedAreas;
  final VoidCallback onTap;

  const _ReportTile({
    required this.report,
    required this.metricCount,
    required this.affectedAreas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatDate(report.reportDate),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const _SourceChip(text: '报告导入'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                report.hospitalName.isEmpty ? '医院未知' : report.hospitalName,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.reportType.isNotEmpty ? report.reportType : '化验单'} · $metricCount 项指标',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              if (affectedAreas.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '影响部位：${affectedAreas.join('、')}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 渲染一条真实数据卡片
class _RealTile extends StatelessWidget {
  final RealEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _RealTile({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatDate(entry.measuredAt),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  _SourceChip(text: entry.source),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                entry.subtitle,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              if (entry.status.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entry.status,
                  style: TextStyle(
                    fontSize: 13,
                    color: _statusColor(entry.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String s) {
  if (s == '正常') return AppColors.normal;
  if (s == '偏高' || s == '偏低') return AppColors.abnormal;
  if (s == '未判断') return AppColors.insufficient;
  return AppColors.insufficient;
}

class _SourceChip extends StatelessWidget {
  final String text;
  const _SourceChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }
}

/// 真实数据详情 / 编辑 / 删除 页
class EntryDetailPage extends StatefulWidget {
  final RealEntry entry;
  const EntryDetailPage({super.key, required this.entry});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.source} · ${formatDate(e.measuredAt)}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Text(e.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(e.subtitle,
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _edit,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('编辑', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _delete,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: AppColors.abnormal),
            child: const Text('删除', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final repo = appRepository;
    if (repo == null) return;
    bool saved = false;
    if (widget.entry.metricId != null) {
      final m = await repo.getMetricById(widget.entry.metricId!);
      if (m != null && mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ManualMetricEntryPage(metric: m),
          ),
        );
        saved = result == true;
      }
    } else if (widget.entry.dailyId != null) {
      final d = await repo.getDailyById(widget.entry.dailyId!);
      if (d != null && mounted) {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => DailyEditPage(record: d),
          ),
        );
        saved = result == true;
      }
    }
    // 仅当子页面确实保存成功（返回 true）时才返回上一页；
    // 用户用返回键/手势取消（返回 null 或非 true）时留在当前页。
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final repo = appRepository;
    if (repo == null) return;
    final bool? confirm = await showDialog<bool>(
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
    if (confirm != true) return;
    if (widget.entry.metricId != null) {
      await repo.deleteMetric(widget.entry.metricId!);
    } else if (widget.entry.dailyId != null) {
      await repo.deleteDaily(widget.entry.dailyId!);
    }
    if (mounted) Navigator.of(context).pop(true);
  }
}
