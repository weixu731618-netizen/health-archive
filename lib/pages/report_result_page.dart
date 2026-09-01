import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../models/body_area_health.dart';
import '../models/report_followup.dart';
import '../services/analytics.dart';
import '../utils/format.dart';
import 'body_page.dart';
import 'report_detail_page.dart';

/// 一条刚入库的指标的精简信息（结果页用，避免结果页再反查全部字段）。
class SavedMetricLine {
  final String metricId;
  final String name;
  final String status;
  final double value;
  final String unit;
  final String bodySystem;

  const SavedMetricLine({
    required this.metricId,
    required this.name,
    required this.status,
    required this.value,
    required this.unit,
    required this.bodySystem,
  });

  bool get isAbnormal => isMetricAbnormalStatus(status);
}

/// §11–§12 / §30–§31：一次报告识别 + 保存完成后的「整理结果页」。
///
/// 这是「让用户看到系统做了什么」的关键一屏 —— 保存成功后 `pushReplacement`
/// 到这里，而不是直接 pop 回列表。
class ReportResultPage extends StatefulWidget {
  final int reportId;
  final String reportType;
  final DateTime reportDate;
  final String hospitalName;
  final List<SavedMetricLine> metrics;

  /// 显式关联到的身体系统（含从指标推导 + 用户/上下文选的）。
  final Set<String> areas;

  /// 报告原始识别文本，用于判断是否含「复查 / 随访」建议。
  final String rawText;

  /// 后端是否给出了检查日期。false 时结果页提示用户确认日期（§21）。
  final bool dateFromOcr;

  /// 当前档案名。仅多档案时传非 null，用于显示「已保存到：X」（§25）。
  final String? savedProfileName;

  /// E4：核对页保存后已弹过关联窗、且用户把这份报告关联成了某条待复查。
  /// 为 true 时结果页不再重复提示「设置复查提醒」。
  final bool alreadyLinkedFollowup;

  const ReportResultPage({
    super.key,
    required this.reportId,
    required this.reportType,
    required this.reportDate,
    required this.hospitalName,
    required this.metrics,
    required this.areas,
    required this.rawText,
    required this.dateFromOcr,
    this.savedProfileName,
    this.alreadyLinkedFollowup = false,
  });

  @override
  State<ReportResultPage> createState() => _ReportResultPageState();
}

class _ReportResultPageState extends State<ReportResultPage> {
  /// metricId → 上一条历史值（若有）。用于「较上次」对比。
  final Map<String, HealthMetric> _prev = {};
  bool _recheckSet = false;

  int get _total => widget.metrics.length;
  int get _abnormal => widget.metrics.where((m) => m.isAbnormal).length;
  int get _normal => _total - _abnormal;

  /// 涉及的身体系统 + 每个系统里本次有几项需要关注，按需关注数降序。
  List<({String name, int abnormal})> get _systems {
    final byArea = <String, int>{};
    for (final a in widget.areas) {
      byArea.putIfAbsent(a, () => 0);
    }
    for (final m in widget.metrics) {
      // 未匹配标准指标的（metricId == 'UNKNOWN'）不计入身体系统，也不新建「其他」。
      if (m.metricId == 'UNKNOWN') continue;
      final a = bodyAreaForSystem(m.bodySystem);
      byArea.update(a, (v) => v + (m.isAbnormal ? 1 : 0),
          ifAbsent: () => m.isAbnormal ? 1 : 0);
    }
    final list = [
      for (final e in byArea.entries) (name: e.key, abnormal: e.value),
    ]..sort((x, y) => y.abnormal.compareTo(x.abnormal));
    return list;
  }

  bool get _suggestsRecheck {
    // E4：核对页已关联过复查，就不再提示。
    if (widget.alreadyLinkedFollowup) return false;
    final t = widget.rawText.trim();
    if (t.isEmpty) return false; // E5：没识别出全文就别猜
    // E5：先排除明确「不用复查」的说法，避免命中里面的「复查」二字。
    const negative = ['无需复查', '不需复查', '无须复查', '暂不复查', '无复查', '不必复查'];
    if (negative.any(t.contains)) return false;
    const kw = ['复查', '随访', '复诊', '定期检查', '定期复查', '按时复查'];
    return kw.any(t.contains);
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    AnalyticsEvents.reportResultViewed(
      metricCount: _total,
      abnormalCount: _abnormal,
      systemCount: widget.areas.length,
    );
  }

  Future<void> _loadHistory() async {
    final repo = appRepository;
    if (repo == null) return;
    var compared = 0;
    for (final m in widget.metrics) {
      if (m.metricId.isEmpty || m.metricId == 'UNKNOWN') continue;
      try {
        final hist = await repo.getMetricHistory(m.metricId);
        // hist 按 measuredAt 倒序；[0] 是刚存的这条，[1] 才是上一条。
        if (hist.length >= 2) {
          _prev[m.metricId] = hist[1];
          compared++;
        }
      } catch (_) {}
    }
    if (compared > 0) {
      AnalyticsEvents.historicalCompareViewed(comparedMetrics: compared);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final compares = [
      for (final m in widget.metrics)
        if (_prev[m.metricId] case final p?)
          (line: m, prev: p, delta: metricDeltaLine(m.value, p.value, m.unit)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('报告整理结果'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Header(
            reportType:
                widget.reportType.isEmpty ? '报告' : widget.reportType,
            reportDate: widget.reportDate,
            hospitalName: widget.hospitalName,
            savedProfileName: widget.savedProfileName,
          ),
          if (!widget.dateFromOcr) ...[
            const SizedBox(height: 10),
            _DateConfirmCard(
              date: widget.reportDate,
              reportId: widget.reportId,
            ),
          ],
          const SizedBox(height: 18),
          const _SectionLabel('本次结果'),
          _StatRow(label: '识别指标', value: '$_total 项', strong: true),
          _StatRow(label: '正常', value: '$_normal 项'),
          _StatRow(
            label: '需要关注',
            value: '$_abnormal 项',
            valueColor: _abnormal > 0 ? AppColors.warning : null,
            // E6：有需要关注的指标时，点这行去报告详情看是哪几项。
            onTap: _abnormal > 0
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ReportDetailPage(reportId: widget.reportId)))
                : null,
          ),
          if (_systems.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionLabel('涉及身体'),
            for (final s in _systems)
              _SystemRow(
                name: s.name,
                abnormal: s.abnormal,
                onTap: () => _openArea(s.name),
              ),
          ],
          if (compares.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionLabel('与历史对比'),
            for (final c in compares)
              _CompareRow(
                name: c.line.name,
                prevText:
                    '上次 ${_fmt(c.prev.value)}${c.line.unit.isEmpty ? '' : ' ${c.line.unit}'}'
                    '（${formatDate(c.prev.measuredAt)}）',
                curText:
                    '本次 ${_fmt(c.line.value)}${c.line.unit.isEmpty ? '' : ' ${c.line.unit}'}',
                delta: c.delta,
              ),
          ],
          const SizedBox(height: 16),
          const _HintCard(
            text: '以后上传同类报告，可自动和这些历史记录比较变化。',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_suggestsRecheck && !_recheckSet)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IosButton.tinted(
                    '这份报告建议复查 · 设置提醒',
                    icon: CupertinoIcons.alarm,
                    onPressed: _setRecheck,
                    expand: true,
                  ),
                ),
              if (_recheckSet)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('已设置复查提醒',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
              IosButton.filled(
                '完成',
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                expand: true,
              ),
              const SizedBox(height: 4),
              IosButton.plain(
                '查看原始报告',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ReportDetailPage(reportId: widget.reportId))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openArea(String areaName) {
    final repo = appRepository;
    if (repo == null) return;
    repo.getAllMetrics().then((all) {
      if (!mounted) return;
      final area = buildBodyAreaHealthFromMetrics(all).firstWhere(
        (s) => s.name == areaName,
        orElse: () => BodyAreaHealthSummary(
            name: areaName, status: '数据不足', metrics: const []),
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BodySystemDetailPage(
          area: area,
          allMetrics: all,
          isExample: false,
        ),
      ));
    });
  }

  Future<void> _setRecheck() async {
    final repo = appRepository;
    if (repo == null) return;
    final months = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('多久之后复查？',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            for (final m in const [1, 3, 6, 12])
              ListTile(
                title: Text('$m 个月后'),
                onTap: () => Navigator.pop(context, m),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (months == null) return;
    final due = DateTime.now().add(Duration(days: months * 30));
    // 复查目标以「涉及的身体系统」为主，不叫「复查 生化检查」这种泛报告名。
    // 报告没关联到任何系统时，才退回用报告类型。
    final areaList = widget.areas.toList();
    final String title;
    final String? areaName;
    if (areaList.isNotEmpty) {
      final shown = areaList.take(2).join('、');
      title = '复查 $shown${areaList.length > 2 ? ' 等' : ''}';
      areaName = areaList.first;
    } else {
      title = '复查 ${widget.reportType.isEmpty ? '报告' : widget.reportType}';
      areaName = null;
    }
    try {
      await repo.insertReminder(
        kind: 'recheck',
        title: title,
        detail: '来自 ${formatDate(widget.reportDate)} 的报告建议',
        dueDate: due,
        sourceType: 'report',
        areaName: areaName,
      );
      await syncReminders();
      AnalyticsEvents.followupCreatedFromResult();
      if (mounted) setState(() => _recheckSet = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('设置失败，请重试')));
      }
    }
  }
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

class _Header extends StatelessWidget {
  final String reportType;
  final DateTime reportDate;
  final String hospitalName;
  final String? savedProfileName;
  const _Header({
    required this.reportType,
    required this.reportDate,
    required this.hospitalName,
    required this.savedProfileName,
  });

  @override
  Widget build(BuildContext context) {
    final sub = [
      formatDate(reportDate),
      if (hospitalName.trim().isNotEmpty) hospitalName.trim(),
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.normal, size: 22),
            SizedBox(width: 8),
            Text('已整理完成',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),
        Text(reportType,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(sub,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        if (savedProfileName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('已保存到：$savedProfileName',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;
  final VoidCallback? onTap;
  const _StatRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
              Row(
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: strong ? 15 : 14,
                          fontWeight:
                              strong ? FontWeight.w700 : FontWeight.w500,
                          color: valueColor ?? AppColors.textPrimary)),
                  if (onTap != null)
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      );
}

class _SystemRow extends StatelessWidget {
  final String name;
  final int abnormal;
  final VoidCallback onTap;
  const _SystemRow(
      {required this.name, required this.abnormal, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          abnormal > 0 ? '$abnormal 项需要关注' : '本次无异常',
          style: TextStyle(
              fontSize: 12,
              color: abnormal > 0
                  ? AppColors.warning
                  : AppColors.textSecondary),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String name;
  final String prevText;
  final String curText;
  final String? delta;
  const _CompareRow({
    required this.name,
    required this.prevText,
    required this.curText,
    required this.delta,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('$prevText → $curText',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            if (delta != null) ...[
              const SizedBox(height: 2),
              Text(delta!,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String text;
  const _HintCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.timeline_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary)),
            ),
          ],
        ),
      );
}

/// §21：后端没识别出检查日期时，提示用户确认（可跳过，不阻塞）。
class _DateConfirmCard extends StatefulWidget {
  final DateTime date;
  final int reportId;
  const _DateConfirmCard({required this.date, required this.reportId});
  @override
  State<_DateConfirmCard> createState() => _DateConfirmCardState();
}

class _DateConfirmCardState extends State<_DateConfirmCard> {
  late DateTime _date = widget.date;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('没能识别出检查日期',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('暂用 ${formatDate(_date)}。可以现在确认，也可以以后在报告详情里改。',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              IosButton.plain(
                '暂不填写',
                onPressed: () => setState(() => _done = true),
              ),
              const SizedBox(width: 4),
              IosButton.tinted('确认检查日期', onPressed: _pick),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await pickCupertinoDate(
      context,
      initial: _date,
      minimumDate: DateTime(2000),
      maximumDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null) return;
    final repo = appRepository;
    try {
      await repo?.updateReportDate(widget.reportId, picked);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _date = picked;
        _done = true;
      });
    }
  }
}
