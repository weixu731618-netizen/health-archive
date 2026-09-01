import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/backup_nudge.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_nav.dart';
import '../widgets/profile_switcher.dart';
import 'body_page.dart';
import 'notification_center_page.dart';
import 'privacy_page.dart';
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

  // —— 换机不丢数据（V1 无登录 / 云同步，只靠本地 zip 备份）——
  static const String _kRestoreHintDismissedKey = 'home_restore_hint_dismissed';
  static const String _kBackupNudgeAckKey = 'home_backup_nudge_ack_at';

  /// 本机还没有任何报告 / 指标：可能是新装机，提示可从旧机备份恢复。
  bool _dbEmpty = false;
  bool _restoreHintDismissed = false;

  /// 攒够报告且上次备份后又有新报告：提示导出一份本地备份。
  bool _showBackupNudge = false;

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
      final followupsAll = <Reminder>[
        for (final r in reminders)
          if ((r.kind == 'recheck' || r.kind == 'followup') &&
              r.completedAt == null &&
              r.dueDate != null)
            r,
      ]..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      // 去重：慢病自动排期偶尔给同一项目排出两条（如「眼底检查」×2），
      // 首页只留最早到期的那条。
      final seenTitles = <String>{};
      final followups = <Reminder>[
        for (final r in followupsAll)
          if (seenTitles.add(r.title.trim())) r,
      ];

      final overdue = [
        for (final r in followups)
          if (r.dueDate!.isBefore(today)) r,
      ];
      final upcoming = [
        for (final r in followups)
          if (!r.dueDate!.isBefore(today) && !r.dueDate!.isAfter(horizon)) r,
      ];

      // HealthAttention：身体部位的异常 / 需关注。首页只收「新的 / 变差的」——
      // 常年稳定的慢性异常（如一直 6.8 的糖化）不再挤首页，身体页照样标红。
      final attention = [
        for (final a in buildBodyAreaHealthFromMetrics(metrics)
            .where((a) => a.priorityRank <= 1))
          if (_areaIsFreshAttention(a, metrics, now))
            _AttentionArea(area: a),
      ];

      final sortedReports = [...reports]
        ..sort((a, b) => b.reportDate.compareTo(a.reportDate));

      // —— 备份提醒判定 ——
      final dbEmpty = reports.isEmpty && metrics.isEmpty;
      DateTime? newestReportCreatedAt;
      for (final r in reports) {
        if (newestReportCreatedAt == null ||
            r.createdAt.isAfter(newestReportCreatedAt)) {
          newestReportCreatedAt = r.createdAt;
        }
      }
      bool restoreHintDismissed = false;
      DateTime? nudgeAckAt;
      try {
        final prefs = await SharedPreferences.getInstance();
        restoreHintDismissed =
            prefs.getBool(_kRestoreHintDismissedKey) ?? false;
        final ack = prefs.getString(_kBackupNudgeAckKey);
        if (ack != null) nudgeAckAt = DateTime.tryParse(ack);
      } catch (_) {}
      final lastBackupAt = await localBackupService.getLastBackupAt();
      final showNudge = shouldShowBackupNudge(
        reportCount: reports.length,
        newestReportCreatedAt: newestReportCreatedAt,
        lastBackupAt: lastBackupAt,
        nudgeAckAt: nudgeAckAt,
      );

      if (mounted) {
        setState(() {
          _unread = unread;
          _metrics = metrics;
          _dbEmpty = dbEmpty;
          _restoreHintDismissed = restoreHintDismissed;
          _showBackupNudge = showNudge;
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

  Future<void> _dismissRestoreHint() async {
    setState(() => _restoreHintDismissed = true);
    try {
      await (await SharedPreferences.getInstance())
          .setBool(_kRestoreHintDismissedKey, true);
    } catch (_) {}
  }

  Future<void> _dismissBackupNudge() async {
    setState(() => _showBackupNudge = false);
    try {
      await (await SharedPreferences.getInstance()).setString(
          _kBackupNudgeAckKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  Future<void> _push(Widget page) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => page))
      .then((_) => _load());

  /// 首页「待跟进」只收「新的 / 变差的」异常部位——判定：该部位有一项异常指标
  /// ① 最新一次测量在 60 天内，或 ② 比上一次读数更偏离参考范围（含新变异常）。
  bool _areaIsFreshAttention(
      BodyAreaHealthSummary a, List<HealthMetric> all, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 60));
    for (final m in a.metrics) {
      if (!m.isAbnormal) continue;
      if (m.measuredAt != null && m.measuredAt!.isAfter(cutoff)) return true;
      final hist = all.where((x) => x.metricId == m.metricId).toList()
        ..sort((x, y) => y.measuredAt.compareTo(x.measuredAt));
      if (hist.length >= 2) {
        final latest = hist[0];
        final prev = hist[1];
        if (!isMetricAbnormalStatus(prev.status)) return true; // 新变异常
        final ld = _deviation(latest);
        final pd = _deviation(prev);
        if (ld != null && pd != null && ld > pd + 1e-9) return true; // 变差
      }
    }
    return false;
  }

  /// 数值偏离参考范围的绝对量（在范围内为 0，缺范围为 null）。
  double? _deviation(HealthMetric m) {
    final v = m.value;
    final lo = m.referenceMin;
    final hi = m.referenceMax;
    if (lo != null && v < lo) return lo - v;
    if (hi != null && v > hi) return v - hi;
    if (lo == null && hi == null) return null;
    return 0;
  }

  /// 待跟进里点复查行：弹「标记已复查 / 推迟 / 取消」。
  Future<void> _recheckActions(Reminder r) async {
    final repo = appRepository;
    if (repo == null) return;
    final pick = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(r.title),
        message: const Text('复查计划'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'done'),
            child: const Text('标记已复查'),
          ),
          if (r.kind == 'recheck')
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'snooze'),
              child: const Text('推迟 1 个月'),
            ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'open'),
            child: const Text('去提醒页'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (pick == null || !mounted) return;
    if (pick == 'done') {
      await repo.markReminderCompleted(r.id);
      await syncReminders();
      _load();
    } else if (pick == 'snooze') {
      await repo.snoozeReminder(
          r.id, DateTime.now().add(const Duration(days: 30)));
      await syncReminders();
      _load();
    } else if (pick == 'open') {
      _push(const RemindersPage());
    }
  }

  /// 待跟进：按「已到期复查 → 即将到期复查 → 当前明确异常」排序。
  /// 长期关注（慢性病）不在首页列，放到部位详情页。
  /// 首页最多显示前 3 项，超过时给一行「查看全部 N 项 ›」进完整列表页。
  List<Widget> _attentionTiles() => [
        for (final r in _overdueFollowups)
          _RecheckRow(
            reminder: r,
            onTap: () => _recheckActions(r),
          ),
        for (final r in _upcomingFollowups)
          _RecheckRow(
            reminder: r,
            onTap: () => _recheckActions(r),
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

  int get _attentionTotal =>
      _overdueFollowups.length + _upcomingFollowups.length + _attention.length;

  void _openAttentionList() => _push(AttentionListPage(
        metrics: _metrics,
        overdueFollowups: _overdueFollowups,
        upcomingFollowups: _upcomingFollowups,
        attentionAreas: [for (final a in _attention) a.area],
      ));

  Widget _attentionSection() {
    final tiles = _attentionTiles();
    const cap = 3;
    final shown = tiles.length > cap ? tiles.sublist(0, cap) : tiles;
    return HealthCard(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      child: Column(children: shown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAttention = _attention.isNotEmpty ||
        _overdueFollowups.isNotEmpty ||
        _upcomingFollowups.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: RefreshIndicator.adaptive(
            onRefresh: _load,
            child: CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: const Text('首页'),
                  backgroundColor:
                      AppColors.background.withValues(alpha: 0.85),
                  trailing: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BellAction(
                          unread: _unread,
                          onTap: () =>
                              _push(const NotificationCenterPage()),
                        ),
                        const ProfileSwitcher(),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 120),
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                      // 拍报告为第一优先级
                      _PrimaryAddCard(
                        onTap: () => _push(const ReportCapturePage()),
                      ),
                      const SizedBox(height: 12),
                      // 上传统一入口：化验单、影像、病历、处方都走这里，识别后
                      // 自动分流（有指标→逐项核对；没指标→图文报告）。
                      _BigButton(
                        icon: CupertinoIcons.cloud_upload,
                        label: '上传截图或 PDF',
                        onTap: () => _push(const ReportImportPage()),
                      ),

                      // 换机不丢数据：新装机提示可从旧机备份恢复
                      if (_dbEmpty && !_restoreHintDismissed) ...[
                        const SizedBox(height: 12),
                        _RestoreHintCard(
                          onTap: () => _push(const PrivacyPage()),
                          onDismiss: _dismissRestoreHint,
                        ),
                      ],

                      // 攒够报告且上次备份后又有新报告：提示导出本地备份
                      if (!_dbEmpty && _showBackupNudge) ...[
                        const SizedBox(height: 12),
                        _BackupNudgeCard(
                          onTap: () => _push(const PrivacyPage()),
                          onDismiss: _dismissBackupNudge,
                        ),
                      ],

                      // 2. 待跟进 —— 有内容才显示；超过 3 行折叠
                      if (showAttention) ...[
                        HealthSectionHeader(
                          '待跟进',
                          actionLabel: _attentionTotal > 3
                              ? '全部 $_attentionTotal 项'
                              : null,
                          onAction:
                              _attentionTotal > 3 ? _openAttentionList : null,
                        ),
                        _attentionSection(),
                      ],

                      // 3. 最近
                      HealthSectionHeader(
                        '最近',
                        actionLabel: _recent.isEmpty ? null : '查看全部',
                        onAction: _recent.isEmpty
                            ? null
                            : () => activeTabNotifier.value = 2,
                      ),
                      if (_recent.isEmpty)
                        const _EmptyRecent()
                      else
                        HealthCard(
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                          child: Column(
                            children: [
                              for (final r in _recent)
                                _RecentTile(
                                  report: r,
                                  onTap: () =>
                                      _push(ReportDetailPage(reportId: r.id)),
                                ),
                            ],
                          ),
                        ),
                      ]),
                    ),
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

/// 圆角方形图标块（primary 浅底 + primary 图标），Health / Fitness 卡片里的常见前缀。
class _IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconTile(this.icon, {this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: size * 0.5, color: AppColors.primary),
    );
  }
}

/// 首页第一优先级入口：拍报告。
class _PrimaryAddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PrimaryAddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: const Row(
        children: [
          _IconTile(CupertinoIcons.camera, size: 44),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('拍报告',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('对着纸质报告拍照',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
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
    return HealthCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          _IconTile(icon, size: 44),
          const SizedBox(width: 13),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

/// 换机不丢数据用的两张轻提醒卡片，共用同一套样式：左图标 + 标题/副标题 + 右上角关闭。
class _HintCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _HintCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('home-hint-$title'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      child: HealthCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            _IconTile(icon, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(CupertinoIcons.xmark,
                    size: 15, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestoreHintCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _RestoreHintCard({required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) => _HintCard(
        icon: CupertinoIcons.arrow_counterclockwise,
        title: '在旧手机备份过？',
        subtitle: '从备份文件恢复健康档案',
        onTap: onTap,
        onDismiss: onDismiss,
      );
}

class _BackupNudgeCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _BackupNudgeCard({required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) => _HintCard(
        icon: CupertinoIcons.archivebox,
        title: '建议备份健康档案',
        subtitle: '导出一份备份文件，换手机 / 重装不丢数据',
        onTap: onTap,
        onDismiss: onDismiss,
      );
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

    return HealthRow(
      leading: Dot(dotColor),
      title: area.name,
      subtitle: countText,
      onTap: onTap,
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
    // 系统按慢病模板自动排的复查（kind='followup'）是估算，给 21 天宽限期：
    // 过了到期日、但还在宽限期内，只灰字提示「复查时间已到」，不上橙色「已到期」。
    // 用户自己设的复查（kind='recheck'）没有宽限，到点即提示。
    final graceDays = reminder.kind == 'followup' ? 21 : 0;
    final overdue = dueDay.isBefore(today);
    final pastGrace =
        today.isAfter(dueDay.add(Duration(days: graceDays)));
    final days = dueDay.difference(today).inDays;
    // 只有「确定要现在处理」的才上橙色。
    final urgent = pastGrace || (graceDays == 0 && days == 0);
    final String sub;
    if (pastGrace) {
      sub = '复查已到期';
    } else if (overdue) {
      sub = '复查时间已到';
    } else if (days == 0) {
      sub = '复查就在今天';
    } else {
      sub = '距离复查还有 $days 天';
    }
    return HealthRow(
      leading: Dot(urgent ? AppColors.warning : AppColors.insufficient),
      title: reminder.title,
      subtitle: sub,
      trailing: urgent
          ? const Text('待处理',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning))
          : null,
      onTap: onTap,
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
    return HealthRow(
      leading: const Icon(CupertinoIcons.doc_text,
          size: 20, color: AppColors.textSecondary),
      title: label.isEmpty ? '报告' : label,
      subtitle: formatDate(r.reportDate),
      onTap: onTap,
    );
  }
}

/// 首页「最近」空状态：只说明，不放操作按钮（上传入口在页面顶部）。
class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return const HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('还没有健康记录',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          SizedBox(height: 6),
          Text('添加第一份资料后，这里会显示最近的检查和健康变化。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
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
    // 与记录页搜索/＋、身体页闹钟一致：32pt 按钮 + 22pt 图标。
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: onTap,
            child: const Icon(CupertinoIcons.bell, size: 22),
          ),
          if (unread > 0)
            Positioned(
              right: -3,
              top: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 15),
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
        ],
      ),
    );
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
    return IosLargeTitleScaffold(
      title: '待跟进',
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: rows.isEmpty
          ? const [
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text('当前没有需要关注的项目',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            ]
          : [
              HealthCard(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                child: Column(children: rows),
              ),
            ],
    );
  }
}
