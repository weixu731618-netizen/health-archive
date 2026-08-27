import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import '../widgets/section_title.dart';
import 'body_page.dart';

/// 内容区域的最大宽度：Chrome / 平板等宽屏下避免卡片无限拉宽。
const double _kContentMaxWidth = 720;
const int _kHomeBodyAreaPreviewCount = 6;
const String _kPriorityAreaPrefKey = 'home_priority_body_areas';

/// 首页：以单个个体为中心的身体关注概览。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserProfileData? _profile;
  List<HealthMetric> _metrics = [];
  Set<String> _selectedPriorityAreaNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selected =
          prefs.getStringList(_kPriorityAreaPrefKey)?.toSet() ?? {};
      final repo = appRepository;
      if (repo == null) {
        if (mounted) {
          setState(() {
            _selectedPriorityAreaNames = selected;
            _loading = false;
          });
        }
        return;
      }
      final profile = await repo.getProfile();
      final metrics = await repo.getAllMetrics();
      if (mounted) {
        setState(() {
          _profile = profile;
          _metrics = metrics;
          _selectedPriorityAreaNames = selected;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<BodyAreaHealthSummary> get _bodyAreas => _metrics.isEmpty
      ? buildFallbackBodyAreaHealth()
      : buildBodyAreaHealthFromMetrics(_metrics);

  List<HealthTopicSummary> get _healthTopics =>
      buildHealthTopicSummaries(_metrics);

  @override
  Widget build(BuildContext context) {
    final bodyAreas = _bodyAreas;
    final selectedNames = _selectedPriorityAreaNames
        .where((name) => bodyAreas.any((area) => area.name == name))
        .toSet();
    final selectedAreas =
        bodyAreas.where((area) => selectedNames.contains(area.name)).toList();
    final attentionAreas =
        bodyAreas.where((o) => o.status == '异常' || o.status == '需关注').toList();
    final prioritySource = selectedAreas.isNotEmpty
        ? selectedAreas
        : attentionAreas.isEmpty
            ? bodyAreas
            : attentionAreas;
    final primaryAreas =
        prioritySource.take(_kHomeBodyAreaPreviewCount).toList();
    final previewAreas = bodyAreas.take(_kHomeBodyAreaPreviewCount).toList();
    final topicPreview = _healthTopics.take(_kHomeBodyAreaPreviewCount).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('身体关注概览')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _OverviewCard(
                  profile: _profile,
                  bodyAreas: bodyAreas,
                  isLoading: _loading,
                  isExample: _metrics.isEmpty,
                ),
                const SectionTitle(title: '健康资料主题'),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  for (final topic in topicPreview) ...[
                    _HealthTopicCard(topic: topic),
                    const SizedBox(height: 12),
                  ],
                _SectionHeader(
                  title: '优先关注部位',
                  actionLabel: '选择',
                  icon: Icons.tune,
                  onPressed: _loading
                      ? null
                      : () => _openPriorityPicker(bodyAreas, selectedNames),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  for (final area in primaryAreas) ...[
                    _HomeBodyAreaCard(
                      area: area,
                      isExample: _metrics.isEmpty,
                      onTap: () => _openBodyArea(context, area),
                    ),
                    const SizedBox(height: 12),
                  ],
                const SectionTitle(title: '全部身体部位'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardW = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final area in previewAreas)
                          SizedBox(
                            width: cardW,
                            child: HealthStatusCard(
                              title: area.name,
                              value: _metricSummary(area.keyMetric),
                              status: area.status,
                              compact: true,
                              onTap: () => _openBodyArea(context, area),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (bodyAreas.length > _kHomeBodyAreaPreviewCount) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BodyPage()),
                      ),
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('查看全部身体部位'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBodyArea(BuildContext context, BodyAreaHealthSummary area) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BodySystemDetailPage(
          area: area,
          allMetrics: _metrics,
          isExample: _metrics.isEmpty,
        ),
      ),
    );
  }

  Future<void> _openPriorityPicker(
    List<BodyAreaHealthSummary> areas,
    Set<String> selectedNames,
  ) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final draft = selectedNames.toSet();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '选择优先关注部位',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setSheetState(draft.clear),
                        child: const Text('重置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (final area in areas)
                    CheckboxListTile(
                      value: draft.contains(area.name),
                      title: Text(area.name),
                      subtitle: Text(_metricSummary(area.keyMetric)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked == true) {
                            draft.add(area.name);
                          } else {
                            draft.remove(area.name);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(draft),
                    child: const Text('完成'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result == null) return;
    setState(() => _selectedPriorityAreaNames = result);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPriorityAreaPrefKey, result.toList());
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final UserProfileData? profile;
  final List<BodyAreaHealthSummary> bodyAreas;
  final bool isLoading;
  final bool isExample;

  const _OverviewCard({
    required this.profile,
    required this.bodyAreas,
    required this.isLoading,
    required this.isExample,
  });

  @override
  Widget build(BuildContext context) {
    final name = (profile?.nickname ?? '').trim().isEmpty
        ? '当前个体'
        : profile!.nickname.trim();
    final attentionCount =
        bodyAreas.where((o) => o.status == '异常' || o.status == '需关注').length;
    final latest = _latestMeasuredAt(bodyAreas);
    final latestText =
        latest == null ? (isExample ? '示例数据' : '暂无检查数据') : formatDate(latest);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.health_and_safety,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isLoading
                        ? '正在整理身体关注数据'
                        : '$attentionCount 个身体部位需关注 · 最近更新 $latestText',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBodyAreaCard extends StatelessWidget {
  final BodyAreaHealthSummary area;
  final bool isExample;
  final VoidCallback onTap;

  const _HomeBodyAreaCard({
    required this.area,
    required this.isExample,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final key = area.keyMetric;
    final latest = area.latestMeasuredAt == null
        ? (isExample ? '示例数据' : '暂无来源')
        : formatDate(area.latestMeasuredAt!);
    final subtitle = key == null
        ? '暂无可用于判断的检查指标'
        : area.abnormalCount > 1
            ? '${area.abnormalCount} 项异常指标 · 关键异常：${key.name} ${key.valueText} · $latest'
            : '${key.name} ${key.valueText} · $latest';

    return HealthStatusCard(
      title: area.name,
      status: area.status,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _HealthTopicCard extends StatelessWidget {
  final HealthTopicSummary topic;

  const _HealthTopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final latest = topic.latestMeasuredAt == null
        ? '暂无记录日期'
        : '最近记录 ${formatDate(topic.latestMeasuredAt!)}';
    final subtitle = topic.recordCount == 0
        ? '暂无相关检查资料'
        : '${topic.summaryText} · $latest';

    return HealthStatusCard(
      title: topic.name,
      status: topic.statusLabel,
      subtitle: subtitle,
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

String _metricSummary(BodyAreaMetricEvidence? metric) {
  if (metric == null) return '暂无指标';
  return '${metric.name} ${metric.valueText}';
}
