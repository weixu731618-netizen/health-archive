import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../models/metric_source.dart';
import '../utils/format.dart';
import '../widgets/profile_switcher.dart';
import '../utils/records_filter.dart';
import 'add_page.dart';
import 'daily_health_entry_page.dart';
import 'daily_history_page.dart';
import 'manual_metric_entry_page.dart';
import 'report_capture_page.dart';
import 'report_detail_page.dart';
import 'report_import_page.dart';

/// 记录页在切 Tab 时会整页重建（为了每次进来都加载最新数据），
/// 用这两个模块级变量把「类型 / 器官」筛选的选择留住，切走再回来还是原来选的那个。
/// App 重启后回到「全部」。
String _recordsTypeFilter = 'all';
String? _recordsOrganFilter;

/// 记录页 = 全部健康资料的时间轴 + 检索入口。
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

/// 记录条目类型。随访记录（FOLLOW_UP_RECORD）暂无创建入口，先不做。
enum _RecKind { report, image, manual }

class _RecordsPageState extends State<RecordsPage> {
  /// 资料类型筛选：all / report（化验报告）/ image（影像·图文报告）/ manual（手动·日常记录）。
  static const List<(String, String)> _typeFilters = [
    ('全部', 'all'),
    ('报告', 'report'),
    ('影像', 'image'),
    ('手动记录', 'manual'),
  ];
  String _typeFilter = _recordsTypeFilter;
  String? _organFilter = _recordsOrganFilter;

  /// 搜索框默认收起，点 AppBar 放大镜展开。
  bool _searchOpen = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  RecordFilter _filter = const RecordFilter();

  List<RealEntry> _real = [];
  List<MedicalReport> _reports = [];
  Map<int, int> _reportMetricCounts = {};
  Map<int, List<String>> _reportMetricNames = {};
  Map<int, bool> _reportHasAbnormal = {};
  List<String> _allTags = const [];
  List<String> _allHospitals = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchCtrl.clear();
        _filter = _filter.copyWith(query: '');
      }
    });
    if (_searchOpen) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _searchFocus.requestFocus());
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = appRepository;
      if (repo != null) {
        final metrics = await repo.getAllMetrics();
        final dailies = await repo.getAllDailyRecords();
        final reports = await repo.getAllReports();
        // 日常记录（血压 / 血糖 / 体重 / 心率）在列表里每类只留最近一条，
        // 点开进 DailyHistoryPage 看曲线。dailies 已按时间倒序，首次出现即最新。
        final seenDailyTypes = <String>{};
        final entries = <RealEntry>[
          for (final m in metrics) RealEntry.metric(m),
          for (final d in dailies)
            if (seenDailyTypes.add(d.type)) RealEntry.daily(d),
        ];
        entries.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
        // 计算每份报告的指标数量 / 指标名 / 是否含异常
        final counts = <int, int>{};
        final metricNames = <int, List<String>>{};
        final hasAbnormal = <int, bool>{};
        for (final r in reports) {
          final reportMetrics = await repo.getMetricsByReport(r.id);
          counts[r.id] = reportMetrics.length;
          metricNames[r.id] = [for (final m in reportMetrics) m.metricName];
          hasAbnormal[r.id] = reportMetrics.any((m) =>
              isMetricAbnormalStatus(m.status) || m.status.contains('异常'));
        }
        final tags = await repo.getDistinctReportTags();
        final hospitals = await repo.getDistinctHospitals();
        if (mounted) {
          setState(() {
            _real = entries;
            _reports = reports;
            _reportMetricCounts = counts;
            _reportMetricNames = metricNames;
            _reportHasAbnormal = hasAbnormal;
            _allTags = tags;
            _allHospitals = hospitals;
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
      appBar: AppBar(
        title: const Text('记录'),
        actions: [
          IconButton(
            tooltip: '搜索',
            icon: Icon(
              _searchOpen ? Icons.search_off : Icons.search,
              color: _filter.query.isNotEmpty ? AppColors.primary : null,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            tooltip: '新增记录',
            icon: const Icon(Icons.add),
            onPressed: _openAddMenu,
          ),
          const ProfileSwitcher(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          // 底部多留一点空间，避免最后一项被悬浮的"添加"按钮挡住。
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            if (_searchOpen) ...[
              TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (v) =>
                    setState(() => _filter = _filter.copyWith(query: v)),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  hintText: '搜索医院、指标、报告内容、标签…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _filter.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(
                                () => _filter = _filter.copyWith(query: ''));
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // 第一层：资料类型。视觉权重最高。
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final (label, value) in _typeFilters)
                  ChoiceChip(
                    label: Text(label),
                    showCheckmark: false,
                    selected: _typeFilter == value,
                    // 再点一下选中的 chip → 回到「全部」。
                    onSelected: (sel) => setState(() {
                      _typeFilter = sel ? value : 'all';
                      _recordsTypeFilter = _typeFilter; // 记住，切 Tab 不丢
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // 第二层：器官 / 高级筛选。放在下面一行，用文字按钮，权重明显更低。
            Row(
              children: [
                _OrganFilterButton(
                  organ: _organFilter,
                  onTap: _pickOrgan,
                ),
                const SizedBox(width: 4),
                _FilterButton(
                  activeCount: _filter.activeCount,
                  onTap: _openFilterSheet,
                ),
              ],
            ),
            if (_filter.activeCount > 0) ...[
              const SizedBox(height: 8),
              _ActiveFilterChips(
                filter: _filter,
                onClear: () => setState(() => _filter = RecordFilter(
                      query: _filter.query,
                    )),
              ),
            ],
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
            else if (_timeline.isEmpty)
              (_filter.query.isNotEmpty ||
                      _filter.activeCount > 0 ||
                      _typeFilter != 'all' ||
                      _organFilter != null)
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('没有符合条件的记录',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '还没有健康资料\n可以拍摄新报告，也可以把以前保存在相册或文件里的医疗资料导入进来。',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) =>
                                            const ReportCapturePage()))
                                    .then((_) => _load()),
                                icon: const Icon(Icons.photo_camera_outlined,
                                    size: 18),
                                label: const Text('拍报告'),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) =>
                                            const ReportImportPage()))
                                    .then((_) => _load()),
                                child: const Text('导入以前的资料'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
            else
              for (final block in _groupByMonth(_timeline)) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 0, 8),
                  child: Text(
                    block.month,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                ),
                for (final item in block.items) ...[
                  if (item.report != null)
                    _ReportTile(
                      report: item.report!,
                      metricCount: _reportMetricCounts[item.report!.id] ?? 0,
                      onTap: () => _openReport(context, item.report!),
                      onEditTags: () => _editTags(item.report!),
                    )
                  else
                    _RealTile(
                      entry: item.entry!,
                      onTap: () => _openReal(context, item.entry!),
                      onLongPress: () => _openReal(context, item.entry!),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
          ],
        ),
      ),
    );
  }

  /// 记录页右上角 `+`：完整新增菜单（拍报告 / 相册·文件 / 影像 / 手工 / 日常 / 用药）。
  /// 复用首页那套 [showAddDataSheet]，不另起一套业务逻辑；回来后刷新时间轴。
  Future<void> _openAddMenu() async {
    await showAddDataSheet(context);
    if (mounted) _load();
  }

  Future<void> _pickOrgan() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('全部器官'),
                trailing: _organFilter == null
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, '__all__'),
              ),
              for (final a in coreBodyAreaOrder)
                ListTile(
                  title: Text(a),
                  trailing: _organFilter == a
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, a),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _organFilter = picked == '__all__' ? null : picked;
      _recordsOrganFilter = _organFilter;
    });
  }

  bool _matchesType(_RecKind k) {
    switch (_typeFilter) {
      case 'report':
        return k == _RecKind.report;
      case 'image':
        return k == _RecKind.image;
      case 'manual':
        return k == _RecKind.manual;
      default:
        return true;
    }
  }

  /// 报告 + 手动/日常记录合成一条按时间倒序的时间轴，逐条套用类型 / 器官 / 搜索筛选。
  List<_TimelineItem> get _timeline {
    final out = <_TimelineItem>[];
    for (final r in _reports) {
      final count = _reportMetricCounts[r.id] ?? 0;
      final kind = count > 0 ? _RecKind.report : _RecKind.image;
      if (!_matchesType(kind)) continue;
      final areas = affectedBodyAreasForRawMetricNames(
          _reportMetricNames[r.id] ?? const []);
      if (_organFilter != null && !areas.contains(_organFilter)) continue;
      if (!_filter.matchesReport(
        r,
        metricNames: _reportMetricNames[r.id] ?? const [],
        hasAbnormalMetric: _reportHasAbnormal[r.id] ?? false,
      )) {
        continue;
      }
      out.add(_TimelineItem(date: r.reportDate, report: r));
    }
    for (final e in _real) {
      if (!_matchesType(_RecKind.manual)) continue;
      if (_organFilter != null && !e.areas.contains(_organFilter)) continue;
      if (!_filter.matchesEntry(
        title: e.title,
        subtitle: e.subtitle,
        status: e.status,
        measuredAt: e.measuredAt,
      )) {
        continue;
      }
      out.add(_TimelineItem(date: e.measuredAt, entry: e));
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  List<_MonthBlock> _groupByMonth(List<_TimelineItem> items) {
    final blocks = <_MonthBlock>[];
    for (final it in items) {
      final label = '${it.date.year}年${it.date.month}月';
      if (blocks.isEmpty || blocks.last.month != label) {
        blocks.add(_MonthBlock(label, [it]));
      } else {
        blocks.last.items.add(it);
      }
    }
    return blocks;
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
    // 日常记录（血压 / 血糖 / 体重 / 心率）→ 带折线图的历史页；
    // 手工录入的化验指标 → 单条详情页。
    final Widget page = entry.dailyType != null
        ? DailyHistoryPage(type: entry.dailyType!)
        : EntryDetailPage(entry: entry);
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) _load();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<RecordFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        initial: _filter,
        allTags: _allTags,
        allHospitals: _allHospitals,
      ),
    );
    if (result != null) setState(() => _filter = result);
  }

  Future<void> _editTags(MedicalReport report) async {
    final repo = appRepository;
    if (repo == null) return;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _TagEditSheet(
        current: HealthRepository.parseTags(report.tags),
        suggestions: _allTags,
      ),
    );
    if (result == null) return;
    await repo.setReportTags(report.id, result);
    if (mounted) _load();
  }
}

/// 时间轴上的一条：报告 或 手动/日常记录，二选一。
class _TimelineItem {
  final DateTime date;
  final MedicalReport? report;
  final RealEntry? entry;
  const _TimelineItem({required this.date, this.report, this.entry});
}

class _MonthBlock {
  final String month;
  final List<_TimelineItem> items;
  _MonthBlock(this.month, this.items);
}

class _OrganFilterButton extends StatelessWidget {
  final String? organ;
  final VoidCallback onTap;
  const _OrganFilterButton({required this.organ, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = organ != null;
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.category_outlined, size: 16),
      label: Text(active ? '器官·$organ' : '器官',
          style: const TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor:
            active ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;
  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.tune, size: 16),
      label: Text(activeCount == 0 ? '筛选' : '筛选·$activeCount',
          style: const TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor:
            activeCount == 0 ? AppColors.textSecondary : AppColors.primary,
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  final RecordFilter filter;
  final VoidCallback onClear;
  const _ActiveFilterChips({required this.filter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (filter.abnormalOnly) '只看异常',
      for (final t in filter.tags) '标签：$t',
      for (final h in filter.hospitals) h,
      if (filter.dateRange != null)
        '${formatDate(filter.dateRange!.start)} ~ ${formatDate(filter.dateRange!.end)}',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final l in labels)
          Chip(
            label: Text(l, style: const TextStyle(fontSize: 12)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        TextButton(
          onPressed: onClear,
          style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: const Text('清除', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

/// 记录页里的一条真实数据（手工录入 或 日常记录）
class RealEntry {
  final int? metricId;
  final int? dailyId;
  final String?
      dailyType; // 日常记录的类型：blood_pressure / blood_glucose / weight / heart_rate
  final String title;
  final String subtitle;
  final String status;
  final String source; // 手工录入 / 日常记录
  final DateTime measuredAt;

  /// 这条记录涉及的身体部位（用于记录页「器官」筛选）。
  final Set<String> areas;

  RealEntry.metric(HealthMetric m)
      : metricId = m.id,
        dailyId = null,
        dailyType = null,
        title = m.metricName,
        subtitle = _valueText(m.value, m.unit) +
            (m.referenceMin == null || m.referenceMax == null
                ? ''
                : '  (参考 ${fmtNum(m.referenceMin!)}–${fmtNum(m.referenceMax!)} ${m.unit})'),
        status = m.status,
        source = sourceTypeLabel(m.sourceType),
        measuredAt = m.measuredAt,
        areas = {bodyAreaForSystem(m.bodySystem)};

  RealEntry.daily(DailyHealthRecord d)
      : metricId = null,
        dailyId = d.id,
        dailyType = d.type,
        title = _dailyTitle(d),
        subtitle = _dailySubtitle(d),
        status = '',
        source = '日常记录',
        measuredAt = d.measuredAt,
        areas = _areasForDailyType(d.type);

  /// 记录卡片右上角标签：日常记录用具体类型（血压 / 血糖 / 体重 / 心率 / 腰围），
  /// 手工录入的化验指标保留「手工录入」。报告 / 影像走各自的 Tile，不用这个。
  String get cornerLabel {
    switch (dailyType) {
      case 'blood_pressure':
        return '血压';
      case 'blood_glucose':
        return '血糖';
      case 'weight':
        return '体重';
      case 'heart_rate':
        return '心率';
      case 'waist':
        return '腰围';
    }
    return source;
  }

  static Set<String> _areasForDailyType(String t) {
    switch (t) {
      case 'blood_pressure':
      case 'heart_rate':
        return {'心血管'};
      case 'blood_glucose':
      case 'weight':
      case 'waist':
        return {'内分泌/代谢'};
      default:
        return const {};
    }
  }

  static String _dailyTitle(DailyHealthRecord d) {
    switch (d.type) {
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

  static String _dailySubtitle(DailyHealthRecord d) {
    switch (d.type) {
      case 'blood_pressure':
        return '${fmtNum(d.value1)} / ${fmtNum(d.value2!)} ${d.unit}${d.context == null ? '' : '  ${d.context}'}';
      case 'blood_glucose':
        return '${fmtNum(d.value1)} ${d.unit}${d.context == null ? '' : '（${d.context}）'}';
      case 'weight':
      case 'waist':
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
/// 来源类型的规范定义（含 Apple Health / 设备等未来预留项）见 [metric_source.dart]。
String sourceTypeLabel(String sourceType) =>
    metricSourceLabelFromWire(sourceType);

/// 一份导入报告的时间线卡片：只三行——日期、医院、类型。
/// 结论 / 影响部位 / 标签 / 分享 等都点开报告详情做，卡片上不铺。
class _ReportTile extends StatelessWidget {
  final MedicalReport report;
  final int metricCount;
  final VoidCallback onTap;
  final VoidCallback onEditTags;

  const _ReportTile({
    required this.report,
    required this.metricCount,
    required this.onTap,
    required this.onEditTags,
  });

  String get _typeLabel =>
      report.reportType.isNotEmpty ? report.reportType : '报告';

  /// 有指标 → 「类型 · N 项指标」；无指标（影像/病理等图文报告）→ 「类型 · 图文报告」。
  String get _summaryLine =>
      metricCount > 0 ? '$_typeLabel · $metricCount 项指标' : '$_typeLabel · 图文报告';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onEditTags,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(report.reportDate),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                report.hospitalName.isEmpty ? '医院未知' : report.hospitalName,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _summaryLine,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
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
                  _SourceChip(text: entry.cornerLabel),
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

/// B3：筛选 bottom sheet（时间范围 / 只看异常 / 标签 / 医院）。
class _FilterSheet extends StatefulWidget {
  final RecordFilter initial;
  final List<String> allTags;
  final List<String> allHospitals;
  const _FilterSheet({
    required this.initial,
    required this.allTags,
    required this.allHospitals,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _abnormalOnly;
  late Set<String> _tags;
  late Set<String> _hospitals;
  DateTimeRange? _range;
  RecordDatePreset _preset = RecordDatePreset.all;

  @override
  void initState() {
    super.initState();
    _abnormalOnly = widget.initial.abnormalOnly;
    _tags = {...widget.initial.tags};
    _hospitals = {...widget.initial.hospitals};
    _range = widget.initial.dateRange;
    if (_range != null) _preset = RecordDatePreset.custom;
  }

  void _applyPreset(RecordDatePreset p) {
    setState(() {
      _preset = p;
      if (p == RecordDatePreset.custom) return;
      _range = presetToRange(p, DateTime.now());
    });
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        _preset = RecordDatePreset.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('筛选',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('只看异常'),
                value: _abnormalOnly,
                onChanged: (v) => setState(() => _abnormalOnly = v),
              ),
              const SizedBox(height: 4),
              const Text('时间范围',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in const {
                    '全部': RecordDatePreset.all,
                    '近 1 个月': RecordDatePreset.month1,
                    '近 3 个月': RecordDatePreset.month3,
                    '近 1 年': RecordDatePreset.year1,
                  }.entries)
                    ChoiceChip(
                      label: Text(e.key),
                      selected: _preset == e.value,
                      onSelected: (_) => _applyPreset(e.value),
                    ),
                  ChoiceChip(
                    label: Text(_preset == RecordDatePreset.custom &&
                            _range != null
                        ? '${formatDate(_range!.start)}~${formatDate(_range!.end)}'
                        : '自定义'),
                    selected: _preset == RecordDatePreset.custom,
                    onSelected: (_) => _pickCustomRange(),
                  ),
                ],
              ),
              if (widget.allTags.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('标签',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in widget.allTags)
                      FilterChip(
                        label: Text(t),
                        selected: _tags.contains(t),
                        onSelected: (s) =>
                            setState(() => s ? _tags.add(t) : _tags.remove(t)),
                      ),
                  ],
                ),
              ],
              if (widget.allHospitals.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('医院',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final h in widget.allHospitals)
                      FilterChip(
                        label: Text(h),
                        selected: _hospitals.contains(h),
                        onSelected: (s) => setState(
                            () => s ? _hospitals.add(h) : _hospitals.remove(h)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(
                        RecordFilter(query: widget.initial.query),
                      ),
                      child: const Text('重置'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        RecordFilter(
                          query: widget.initial.query,
                          abnormalOnly: _abnormalOnly,
                          tags: _tags,
                          hospitals: _hospitals,
                          dateRange: _range,
                        ),
                      ),
                      child: const Text('应用'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// B3：给一份报告编辑标签。
class _TagEditSheet extends StatefulWidget {
  final List<String> current;
  final List<String> suggestions;
  const _TagEditSheet({required this.current, required this.suggestions});

  @override
  State<_TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends State<_TagEditSheet> {
  late List<String> _tags;
  final _ctrl = TextEditingController();

  static const List<String> _common = ['体检', '术前', '复查', '住院', '门诊'];

  @override
  void initState() {
    super.initState();
    _tags = [...widget.current];
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t.contains(',') || _tags.contains(t)) return;
    setState(() {
      _tags.add(t);
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = <String>{..._common, ...widget.suggestions}
        .where((t) => !_tags.contains(t))
        .toList();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('报告标签',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (_tags.isEmpty)
                const Text('还没有标签',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final t in _tags)
                      InputChip(
                        label: Text(t),
                        onDeleted: () => setState(() => _tags.remove(t)),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '新建标签',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _add(_ctrl.text),
                  ),
                ),
                onSubmitted: _add,
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in suggestions.take(12))
                      ActionChip(
                        label: Text(s),
                        onPressed: () => _add(s),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_tags),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
