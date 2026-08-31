import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../models/chronic_condition_dictionary.dart';
import '../models/metric_dictionary.dart';
import '../models/report_followup.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import '../widgets/normal_items_toggle.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/section_title.dart';
import 'add_page.dart';
import 'metric_history_page.dart';
import 'reminders_page.dart';
import 'report_detail_page.dart';

/// 「身体」tab = 器官导航：各部位最近有什么记录、哪里需要关注、哪里暂无资料。
/// 纯读档案聚合，不做慢病管理，不做体检计划，不打健康评分。
class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

/// 部位在身体页里显示的单一状态词。优先级从高到低。
enum _AreaState { followUp, attention, longTerm, hasRecord, noRecord }

extension on _AreaState {
  String get label => switch (this) {
        _AreaState.followUp => '等待复查',
        _AreaState.attention => '需要关注',
        _AreaState.longTerm => '长期关注',
        _AreaState.hasRecord => '近期有记录',
        _AreaState.noRecord => '暂无记录',
      };
}

class _AreaRow {
  final BodyAreaHealthSummary area;
  final _AreaState state;

  /// 该部位当前未完成的复查 / 随访任务数（§3：显示「N 项待复查」而非统一「等待复查」）。
  final int followUpCount;

  const _AreaRow(this.area, this.state, {this.followUpCount = 0});

  int get abnormalCount => area.abnormalCount;
}

/// §4：顶部三个统计既是数字也是筛选器。null = 不筛选（显示全部部位）。
enum _StatFilter { hasRecord, attention, noRecord }

class _BodyPageState extends State<BodyPage> {
  List<HealthMetric> _real = [];
  List<_AreaRow> _rows = const [];
  bool _loading = true;
  String? _error;
  _StatFilter? _statFilter;

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
            _rows = const [];
            _loading = false;
            _error = null;
          });
        }
        return;
      }
      final metrics = await repo.getAllMetrics();
      final reminders = await repo.getActiveReminders();
      final diseases = await repo.getChronicDiseases();

      // 每个部位当前有几个未完成的复查 / 随访任务。
      final followUpCountByArea = <String, int>{};
      for (final r in reminders) {
        if ((r.kind == 'recheck' || r.kind == 'followup') &&
            r.completedAt == null) {
          for (final area in _areasForReminder(r)) {
            followUpCountByArea.update(area, (v) => v + 1, ifAbsent: () => 1);
          }
        }
      }
      // 关联到已确认慢性病的部位
      final longTermAreas = <String>{};
      for (final d in diseases) {
        if (d.status == '已恢复') continue;
        longTermAreas.addAll(_areasForCondition(d.conditionCode));
      }

      final areas = buildBodyAreaHealthFromMetrics(metrics);
      final rows = [
        for (final a in areas)
          _AreaRow(
            a,
            _stateFor(
              a,
              followUp: (followUpCountByArea[a.name] ?? 0) > 0,
              longTerm: longTermAreas.contains(a.name),
            ),
            followUpCount: followUpCountByArea[a.name] ?? 0,
          ),
      ];

      if (mounted) {
        setState(() {
          _real = metrics;
          _rows = rows;
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

  _AreaState _stateFor(
    BodyAreaHealthSummary a, {
    required bool followUp,
    required bool longTerm,
  }) {
    if (followUp) return _AreaState.followUp;
    if (a.status == '异常' || a.status == '需关注') return _AreaState.attention;
    if (longTerm) return _AreaState.longTerm;
    if (a.metrics.isNotEmpty) return _AreaState.hasRecord;
    return _AreaState.noRecord;
  }

  bool get _hasAnyRecord => _rows.any((r) => r.area.metrics.isNotEmpty);

  /// §4：某行属于哪个统计桶（与 [_OverviewCard] 的计数口径一致）。
  static _StatFilter _bucketOf(_AreaState s) => switch (s) {
        _AreaState.followUp || _AreaState.attention => _StatFilter.attention,
        _AreaState.longTerm || _AreaState.hasRecord => _StatFilter.hasRecord,
        _AreaState.noRecord => _StatFilter.noRecord,
      };

  /// 「身体记录」列表：按顶部选中的统计筛选（未选则全部）。
  List<_AreaRow> get _recordRows => _statFilter == null
      ? _rows
      : _rows.where((r) => _bucketOf(r.state) == _statFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('身体'),
        actions: const [ProfileSwitcher()],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ))
            : _error != null
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    ),
                  ])
                : !_hasAnyRecord
                    ? _BodyEmptyState(
                        onAdd: () async {
                          await showAddDataSheet(context);
                          if (mounted) _load();
                        },
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          _OverviewCard(
                            rows: _rows,
                            selected: _statFilter,
                            onSelect: (f) => setState(() =>
                                _statFilter = _statFilter == f ? null : f),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SectionTitle(title: '身体记录'),
                              if (_statFilter != null)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _statFilter = null),
                                  style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact),
                                  child: const Text('清除筛选',
                                      style: TextStyle(fontSize: 13)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (_recordRows.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('没有符合当前筛选的部位',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            )
                          else
                            for (int i = 0; i < _recordRows.length; i++) ...[
                              if (i > 0)
                                const Divider(height: 1, thickness: 0.5),
                              _AreaListRow(
                                row: _recordRows[i],
                                onTap: () =>
                                    _openAreaDetail(_recordRows[i].area),
                              ),
                            ],
                        ],
                      ),
      ),
    );
  }


  void _openAreaDetail(BodyAreaHealthSummary area) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BodySystemDetailPage(
            area: area,
            allMetrics: _real,
            isExample: false,
          ),
        ))
        .then((_) => _load());
  }
}

/// 慢病字典的 conditionCode → 受影响的身体部位集合。
Set<String> _areasForCondition(String? code) {
  final def = findChronicCondition(code);
  if (def == null) return const {};
  final out = <String>{};
  for (final mid in def.relatedMetricIds) {
    final d = findMetricDefinition(mid);
    if (d != null) out.add(bodyAreaForSystem(d.bodySystem));
  }
  for (final dt in def.relatedDailyTypes) {
    final a = _areaForDailyType(dt);
    if (a != null) out.add(a);
  }
  return out;
}

/// 一条复查 / 随访提醒 → 受影响的身体部位集合。
/// 先按 conditionCode 走字典；再用提醒标题里是否包含部位名兜底。
Set<String> _areasForReminder(Reminder r) {
  final out = <String>{..._areasForCondition(r.conditionCode)};
  for (final area in coreBodyAreaOrder) {
    for (final seg in area.split('/')) {
      if (seg.trim().isNotEmpty && r.title.contains(seg.trim())) out.add(area);
    }
  }
  return out;
}

String? _areaForDailyType(String t) {
  switch (t) {
    case 'blood_pressure':
    case 'heart_rate':
      return '心血管';
    case 'blood_glucose':
    case 'weight':
    case 'waist':
      return '内分泌/代谢';
  }
  return null;
}

/// 身体记录概览：有近期记录 / 需要关注 / 暂无记录 三个计数（不用百分比）。
/// §3：一个部位的状态用一句话表达。
/// 有真实复查任务 → 「N 项待复查」；只是指标异常 → 「N 项指标异常」；否则用状态词。
/// 「异常 ≠ 等待复查」——两者分开。
///
/// 颜色：文字一律走灰色（由调用方渲染），分类信号交给左侧小圆点 [dot]。
/// 只有真正需要现在处理的（已到期复查）才在别处用橙色，普通异常 / 待复查不抢注意力。
({String text, Color? dot}) _areaStatusLine(_AreaRow row) {
  if (row.followUpCount > 0) {
    return (text: '${row.followUpCount} 项待复查', dot: AppColors.warning);
  }
  if (row.state == _AreaState.attention && row.abnormalCount > 0) {
    return (
      text: '${row.abnormalCount} 项指标异常',
      dot: row.area.status == '异常' ? AppColors.abnormal : AppColors.warning,
    );
  }
  return (text: row.state.label, dot: null);
}

class _OverviewCard extends StatelessWidget {
  final List<_AreaRow> rows;
  final _StatFilter? selected;
  final ValueChanged<_StatFilter> onSelect;
  const _OverviewCard({
    required this.rows,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    var attention = 0;
    var hasRecord = 0;
    var noRecord = 0;
    for (final r in rows) {
      switch (r.state) {
        case _AreaState.followUp:
        case _AreaState.attention:
          attention++;
        case _AreaState.longTerm:
        case _AreaState.hasRecord:
          hasRecord++;
        case _AreaState.noRecord:
          noRecord++;
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _OverviewStat(
              n: hasRecord,
              label: '有近期记录',
              color: AppColors.normal,
              selected: selected == _StatFilter.hasRecord,
              onTap: () => onSelect(_StatFilter.hasRecord),
            ),
            _OverviewStat(
              n: attention,
              label: '需要关注',
              color: AppColors.warning,
              selected: selected == _StatFilter.attention,
              onTap: () => onSelect(_StatFilter.attention),
            ),
            _OverviewStat(
              n: noRecord,
              label: '暂无记录',
              color: AppColors.insufficient,
              selected: selected == _StatFilter.noRecord,
              onTap: () => onSelect(_StatFilter.noRecord),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final int n;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _OverviewStat({
    required this.n,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text('$n',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? color : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400)),
          ]),
        ),
      ),
    );
  }
}


/// 「身体记录」里的一行：部位名 ……… 状态词。§6：比「需要关注」卡片更紧凑，
/// 去掉卡片外壳，单行、矮，行间用细分隔线。
class _AreaListRow extends StatelessWidget {
  final _AreaRow row;
  final VoidCallback onTap;
  const _AreaListRow({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final line = _areaStatusLine(row);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            // 定宽的圆点位：有分类信号才画点，名字始终对齐。
            SizedBox(
              width: 14,
              child: line.dot == null
                  ? null
                  : Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: line.dot, shape: BoxShape.circle),
                      ),
                    ),
            ),
            Expanded(
              child: Text(row.area.name,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
            ),
            Text(line.text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _BodyEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _BodyEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 96),
      children: [
        const Icon(Icons.accessibility_new,
            size: 48, color: AppColors.insufficient),
        const SizedBox(height: 16),
        const Text('还没有身体健康记录',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('添加检查资料后，指标会自动归入对应身体部位，并逐步形成你的身体健康档案。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(
            onPressed: onAdd,
            child: const Text('添加健康资料'),
          ),
        ),
      ],
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

  /// 本部位的未完成复查 / 随访提醒（取最早到期的一条）。
  Reminder? _recheck;

  /// 本部位关联到的已确认慢性病名称。
  List<String> _longTerm = const [];

  /// reportId → 报告（用于「历史报告」列表显示日期 / 医院 / 类型）。
  Map<int, MedicalReport> _reportsById = const {};

  /// 显式关联到本部位、但没有指标喂进来的报告（主要是影像 / 图文报告）。
  List<int> _extraReportIds = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

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

    Reminder? recheck;
    try {
      final reminders = await repo.getActiveReminders();
      final mine = [
        for (final r in reminders)
          if ((r.kind == 'recheck' || r.kind == 'followup') &&
              r.completedAt == null &&
              r.dueDate != null &&
              _areasForReminder(r).contains(widget.area.name))
            r,
      ]..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      recheck = mine.isEmpty ? null : mine.first;
    } catch (_) {}

    var longTerm = const <String>[];
    try {
      final diseases = await repo.getChronicDiseases();
      longTerm = [
        for (final d in diseases)
          if (d.status != '已恢复' &&
              _areasForCondition(d.conditionCode).contains(widget.area.name))
            d.name,
      ];
    } catch (_) {}

    var reportsById = const <int, MedicalReport>{};
    try {
      final reports = await repo.getAllReports();
      reportsById = {for (final r in reports) r.id: r};
    } catch (_) {}

    var extraReportIds = const <int>[];
    try {
      extraReportIds = await repo.reportIdsForArea(widget.area.name);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _allMetrics = list;
        _area = area;
        _recheck = recheck;
        _longTerm = longTerm;
        _reportsById = reportsById;
        _extraReportIds = extraReportIds;
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

  /// 显式关联到本部位、但不在 _metricsByReport 里的报告 id（影像 / 图文报告）。
  List<int> get _extraOnlyReportIds {
    final withMetrics = _metricsByReport.keys.toSet();
    return _extraReportIds.where((id) => !withMetrics.contains(id)).toList();
  }

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
      appBar: AppBar(
        title: Text(_area.name),
        actions: widget.isExample
            ? null
            : [
                IconButton(
                  tooltip: '添加${_area.name}相关资料',
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await showAddDataSheet(context, contextArea: _area.name);
                    if (mounted) _reload();
                  },
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _SummaryCard(area: _area, isExample: widget.isExample),
            if (!widget.isExample) ...[
              if (_longTerm.isNotEmpty) ...[
                const SectionTitle(title: '长期关注'),
                _LongTermCard(names: _longTerm),
              ],
              const SectionTitle(title: '复查'),
              _RecheckCard(
                reminder: _recheck,
                canSet: key != null,
                onSet: key == null ? null : () => _openHistoryByEvidence(key),
                onView: () => _openRecheck(key),
              ),
            ],
            const SectionTitle(title: '需关注问题'),
            if (_area.metrics.isEmpty)
              const _EmptyDataCard()
            else if (widget.isExample)
              for (final m in _area.metrics) ...[
                _EvidenceCard(metric: m),
                const SizedBox(height: 12),
              ]
            else ...[
              ..._groupedMetricCards(_attentionMetrics),
              if (_attentionMetrics.isEmpty)
                ..._groupedMetricCards(_normalMetrics)
              else ...[
                NormalItemsToggle(
                  expanded: _showNormalMetrics,
                  hiddenCount: _normalMetrics.length,
                  onTap: () =>
                      setState(() => _showNormalMetrics = !_showNormalMetrics),
                ),
                if (_showNormalMetrics) ...[
                  const SizedBox(height: 12),
                  ..._groupedMetricCards(_normalMetrics),
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
            const SectionTitle(title: '历史报告'),
            if (widget.isExample)
              const _SourceNoteCard(text: '示例数据来自本地演示内容。导入报告或手动录入后，将展示实际来源。')
            else if (_metricsByReport.isEmpty && _extraOnlyReportIds.isEmpty)
              const _SourceNoteCard(text: '暂无关联到本部位的报告。')
            else ...[
              for (final entry in _metricsByReport.entries) ...[
                _ReportSourceCard(
                  reportId: entry.key,
                  metricCount: entry.value.length,
                  report: _reportsById[entry.key],
                ),
                const SizedBox(height: 12),
              ],
              // 影像 / 图文报告：没有指标，但显式关联到了本部位。
              for (final id in _extraOnlyReportIds) ...[
                _ReportSourceCard(
                  reportId: id,
                  metricCount: 0,
                  report: _reportsById[id],
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 4),
            const _DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  /// 把指标卡片按「指标分类」（血糖 / 电解质 / 肝功能…）分组渲染。
  /// 只有一个分类时不显示小标题，避免多余层级。
  List<Widget> _groupedMetricCards(List<BodyAreaMetricEvidence> list) {
    if (list.isEmpty) return const [];
    final groups = <String, List<BodyAreaMetricEvidence>>{};
    for (final m in list) {
      groups.putIfAbsent(m.groupLabel, () => []).add(m);
    }
    final showHeaders = groups.length > 1;
    final out = <Widget>[];
    groups.forEach((label, items) {
      if (showHeaders) {
        out.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ));
      }
      for (final m in items) {
        out.add(_RealMetricCard(
            metric: m, onTap: () => _openHistoryByEvidence(m)));
        out.add(const SizedBox(height: 12));
      }
    });
    return out;
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

  /// 查看 / 修改本部位的复查提醒：有关键指标就进它的历史页（复查设置在那里），
  /// 否则退回到提醒页。
  Future<void> _openRecheck(BodyAreaMetricEvidence? key) async {
    if (key != null) {
      await _openHistoryByEvidence(key);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RemindersPage()),
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
  final MedicalReport? report;

  const _ReportSourceCard({
    required this.reportId,
    required this.metricCount,
    this.report,
  });

  @override
  Widget build(BuildContext context) {
    final r = report;
    final title = r == null
        ? '原始报告 #$reportId'
        : [
            formatDate(r.reportDate),
            if (r.hospitalName.trim().isNotEmpty) r.hospitalName.trim(),
            if (r.reportType.trim().isNotEmpty) r.reportType.trim(),
          ].join(' · ');
    return HealthStatusCard(
      title: title,
      status: metricCount > 0 ? '$metricCount 项指标' : '图文报告',
      subtitle: '点击查看这份报告',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReportDetailPage(reportId: reportId)),
      ),
    );
  }
}

/// 本部位的复查提醒卡片：有安排 → 显示下次复查日期 + 修改入口；
/// 没安排但有关键指标 → 一个「设置复查提醒」按钮；否则不显示。
class _RecheckCard extends StatelessWidget {
  final Reminder? reminder;
  final bool canSet;
  final VoidCallback? onSet;
  final VoidCallback onView;

  const _RecheckCard({
    required this.reminder,
    required this.canSet,
    required this.onSet,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final r = reminder;
    if (r != null && r.dueDate != null) {
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      // 系统自动排的随访给 21 天宽限期，过了到期日但还在宽限期内不算「已逾期」。
      final graceDays = r.kind == 'followup' ? 21 : 0;
      final pastGrace = today
          .isAfter(r.dueDate!.add(Duration(days: graceDays)));
      // §1：这条复查如果来自某个长期关注（慢性病），在详情里说明关联，
      // 但不把病名放进标题。
      final condName = r.conditionCode == null
          ? null
          : findChronicCondition(r.conditionCode)?.name;
      return Card(
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: const Icon(Icons.event_available_outlined,
              color: AppColors.primary),
          title: Text(pastGrace ? '复查已逾期' : '下次复查',
              style: const TextStyle(fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatDate(r.dueDate!)} · ${recheckSourceLabel(r.sourceType)}',
                style: TextStyle(
                    fontSize: 12,
                    color: pastGrace
                        ? AppColors.warning
                        : AppColors.textSecondary),
              ),
              if (condName != null && condName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('关联长期关注：$condName',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
            ],
          ),
          trailing: const Text('修改',
              style: TextStyle(fontSize: 13, color: AppColors.primary)),
          onTap: onView,
        ),
      );
    }
    if (!canSet) {
      return const _SourceNoteCard(text: '有异常指标时，可在指标历史页里设置复查提醒。');
    }
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.add_alarm_outlined,
            color: AppColors.primary),
        title: const Text('设置复查提醒', style: TextStyle(fontSize: 15)),
        subtitle: const Text('到期提醒你复查这个部位的相关指标',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onSet,
      ),
    );
  }
}

/// 「长期关注」卡片：自然呈现关联的已确认慢性病名字，不加「慢病患者」这类标签。
class _LongTermCard extends StatelessWidget {
  final List<String> names;
  const _LongTermCard({required this.names});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          names.join('、'),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
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
