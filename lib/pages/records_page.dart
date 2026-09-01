import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../models/metric_source.dart';
import '../models/report_models.dart' show kUnlinkedReportType;
import '../utils/format.dart';
import '../widgets/health_ui.dart';
import '../widgets/toast.dart';
import '../widgets/ios_button.dart';
import '../widgets/ios_tap.dart';
import '../widgets/profile_switcher.dart';
import '../utils/records_filter.dart';
import 'add_page.dart';
import 'daily_health_entry_page.dart';
import 'daily_history_page.dart';
import 'manual_metric_entry_page.dart';
import 'report_detail_page.dart';

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
enum _RecKind { report, image, unlinked, manual }

class _RecordsPageState extends State<RecordsPage> {
  /// 资料类型筛选：all / report（化验报告）/ image（影像·图文报告）/ manual（手动·日常记录）。
  static const List<(String, String)> _typeFilters = [
    ('全部', 'all'),
    ('报告', 'report'),
    ('影像', 'image'),
    ('未关联', 'unlinked'),
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
        _searchFocus.unfocus(); // 收起时也收键盘
      }
    });
    // 展开时只露出搜索框，不自动弹键盘——用户点搜索框才弹，避免"一点放大镜键盘就糊脸"。
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
    final content = <Widget>[
      if (_filterSummary != null) ...[
        Row(
          children: [
            Expanded(
              child: Text(_filterSummary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
              onPressed: _clearSheetFilters,
              child: const Text('清除', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
      if (_loading)
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CupertinoActivityIndicator()),
        )
      else if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(_error!,
              style: const TextStyle(color: AppColors.textSecondary)),
        )
      else if (_timeline.isEmpty)
        (_filter.query.isNotEmpty ||
                _filter.activeCount > 0 ||
                _typeFilter != 'all' ||
                _organFilter != null)
            ? const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 8),
                child: Text('没有符合条件的记录',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '还没有健康记录',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '检查报告、影像资料和手动记录都会保存在这里。',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    CupertinoButton.filled(
                      onPressed: _openAddMenu,
                      child: const Text('添加第一条记录'),
                    ),
                  ],
                ),
              )
      else
        for (final block in _groupByMonth(_timeline)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
            child: Text(
              block.month,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary),
            ),
          ),
          HealthCard(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
            child: Column(children: [
              for (final item in block.items)
                if (item.report != null)
                  _ReportRow(
                    report: item.report!,
                    metricCount: _reportMetricCounts[item.report!.id] ?? 0,
                    onTap: () => _openReport(context, item.report!),
                    onEditTags: () => _editTags(item.report!),
                  )
                else
                  _RealRow(
                    entry: item.entry!,
                    onTap: () => _openReal(context, item.entry!),
                    onDelete: () => _deleteReal(item.entry!),
                  ),
            ]),
          ),
        ],
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator.adaptive(
        onRefresh: _load,
        child: SlidableAutoCloseBehavior(
          child: CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text('记录'),
                backgroundColor:
                    AppColors.background.withValues(alpha: 0.85),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_searchOpen)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: _toggleSearch,
                        child: Icon(CupertinoIcons.search,
                            size: 22,
                            color: _filter.query.isNotEmpty
                                ? AppColors.primary
                                : null),
                      ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      onPressed: _openAddMenu,
                      child: const Icon(CupertinoIcons.add, size: 24),
                    ),
                    const ProfileSwitcher(),
                  ],
                ),
              ),
              if (_searchOpen)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoSearchTextField(
                            controller: _searchCtrl,
                            focusNode: _searchFocus,
                            placeholder: '搜索医院、指标、报告内容、标签…',
                            onChanged: (v) => setState(() =>
                                _filter = _filter.copyWith(query: v)),
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.only(left: 8),
                          onPressed: _toggleSearch,
                          child: const Text('取消'),
                        ),
                      ],
                    ),
                  ),
                ),
              // 类型胶囊 + 「筛选」——滚动时钉在导航栏下方。
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarHeader(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView(
                          key: const PageStorageKey('records-type-scroll'),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          children: [
                            for (final (label, value) in _typeFilters) ...[
                              _TypePill(
                                label: label,
                                selected: _typeFilter == value,
                                onTap: () => setState(() {
                                  _typeFilter =
                                      _typeFilter == value ? 'all' : value;
                                  _recordsTypeFilter = _typeFilter;
                                }),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      _TypePill(
                        label: _sheetActiveCount > 0
                            ? '筛选·$_sheetActiveCount'
                            : '筛选',
                        selected: _sheetActiveCount > 0,
                        onTap: _openFilterSheet,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                // 底部多留一点空间，避免最后一项被悬浮的"添加"按钮挡住。
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(content),
                ),
              ),
            ],
          ),
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

  /// 「筛选」胶囊上的角标数：器官 + 高级筛选（时间 / 只看异常 / 标签 / 医院）。
  int get _sheetActiveCount =>
      _filter.activeCount + (_organFilter != null ? 1 : 0);

  /// 胶囊行下方那一行灰字摘要；没有任何筛选时为 null。
  String? get _filterSummary {
    final parts = <String>[
      if (_organFilter != null) _organFilter!,
      if (_filter.abnormalOnly) '只看异常',
      for (final t in _filter.tags) '#$t',
      for (final h in _filter.hospitals) h,
      if (_filter.dateRange != null)
        '${formatDateShort(_filter.dateRange!.start)}~${formatDateShort(_filter.dateRange!.end)}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  void _clearSheetFilters() => setState(() {
        _filter = RecordFilter(query: _filter.query);
        _organFilter = null;
        _recordsOrganFilter = null;
      });

  bool _matchesType(_RecKind k) {
    switch (_typeFilter) {
      case 'report':
        return k == _RecKind.report;
      case 'image':
        return k == _RecKind.image;
      case 'unlinked':
        return k == _RecKind.unlinked;
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
      final kind = r.reportType == kUnlinkedReportType
          ? _RecKind.unlinked
          : (count > 0 ? _RecKind.report : _RecKind.image);
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
    final result =
        await showModalBottomSheet<({RecordFilter filter, String? organ})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(
        initial: _filter,
        initialOrgan: _organFilter,
        allTags: _allTags,
        allHospitals: _allHospitals,
      ),
    );
    if (result != null) {
      setState(() {
        _filter = result.filter;
        _organFilter = result.organ;
        _recordsOrganFilter = _organFilter;
      });
    }
  }

  /// 记录行左滑「删除」：手工录入指标 / 日常记录，带二次确认。
  Future<void> _deleteReal(RealEntry entry) async {
    final repo = appRepository;
    if (repo == null) return;
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('删除这条记录？'),
        content: Text('「${entry.title}」将被删除，且无法恢复。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      if (entry.metricId != null) {
        await repo.deleteMetric(entry.metricId!);
      } else if (entry.dailyId != null) {
        await repo.deleteDaily(entry.dailyId!);
      }
      if (mounted) showToast(context, '已删除');
    } catch (_) {
      if (mounted) showToast(context, '删除失败，请重试');
    }
    if (mounted) _load();
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

/// 类型胶囊行的 sliver 头：固定高度，滚动时钉在导航栏下方。
/// 背景填成页面底色，避免下方内容透上来。
class _FilterBarHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _FilterBarHeader({required this.child});

  static const double _height = 46;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _height,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_FilterBarHeader oldDelegate) => true;
}

/// 记录页第一层「资料类型」筛选胶囊。无水波纹，选中态浅色填充 + 主色描边。
class _TypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IosTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD9DEE3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
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

/// 一份导入报告的时间线行：标题「类型 · N 项指标」，副标题「医院 · 日期」。
/// 结论 / 影响部位 / 标签 / 分享 等都点开报告详情做，行里不铺。
class _ReportRow extends StatelessWidget {
  final MedicalReport report;
  final int metricCount;
  final VoidCallback onTap;
  final VoidCallback onEditTags;

  const _ReportRow({
    required this.report,
    required this.metricCount,
    required this.onTap,
    required this.onEditTags,
  });

  String get _typeLabel =>
      report.reportType.isNotEmpty ? report.reportType : '报告';

  String get _summaryLine {
    if (report.reportType == kUnlinkedReportType) return '未关联记录 · 待整理';
    return metricCount > 0
        ? '$_typeLabel · $metricCount 项指标'
        : '$_typeLabel · 图文报告';
  }

  @override
  Widget build(BuildContext context) {
    final hospital =
        report.hospitalName.isEmpty ? '医院未知' : report.hospitalName;
    return Slidable(
      key: ValueKey('rec-report-${report.id}'),
      groupTag: 'records',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.26,
        children: [
          SlidableAction(
            onPressed: (_) => onEditTags(),
            backgroundColor: AppColors.primary,
            foregroundColor: CupertinoColors.white,
            icon: CupertinoIcons.tag,
            label: '标签',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: onEditTags, // 长按仍可改标签
        child: HealthRow(
          title: _summaryLine,
          subtitle: '$hospital · ${formatDateShort(report.reportDate)}',
          onTap: onTap,
        ),
      ),
    );
  }
}

/// 一条真实数据（手工录入 / 日常记录）的时间线行。
class _RealRow extends StatelessWidget {
  final RealEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RealRow({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sub = '${entry.subtitle} · ${formatDateShort(entry.measuredAt)}';
    return Slidable(
      key: ValueKey('rec-real-${entry.metricId ?? 'd'}-${entry.dailyId ?? 'm'}'
          '-${entry.measuredAt.millisecondsSinceEpoch}'),
      groupTag: 'records',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.26,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.abnormal,
            foregroundColor: CupertinoColors.white,
            icon: CupertinoIcons.delete,
            label: '删除',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: HealthRow(
        title: entry.title,
        subtitle: sub,
        trailing: entry.status.isEmpty
            ? null
            : Text(entry.status,
                style: TextStyle(
                    fontSize: 13,
                    color: _statusColor(entry.status),
                    fontWeight: FontWeight.w600)),
        onTap: onTap,
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

/// B3：筛选 bottom sheet（器官 / 时间范围 / 只看异常 / 标签 / 医院）。
/// 返回 `(filter, organ)` —— 器官原本是页面上单独的入口，现在收进这里一起选。
class _FilterSheet extends StatefulWidget {
  final RecordFilter initial;
  final String? initialOrgan;
  final List<String> allTags;
  final List<String> allHospitals;
  const _FilterSheet({
    required this.initial,
    required this.initialOrgan,
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
  String? _organ;
  DateTimeRange? _range;
  RecordDatePreset _preset = RecordDatePreset.all;

  @override
  void initState() {
    super.initState();
    _abnormalOnly = widget.initial.abnormalOnly;
    _tags = {...widget.initial.tags};
    _hospitals = {...widget.initial.hospitals};
    _organ = widget.initialOrgan;
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
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final maxDate = DateTime(now.year, now.month, now.day);
    final picked = await showCupertinoModalPopup<DateTimeRange>(
      context: context,
      builder: (_) => _DateRangeSheet(
        start: _range?.start ?? DateTime(now.year, now.month - 1, now.day),
        end: _range?.end ?? maxDate,
        maxDate: maxDate,
      ),
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
              const Text('器官',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TypePill(
                    label: '全部',
                    selected: _organ == null,
                    onTap: () => setState(() => _organ = null),
                  ),
                  for (final a in coreBodyAreaOrder)
                    _TypePill(
                      label: a,
                      selected: _organ == a,
                      onTap: () => setState(
                          () => _organ = _organ == a ? null : a),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Expanded(child: Text('只看异常')),
                    CupertinoSwitch(
                      value: _abnormalOnly,
                      onChanged: (v) => setState(() => _abnormalOnly = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('时间范围',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in const {
                    '全部': RecordDatePreset.all,
                    '近 1 个月': RecordDatePreset.month1,
                    '近 3 个月': RecordDatePreset.month3,
                    '近 1 年': RecordDatePreset.year1,
                  }.entries)
                    _TypePill(
                      label: e.key,
                      selected: _preset == e.value,
                      onTap: () => _applyPreset(e.value),
                    ),
                  _TypePill(
                    label: _preset == RecordDatePreset.custom && _range != null
                        ? '${formatDateShort(_range!.start)}~${formatDateShort(_range!.end)}'
                        : '自定义',
                    selected: _preset == RecordDatePreset.custom,
                    onTap: _pickCustomRange,
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
                  runSpacing: 8,
                  children: [
                    for (final t in widget.allTags)
                      _TypePill(
                        label: t,
                        selected: _tags.contains(t),
                        onTap: () => setState(() =>
                            _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
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
                  runSpacing: 8,
                  children: [
                    for (final h in widget.allHospitals)
                      _TypePill(
                        label: h,
                        selected: _hospitals.contains(h),
                        onTap: () => setState(() => _hospitals.contains(h)
                            ? _hospitals.remove(h)
                            : _hospitals.add(h)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => Navigator.of(context).pop((
                        filter: RecordFilter(query: widget.initial.query),
                        organ: null,
                      )),
                      child: const Text('重置',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => Navigator.of(context).pop((
                        filter: RecordFilter(
                          query: widget.initial.query,
                          abnormalOnly: _abnormalOnly,
                          tags: _tags,
                          hospitals: _hospitals,
                          dateRange: _range,
                        ),
                        organ: _organ,
                      )),
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

/// iOS 风格的「起 / 止」日期区间选择器：顶部分段切「开始 / 结束」，下面一个滚轮。
/// 取代 Material 的整屏 `showDateRangePicker`。
class _DateRangeSheet extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final DateTime maxDate;
  const _DateRangeSheet({
    required this.start,
    required this.end,
    required this.maxDate,
  });

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  late DateTime _start = _dateOnly(widget.start);
  late DateTime _end = _dateOnly(widget.end);
  bool _editingEnd = false;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final active = _editingEnd ? _end : _start;
    return Container(
      height: 340,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(
                    DateTimeRange(
                      start: _start,
                      end: _end.isBefore(_start) ? _start : _end,
                    ),
                  ),
                  child: const Text('完成',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CupertinoSlidingSegmentedControl<bool>(
                groupValue: _editingEnd,
                onValueChanged: (v) => setState(() => _editingEnd = v ?? false),
                children: {
                  false: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('开始  ${formatDate(_start)}'),
                  ),
                  true: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('结束  ${formatDate(_end)}'),
                  ),
                },
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                key: ValueKey(_editingEnd),
                mode: CupertinoDatePickerMode.date,
                initialDateTime: active,
                minimumDate: _editingEnd ? _start : DateTime(2000),
                maximumDate: widget.maxDate,
                onDateTimeChanged: (d) => setState(() {
                  final v = _dateOnly(d);
                  if (_editingEnd) {
                    _end = v;
                  } else {
                    _start = v;
                    if (_end.isBefore(_start)) _end = _start;
                  }
                }),
              ),
            ),
          ],
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
                  runSpacing: 8,
                  children: [
                    for (final t in _tags)
                      GestureDetector(
                        onTap: () => setState(() => _tags.remove(t)),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.primary)),
                              const SizedBox(width: 4),
                              const Icon(CupertinoIcons.xmark_circle_fill,
                                  size: 15, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _ctrl,
                placeholder: '新建标签',
                onSubmitted: _add,
                suffix: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  onPressed: () => _add(_ctrl.text),
                  child: const Icon(CupertinoIcons.add, size: 20),
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions.take(12))
                      _TypePill(
                        label: s,
                        selected: false,
                        onTap: () => _add(s),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () => Navigator.of(context).pop(_tags),
                child: const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
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
          IosButton.tinted('编辑', onPressed: _edit, expand: true),
          const SizedBox(height: 8),
          CupertinoButton(
            onPressed: _delete,
            child: const Text('删除',
                style: TextStyle(fontSize: 16, color: AppColors.abnormal)),
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
    final bool? confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('确定删除这条健康记录吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
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
