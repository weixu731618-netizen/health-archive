import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/section_title.dart';
import 'body_page.dart';
import 'imaging_report_page.dart';
import 'notification_center_page.dart';
import 'reminders_page.dart';
import 'report_capture_page.dart';
import 'report_detail_page.dart';
import 'report_import_page.dart';

const double _kContentMaxWidth = 720;

/// 首页 = 一句话说清 App 是什么：
///  「拍 / 导入医疗报告，长期保存并追踪的健康档案」。
///
/// 自上而下:
///  1. 拍报告 —— 第一优先级，配相册 / 文件 / 影像
///  2. 需要关注 —— 有异常 / 待复查才显示；超过 3 行折叠
///  3. 最近 —— 最近导入的医疗资料
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  int _unread = 0;

  /// 首页「需要关注」上门槛：即将到期的复查只提前这么多天进首页，
  /// 更远的留在「提醒」页里，不占首页注意力。
  static const int _upcomingWindowDays = 30;

  List<HealthMetric> _metrics = const [];
  List<_AttentionArea> _attention = const [];
  List<Reminder> _overdueFollowups = const [];
  List<Reminder> _upcomingFollowups = const [];
  List<MedicalReport> _recent = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      try {
        await repo.regenerateFollowUpsForAllProfiles();
      } catch (_) {}
      await repo.syncNotificationsFromReminders();

      final metrics = await repo.getAllMetrics();
      final reports = await repo.getAllReports();
      final reminders = await repo.getActiveReminders();
      final unread = await repo.actionableUnreadCount();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final horizon = today.add(const Duration(days: _upcomingWindowDays));

      // 首页「需要关注」把三类东西分开处理，不再互相混合：
      //   1) FollowUpTask —— 真实存在的复查 / 随访提醒（已到期 / 即将到期）
      //   2) HealthAttention —— 身体部位层面的异常 / 需关注
      //   3) ChronicCondition（长期关注）—— 不在首页高频展示疾病名，放到详情页
      final followups = <Reminder>[
        for (final r in reminders)
          if ((r.kind == 'recheck' || r.kind == 'followup') &&
              r.completedAt == null &&
              r.dueDate != null)
            r,
      ]..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

      final overdue = [
        for (final r in followups)
          if (r.dueDate!.isBefore(today)) r,
      ];
      final upcoming = [
        for (final r in followups)
          if (!r.dueDate!.isBefore(today) && !r.dueDate!.isAfter(horizon)) r,
      ];

      // HealthAttention：只看身体部位的异常 / 需关注，不再往上贴复查后缀。
      final attention = [
        for (final a in buildBodyAreaHealthFromMetrics(metrics)
            .where((a) => a.priorityRank <= 1))
          _AttentionArea(area: a),
      ];

      final sortedReports = [...reports]
        ..sort((a, b) => b.reportDate.compareTo(a.reportDate));

      if (mounted) {
        setState(() {
          _unread = unread;
          _metrics = metrics;
          _attention = attention;
          _overdueFollowups = overdue;
          _upcomingFollowups = upcoming;
          _recent = sortedReports.take(3).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _push(Widget page) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => page))
      .then((_) => _load());

  /// 需要关注：按「已到期复查 → 即将到期复查 → 当前明确异常」排序。
  /// 长期关注（慢性病）不在首页列，放到部位详情页。
  /// 首页最多显示前 3 项，超过时给一行「查看全部 N 项 ›」进完整列表页。
  List<Widget> _attentionWidgets() => [
        for (final r in _overdueFollowups)
          _RecheckRow(
            reminder: r,
            onTap: () => _push(const RemindersPage()),
          ),
        for (final r in _upcomingFollowups)
          _RecheckRow(
            reminder: r,
            onTap: () => _push(const RemindersPage()),
          ),
        for (final a in _attention)
          _AttentionCard(
            entry: a,
            onTap: () => _push(BodySystemDetailPage(
              area: a.area,
              allMetrics: _metrics,
              isExample: false,
            )),
          ),
      ];

  List<Widget> _buildAttentionRows() {
    final rows = _attentionWidgets();
    const cap = 3;
    final shown = rows.length > cap ? rows.sublist(0, cap) : rows;

    return [
      for (final w in shown) ...[w, const SizedBox(height: 10)],
      if (rows.length > cap)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _push(AttentionListPage(
              metrics: _metrics,
              overdueFollowups: _overdueFollowups,
              upcomingFollowups: _upcomingFollowups,
              attentionAreas: [for (final a in _attention) a.area],
            )),
            child: Text('查看全部 ${rows.length} 项 ›'),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final showAttention = _attention.isNotEmpty ||
        _overdueFollowups.isNotEmpty ||
        _upcomingFollowups.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          _BellAction(
            unread: _unread,
            onTap: () => _push(const NotificationCenterPage()),
          ),
          const ProfileSwitcher(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? ListView(children: const [
                    SizedBox(height: 160),
                    Center(child: CircularProgressIndicator()),
                  ])
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      // 拍报告为第一优先级
                      _PrimaryAddCard(
                        onTap: () => _push(const ReportCapturePage()),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _BigButton(
                            icon: Icons.image_outlined,
                            label: '导入报告',
                            onTap: () => _push(const ReportImportPage()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigButton(
                            icon: Icons.medical_information_outlined,
                            label: '添加医学影像',
                            onTap: () => _push(const ImagingReportPage()),
                          ),
                        ),
                      ]),

                      // 2. 需要关注 —— 有内容才显示；超过 3 行折叠
                      if (showAttention) ...[
                        const SizedBox(height: 22),
                        const SectionTitle(title: '需要关注'),
                        const SizedBox(height: 8),
                        ..._buildAttentionRows(),
                      ],

                      // 3. 最近
                      const SizedBox(height: 22),
                      const SectionTitle(title: '最近'),
                      const SizedBox(height: 8),
                      if (_recent.isEmpty)
                        const _EmptyRecent()
                      else
                        for (final r in _recent)
                          _RecentTile(
                            report: r,
                            onTap: () =>
                                _push(ReportDetailPage(reportId: r.id)),
                          ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AttentionArea {
  final BodyAreaHealthSummary area;
  const _AttentionArea({required this.area});
}

/// 首页第一优先级入口：拍报告。
class _PrimaryAddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PrimaryAddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(children: [
            const Icon(Icons.photo_camera_outlined,
                size: 30, color: AppColors.primary),
            const SizedBox(height: 10),
            const Text('拍检查资料',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('现场拍摄纸质检查报告',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: .8))),
          ]),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BigButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ]),
        ),
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final _AttentionArea entry;
  final VoidCallback onTap;
  const _AttentionCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final area = entry.area;
    final isAbnormal = area.status == '异常';
    final dotColor = isAbnormal ? AppColors.abnormal : AppColors.warning;
    final count = area.abnormalCount;
    final countText = count > 0 ? '$count 项指标异常' : '需要关注';

    return Card(
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(Icons.circle, size: 12, color: dotColor),
        title: Text(area.name, style: const TextStyle(fontSize: 15)),
        subtitle: Text(countText,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _RecheckRow extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  const _RecheckRow({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final due = reminder.dueDate!;
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final overdue = dueDay.isBefore(today);
    final days = dueDay.difference(today).inDays;
    // 只有「已到期 / 就在今天」这种确定要现在处理的才上橙色；
    // 「还有 N 天」是普通信息，走灰色，不抢注意力。
    final urgent = overdue || days == 0;
    final String sub;
    if (overdue) {
      sub = '复查已到期';
    } else if (days == 0) {
      sub = '复查就在今天';
    } else {
      sub = '距离复查还有 $days 天';
    }
    return Card(
      child: ListTile(
        dense: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(Icons.event_outlined,
            color: urgent ? AppColors.warning : AppColors.textSecondary),
        title: Text(reminder.title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          sub,
          style: TextStyle(
              fontSize: 12,
              color: urgent ? AppColors.warning : AppColors.textSecondary),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final MedicalReport report;
  final VoidCallback onTap;
  const _RecentTile({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = report;
    final label = [r.hospitalName, r.reportType]
        .where((e) => e.trim().isNotEmpty)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          leading: const Icon(Icons.description_outlined,
              color: AppColors.textSecondary),
          title: Text(label.isEmpty ? '报告' : label,
              style: const TextStyle(fontSize: 14)),
          subtitle: Text(formatDate(r.reportDate),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// 首页「最近」空状态：只说明，不放操作按钮（上传入口在页面顶部）。
class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('还没有健康记录',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            SizedBox(height: 6),
            Text('添加第一份资料后，这里会显示最近的检查和健康变化。',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _BellAction extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;
  const _BellAction({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      IconButton(
        tooltip: '通知',
        icon: const Icon(Icons.notifications_none),
        onPressed: onTap,
      ),
      if (unread > 0)
        Positioned(
          right: 6,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: AppColors.abnormal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              unread > 99 ? '99+' : '$unread',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ),
    ]);
  }
}

/// 首页「需要关注」的完整列表页（点「查看全部 N 项」进入）。
/// 用与首页完全相同的行，只是不截断。数据由首页传入，不重新查库。
class AttentionListPage extends StatelessWidget {
  final List<HealthMetric> metrics;
  final List<Reminder> overdueFollowups;
  final List<Reminder> upcomingFollowups;
  final List<BodyAreaHealthSummary> attentionAreas;

  const AttentionListPage({
    super.key,
    required this.metrics,
    required this.overdueFollowups,
    required this.upcomingFollowups,
    required this.attentionAreas,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final r in overdueFollowups)
        _RecheckRow(
          reminder: r,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersPage())),
        ),
      for (final r in upcomingFollowups)
        _RecheckRow(
          reminder: r,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersPage())),
        ),
      for (final a in attentionAreas)
        _AttentionCard(
          entry: _AttentionArea(area: a),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BodySystemDetailPage(
              area: a,
              allMetrics: metrics,
              isExample: false,
            ),
          )),
        ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('需要关注')),
      body: rows.isEmpty
          ? const Center(
              child: Text('当前没有需要关注的项目',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => rows[i],
            ),
    );
  }
}
