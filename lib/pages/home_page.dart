import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/checkup_coverage.dart';
import '../utils/format.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/section_title.dart';
import 'daily_health_entry_page.dart';
import 'notification_center_page.dart';
import 'reminders_page.dart';
import 'report_capture_page.dart';
import 'report_detail_page.dart';
import 'report_import_page.dart';

const double _kContentMaxWidth = 720;

/// 首页 = 两个驱动:
///  - 报告驱动:打开就想「把刚拿到的报告存进去」→ 两个大按钮
///  - 检查驱动:「我该做的检查跟上了吗」→ 完成度 + 待办
/// 加一段「最近存了什么」确认它在工作。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  int _unread = 0;
  int _todo = 0;
  CoverageOverview? _coverage;
  List<MedicalReport> _recentReports = const [];
  String _memberName = '本人';

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

      final profile = await repo.getProfile();
      final metrics = await repo.getAllMetrics();
      final reports = await repo.getAllReports();
      final daily = await repo.getAllDailyRecords();
      final reminders = await repo.getActiveReminders();
      final unread = await repo.unreadNotificationCount();

      final now = DateTime.now();
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      var todo = 0;
      for (final r in reminders) {
        if (r.kind == 'recheck' || r.kind == 'followup') {
          if (r.completedAt == null &&
              r.dueDate != null &&
              !r.dueDate!.isAfter(endOfToday)) {
            todo++;
          }
        } else if (r.kind == 'medication' && r.enabled) {
          todo++;
        }
      }

      final coverage = buildCheckupCoverage(
        metrics: metrics,
        reports: reports,
        daily: daily,
        now: now,
      );

      final sorted = [...reports]
        ..sort((a, b) => b.reportDate.compareTo(a.reportDate));

      if (mounted) {
        setState(() {
          _memberName = (profile?.nickname.trim().isNotEmpty ?? false)
              ? profile!.nickname.trim()
              : '本人';
          _unread = unread;
          _todo = todo;
          _coverage = coverage;
          _recentReports = sorted.take(3).toList();
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

  Future<void> _captureLab() async {
    final mode = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined,
                color: AppColors.primary),
            title: const Text('拍照'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined,
                color: AppColors.primary),
            title: const Text('从相册或文件选'),
            subtitle: const Text('图片或 PDF'),
            onTap: () => Navigator.pop(context, 'upload'),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (!mounted) return;
    if (mode == 'camera') {
      _push(const ReportCapturePage());
    } else if (mode == 'upload') {
      _push(const ReportImportPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          _BellAction(unread: _unread, onTap: () {
            _push(const NotificationCenterPage());
          }),
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
                      _MemberHeader(name: _memberName),
                      const SizedBox(height: 14),

                      // 检查驱动:待办 + 完成度
                      _StatusCard(
                        todo: _todo,
                        coverage: _coverage,
                        onTapTodo: () => _push(const RemindersPage()),
                        onTapCoverage: _coverage == null
                            ? null
                            : () => _push(_CoverageDetailPage(
                                  overview: _coverage!,
                                )),
                      ),
                      const SizedBox(height: 18),

                      // 报告驱动:两个大按钮
                      const SectionTitle(title: '添加'),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: _BigButton(
                            icon: Icons.photo_camera_outlined,
                            label: '拍化验单',
                            onTap: _captureLab,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigButton(
                            icon: Icons.image_outlined,
                            label: '从相册 / 文件',
                            onTap: () => _push(const ReportImportPage()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _MiniButton(
                        label: '记一次血压 / 血糖 / 体重',
                        onTap: () => _push(const DailyHealthEntryPage()),
                      ),
                      const SizedBox(height: 18),

                      // 最近存了什么
                      const SectionTitle(title: '最近'),
                      if (_recentReports.isEmpty)
                        const _QuietText('还没有存过报告，点上面「拍化验单」开始。')
                      else
                        for (final r in _recentReports)
                          _RecentTile(
                            report: r,
                            onTap: () => _push(
                                ReportDetailPage(reportId: r.id)),
                          ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  final String name;
  const _MemberHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final viewingOther = (appRepository?.activeProfileId ?? 1) !=
        HealthRepository.defaultProfileId;
    return Row(children: [
      const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE0F2F1),
        child: Icon(Icons.person, color: AppColors.primary, size: 20),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text(viewingOther ? '家庭成员档案' : '本人档案',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ]);
  }
}

class _StatusCard extends StatelessWidget {
  final int todo;
  final CoverageOverview? coverage;
  final VoidCallback onTapTodo;
  final VoidCallback? onTapCoverage;

  const _StatusCard({
    required this.todo,
    required this.coverage,
    required this.onTapTodo,
    required this.onTapCoverage,
  });

  @override
  Widget build(BuildContext context) {
    final cov = coverage;
    final due = cov?.dueList ?? const [];
    final dueLabels = due.take(3).map((a) => a.aspect.label).join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 待办行
            InkWell(
              onTap: todo > 0 ? onTapTodo : null,
              borderRadius: BorderRadius.circular(8),
              child: Row(children: [
                Icon(
                  todo > 0 ? Icons.notifications_active_outlined
                           : Icons.check_circle_outline,
                  size: 20,
                  color: todo > 0 ? AppColors.warning : AppColors.normal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    todo > 0 ? '$todo 项待办：该复查 / 该服药' : '目前没有待办',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ),
                if (todo > 0)
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
              ]),
            ),

            if (cov != null) ...[
              const Divider(height: 22),
              InkWell(
                onTap: onTapCoverage,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(cov.headline,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ),
                      Text('${cov.coveredCount} / ${cov.total}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: cov.ratio,
                        minHeight: 7,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: .12),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      due.isEmpty
                          ? '该做的检查都跟上了'
                          : '该做的：$dueLabels',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: due.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.warning),
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
}

class _CoverageDetailPage extends StatelessWidget {
  final CoverageOverview overview;
  const _CoverageDetailPage({required this.overview});

  @override
  Widget build(BuildContext context) {
    final list = [...overview.aspects]..sort((a, b) {
        int rank(AspectStatus s) => s.neverDone ? 0 : (s.overdue ? 1 : 2);
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : a.aspect.label.compareTo(b.aspect.label);
      });
    return Scaffold(
      appBar: AppBar(title: const Text('检查完成度')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(overview.headline,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('按常见体检项目粗算，只作提醒，不是医疗建议。具体查什么听医生的。',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          for (final s in list)
            Card(
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                title: Text(s.aspect.label,
                    style: const TextStyle(fontSize: 15)),
                subtitle: Text(
                  s.lastDone == null
                      ? '从没查过 · ${s.aspect.cycleText}'
                      : '上次 ${formatDate(s.lastDone!)} · ${s.aspect.cycleText}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: _CoverChip(s),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverChip extends StatelessWidget {
  final AspectStatus s;
  const _CoverChip(this.s);
  @override
  Widget build(BuildContext context) {
    late final String t;
    late final Color c;
    if (s.neverDone) {
      t = '没查过';
      c = AppColors.insufficient;
    } else if (s.overdue) {
      t = '该查了';
      c = AppColors.warning;
    } else {
      t = '已覆盖';
      c = AppColors.normal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(t,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: c)),
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
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(children: [
            Icon(icon, size: 26, color: AppColors.primary),
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

class _MiniButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: Color(0xFFC9D3D1)),
        foregroundColor: AppColors.textSecondary,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
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
    return Card(
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: const Icon(Icons.description_outlined,
            color: AppColors.textSecondary),
        title: Text(label.isEmpty ? '报告' : label,
            style: const TextStyle(fontSize: 14)),
        subtitle: Text(formatDate(r.reportDate),
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        onTap: onTap,
      ),
    );
  }
}

class _QuietText extends StatelessWidget {
  final String text;
  const _QuietText(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      );
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
