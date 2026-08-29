import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/profile_switcher.dart';
import 'body_page.dart';
import 'records_page.dart';
import 'reminders_page.dart';

/// 内容区域的最大宽度：宽屏下避免卡片无限拉宽。
const double _kContentMaxWidth = 720;
const int _kHomeAttentionPreview = 3;

/// 首页：精简的健康关注概览 + 待办提醒 + 健康冷知识。
/// 不展示姓名 / 年龄 / 身高等个人信息（身份由 AppBar 的档案切换器体现）。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HealthMetric> _metrics = [];
  List<Reminder> _reminders = [];
  int _unread = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = appRepository;
      if (repo == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      await repo.syncNotificationsFromReminders();
      final metrics = await repo.getAllMetrics();
      final reminders = await repo.getActiveReminders();
      final unread = await repo.unreadNotificationCount();
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _reminders = reminders;
          _unread = unread;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<BodyAreaHealthSummary> get _bodyAreas =>
      buildBodyAreaHealthFromMetrics(_metrics);

  int get _medReminderCount =>
      _reminders.where((r) => r.kind == 'medication' && r.enabled).length;

  int get _recheckDueCount {
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    return _reminders
        .where((r) =>
            r.kind == 'recheck' &&
            r.enabled &&
            r.completedAt == null &&
            r.dueDate != null &&
            !r.dueDate!.isAfter(d0.add(const Duration(days: 1))))
        .length;
  }

  Future<void> _openBody() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const BodyPage()))
      .then((_) => _load());

  Future<void> _openReminders() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const RemindersPage()))
      .then((_) => _load());

  @override
  Widget build(BuildContext context) {
    final bodyAreas = _bodyAreas;
    final attentionAreas = bodyAreas
        .where((o) => o.status == '异常' || o.status == '需关注')
        .toList();
    final attentionCount = attentionAreas.length;
    final latest = _latestMeasuredAt(bodyAreas);
    final medCount = _medReminderCount;
    final recheckDue = _recheckDueCount;
    final hasTodo = medCount > 0 || recheckDue > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            tooltip: '搜索记录',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const RecordsPage()))
                .then((_) => _load()),
          ),
          _BellAction(unread: _unread, onTap: _openReminders),
          const ProfileSwitcher(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                // 状态条：只说「几项需关注 + 更新日期」，不带姓名
                _StatusBar(
                  loading: _loading,
                  attentionCount: attentionCount,
                  latestText: latest == null ? '暂无检查数据' : formatDate(latest),
                  onTap: _openBody,
                ),
                if (hasTodo) ...[
                  const SizedBox(height: 10),
                  _TodoLine(
                    text: _todoText(medCount, recheckDue),
                    onTap: _openReminders,
                  ),
                ],
                const SizedBox(height: 12),
                const HealthTipCard(),
                const SizedBox(height: 20),
                const Text(
                  '需关注',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (attentionAreas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('目前没有需要关注的指标',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  )
                else
                  for (final area
                      in attentionAreas.take(_kHomeAttentionPreview)) ...[
                    _HomeBodyAreaCard(
                      area: area,
                      onTap: () => _openBodyArea(context, area),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _openBody,
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('查看全部身体部位'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _todoText(int med, int recheck) {
    final parts = <String>[
      if (med > 0) '$med 项服药',
      if (recheck > 0) '$recheck 项复查到期',
    ];
    return '今天：${parts.join(' · ')}';
  }

  void _openBodyArea(BuildContext context, BodyAreaHealthSummary area) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BodySystemDetailPage(
            area: area,
            allMetrics: _metrics,
            isExample: false,
          ),
        ))
        .then((_) => _load());
  }
}

class _BellAction extends StatelessWidget {
  final int unread;
  final VoidCallback onTap;
  const _BellAction({required this.unread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: '提醒',
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
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  final bool loading;
  final int attentionCount;
  final String latestText;
  final VoidCallback onTap;

  const _StatusBar({
    required this.loading,
    required this.attentionCount,
    required this.latestText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = attentionCount > 0 ? AppColors.warning : AppColors.normal;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loading
                    ? '正在整理数据'
                    : '$attentionCount 项需关注 · 上次更新 $latestText',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TodoLine extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _TodoLine({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _HomeBodyAreaCard extends StatelessWidget {
  final BodyAreaHealthSummary area;
  final VoidCallback onTap;

  const _HomeBodyAreaCard({required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final key = area.keyMetric;
    final latest = area.latestMeasuredAt == null
        ? '暂无来源'
        : formatDate(area.latestMeasuredAt!);
    final subtitle = key == null
        ? '暂无可用于判断的检查指标'
        : area.abnormalCount > 1
            ? '${area.abnormalCount} 项异常 · 关键：${key.name} ${key.valueText} · $latest'
            : '${key.name} ${key.valueText} · $latest';

    return HealthStatusCard(
      title: area.name,
      status: area.status,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

DateTime? _latestMeasuredAt(List<BodyAreaHealthSummary> areas) {
  DateTime? latest;
  for (final area in areas) {
    final d = area.latestMeasuredAt;
    if (d != null && (latest == null || d.isAfter(latest))) latest = d;
  }
  return latest;
}
