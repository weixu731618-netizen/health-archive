import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import '../widgets/normal_items_toggle.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/section_title.dart';
import 'condition_page.dart';
import 'medical_summary_page.dart';
import 'medication_page.dart';
import 'metric_history_page.dart';
import 'report_detail_page.dart';

/// 身体页面：以身体部位为主线查看健康数据。
/// 第一阶段继续使用 health_metrics.bodySystem 作为指标来源字段。
class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  List<HealthMetric> _real = [];
  int _diseaseCount = 0;
  int _medCount = 0;
  bool _loading = true;
  String? _error;
  bool _showNormalAreas = false;

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
            _real = const [];
            _loading = false;
            _error = null;
          });
        }
        return;
      }
      final list = await repo.getAllMetrics();
      final diseases = await repo.getAllDiseases();
      final meds = await repo.getAllMedications();
      if (mounted) {
        setState(() {
          _real = list;
          _diseaseCount = diseases.length;
          _medCount = meds.length;
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

  List<BodyAreaHealthSummary> get _bodyAreas =>
      buildBodyAreaHealthFromMetrics(_real);

  /// 异常 / 需关注的部位：始终展示在前。
  List<BodyAreaHealthSummary> get _attentionAreas =>
      _bodyAreas.where((a) => a.priorityRank <= 1).toList();

  /// 正常（含数据不足）的部位：默认折叠。
  List<BodyAreaHealthSummary> get _normalAreas =>
      _bodyAreas.where((a) => a.priorityRank > 1).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('身体部位健康'),
        actions: const [ProfileSwitcher()],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // 底部多留一点空间，避免最后一项被悬浮的"添加"按钮挡住。
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                '按身体部位查看指标证据，异常和需关注部位会优先显示。',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            const SectionTitle(title: '健康背景'),
            _BackgroundTile(
              icon: Icons.coronavirus_outlined,
              title: '疾病史',
              count: _diseaseCount,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => const ConditionPage()))
                  .then((_) => _load()),
            ),
            const SizedBox(height: 12),
            _BackgroundTile(
              icon: Icons.medication_outlined,
              title: '当前用药',
              count: _medCount,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => const MedicationPage()))
                  .then((_) => _load()),
            ),
            const SizedBox(height: 12),
            _BackgroundTile(
              icon: Icons.description_outlined,
              title: '给医生看的摘要',
              trailingText: '导出',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const MedicalSummaryPage())),
            ),
            const SizedBox(height: 16),
            const SectionTitle(title: '身体部位'),
            const SizedBox(height: 4),
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
            else ...[
              for (final area in _attentionAreas) ...[
                _BodyAreaCard(
                  area: area,
                  isExample: false,
                  onTap: () => _openAreaDetail(context, area),
                ),
                const SizedBox(height: 12),
              ],
              if (_attentionAreas.isEmpty)
                for (final area in _normalAreas) ...[
                  _BodyAreaCard(
                    area: area,
                    isExample: false,
                    onTap: () => _openAreaDetail(context, area),
                  ),
                  const SizedBox(height: 12),
                ]
              else ...[
                NormalItemsToggle(
                  expanded: _showNormalAreas,
                  hiddenCount: _normalAreas.length,
                  onTap: () =>
                      setState(() => _showNormalAreas = !_showNormalAreas),
                ),
                if (_showNormalAreas) ...[
                  const SizedBox(height: 12),
                  for (final area in _normalAreas) ...[
                    _BodyAreaCard(
                      area: area,
                      isExample: false,
                      onTap: () => _openAreaDetail(context, area),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _openAreaDetail(BuildContext context, BodyAreaHealthSummary area) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BodySystemDetailPage(
          area: area,
          allMetrics: _real,
          isExample: false,
        ),
      ),
    );
  }
}

/// 「健康背景」区的一行：疾病史 / 当前用药 / 给医生看的摘要。
class _BackgroundTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;
  final String? trailingText;
  final VoidCallback onTap;

  const _BackgroundTile({
    required this.icon,
    required this.title,
    this.count,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tail = trailingText ?? (count != null && count! > 0 ? '$count 条' : null);
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tail != null) ...[
              Text(tail,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BodyAreaCard extends StatelessWidget {
  final BodyAreaHealthSummary area;
  final bool isExample;
  final VoidCallback onTap;

  const _BodyAreaCard({
    required this.area,
    required this.isExample,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final key = area.keyMetric;
    final source = area.latestMeasuredAt == null
        ? (isExample ? '示例数据' : '暂无来源')
        : formatDate(area.latestMeasuredAt!);
    final subtitle = key == null
        ? '暂无可用于判断的检查指标'
        : area.abnormalCount > 0
            ? '异常指标：${key.name} ${key.valueText} · 来源 $source'
            : '关键指标：${key.name} ${key.valueText} · 来源 $source';

    return HealthStatusCard(
      title: area.name,
      status: area.status,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

/// 身体部位详情页：摘要 / 关联指标 / 历史趋势 / 来源报告。
class BodySystemDetailPage extends StatefulWidget {
  final BodyAreaHealthSummary area;
  final List<HealthMetric> allMetrics;
  final bool isExample;

  const BodySystemDetailPage({
    super.key,
    required this.area,
    required this.allMetrics,
    this.isExample = false,
  });

  @override
  State<BodySystemDetailPage> createState() => _BodySystemDetailPageState();
}

class _BodySystemDetailPageState extends State<BodySystemDetailPage> {
  late List<HealthMetric> _allMetrics = widget.allMetrics;
  late BodyAreaHealthSummary _area = widget.area;
  bool _showNormalMetrics = false;

  Future<void> _reload() async {
    final repo = appRepository;
    if (repo == null || widget.isExample) return;
    final list = await repo.getAllMetrics();
    final summaries = buildBodyAreaHealthFromMetrics(list);
    final area = summaries.firstWhere(
      (s) => s.name == widget.area.name,
      orElse: () => BodyAreaHealthSummary(
        name: widget.area.name,
        status: '数据不足',
        metrics: const [],
      ),
    );
    if (mounted) {
      setState(() {
        _allMetrics = list;
        _area = area;
      });
    }
  }

  List<HealthMetric> get _metrics {
    final list = _allMetrics
        .where((m) => bodyAreaForSystem(m.bodySystem) == _area.name)
        .toList();
    list.sort((a, b) {
      final ar = isMetricAbnormalStatus(a.status) ? 0 : 1;
      final br = isMetricAbnormalStatus(b.status) ? 0 : 1;
      if (ar != br) return ar.compareTo(br);
      return b.measuredAt.compareTo(a.measuredAt);
    });
    return list;
  }

  /// 每个指标去重后只保留最新一条：异常/需关注的排前，正常/数据不足的可折叠。
  List<BodyAreaMetricEvidence> get _attentionMetrics =>
      _area.metrics.where((m) => m.needsAttention).toList();

  List<BodyAreaMetricEvidence> get _normalMetrics =>
      _area.metrics.where((m) => !m.needsAttention).toList();

  Map<int, List<HealthMetric>> get _metricsByReport {
    final out = <int, List<HealthMetric>>{};
    for (final m in _metrics) {
      final id = m.reportId;
      if (id == null) continue;
      out.putIfAbsent(id, () => []).add(m);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final key = _area.keyMetric;
    return Scaffold(
      appBar: AppBar(title: Text(_area.name)),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _SummaryCard(area: _area, isExample: widget.isExample),
            const SectionTitle(title: '需关注问题'),
            if (_area.metrics.isEmpty)
              const _EmptyDataCard()
            else if (widget.isExample)
              for (final m in _area.metrics) ...[
                _EvidenceCard(metric: m),
                const SizedBox(height: 12),
              ]
            else ...[
              for (final m in _attentionMetrics) ...[
                _RealMetricCard(
                    metric: m, onTap: () => _openHistoryByEvidence(m)),
                const SizedBox(height: 12),
              ],
              if (_attentionMetrics.isEmpty)
                for (final m in _normalMetrics) ...[
                  _RealMetricCard(
                      metric: m, onTap: () => _openHistoryByEvidence(m)),
                  const SizedBox(height: 12),
                ]
              else ...[
                NormalItemsToggle(
                  expanded: _showNormalMetrics,
                  hiddenCount: _normalMetrics.length,
                  onTap: () => setState(
                      () => _showNormalMetrics = !_showNormalMetrics),
                ),
                if (_showNormalMetrics) ...[
                  const SizedBox(height: 12),
                  for (final m in _normalMetrics) ...[
                    _RealMetricCard(
                        metric: m, onTap: () => _openHistoryByEvidence(m)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ],
            const SectionTitle(title: '历史趋势'),
            if (key == null)
              const _EmptyDataCard(message: '暂无足够数据形成趋势')
            else
              _TrendEntryCard(
                metric: key,
                onTap:
                    widget.isExample ? null : () => _openHistoryByEvidence(key),
              ),
            const SectionTitle(title: '数据来源报告'),
            if (widget.isExample)
              const _SourceNoteCard(text: '示例数据来自本地演示内容。导入报告或手动录入后，将展示实际来源。')
            else if (_metricsByReport.isEmpty)
              const _SourceNoteCard(text: '当前指标来自手工录入，暂无关联的原始报告。')
            else
              for (final entry in _metricsByReport.entries) ...[
                _ReportSourceCard(
                  reportId: entry.key,
                  metricCount: entry.value.length,
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 4),
            const _DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _openHistoryByEvidence(BodyAreaMetricEvidence metric) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MetricHistoryPage(
          metricId: metric.metricId,
          metricName: metric.name,
          unit: _unitFromValueText(metric.valueText),
        ),
      ),
    );
    if (mounted) _reload();
  }
}

class _SummaryCard extends StatelessWidget {
  final BodyAreaHealthSummary area;
  final bool isExample;

  const _SummaryCard({required this.area, required this.isExample});

  @override
  Widget build(BuildContext context) {
    final latest = area.latestMeasuredAt == null
        ? (isExample ? '示例数据' : '暂无数据')
        : formatDate(area.latestMeasuredAt!);
    final attention = area.abnormalCount == 0
        ? '未发现异常指标置顶项'
        : '${area.abnormalCount} 项异常指标需关注';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    area.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusChip(
                  text: area.status,
                  color: valueStatusColor(area.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$attention · 最近来源 $latest',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealMetricCard extends StatelessWidget {
  final BodyAreaMetricEvidence metric;
  final VoidCallback onTap;

  const _RealMetricCard({required this.metric, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasRange = metric.referenceMin != null && metric.referenceMax != null;
    final dateText =
        metric.measuredAt == null ? '' : ' · ${formatDate(metric.measuredAt!)}';
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          metric.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${metric.valueText}'
          '${hasRange ? ' · 参考 ${_fmt(metric.referenceMin!)}–${_fmt(metric.referenceMax!)}' : ''}'
          '$dateText',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: StatusChip(
          text: metric.status,
          color: valueStatusColor(metric.status),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  final BodyAreaMetricEvidence metric;

  const _EvidenceCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return HealthStatusCard(
      title: metric.name,
      value: metric.valueText,
      status: metric.status,
    );
  }
}

class _TrendEntryCard extends StatelessWidget {
  final BodyAreaMetricEvidence metric;
  final VoidCallback? onTap;

  const _TrendEntryCard({required this.metric, this.onTap});

  @override
  Widget build(BuildContext context) {
    return HealthStatusCard(
      title: metric.name,
      status: metric.status,
      subtitle: onTap == null ? '导入真实数据后可查看完整历史趋势' : '点击查看该指标的历史趋势',
      onTap: onTap,
    );
  }
}

class _ReportSourceCard extends StatelessWidget {
  final int reportId;
  final int metricCount;

  const _ReportSourceCard({
    required this.reportId,
    required this.metricCount,
  });

  @override
  Widget build(BuildContext context) {
    return HealthStatusCard(
      title: '原始报告 #$reportId',
      status: '$metricCount 项指标',
      subtitle: '点击查看这份报告及其影响的身体部位',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReportDetailPage(reportId: reportId)),
      ),
    );
  }
}

class _EmptyDataCard extends StatelessWidget {
  final String message;

  const _EmptyDataCard({this.message = '暂无可用于判断的检查指标'});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SourceNoteCard extends StatelessWidget {
  final String text;

  const _SourceNoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '当前状态由已记录数据和参考范围整理得出，用于提示、趋势展示和来源追溯，不等同于医学诊断。',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

String _unitFromValueText(String valueText) {
  final parts = valueText.trim().split(RegExp(r'\s+'));
  if (parts.length <= 1) return '';
  return parts.sublist(1).join(' ');
}
