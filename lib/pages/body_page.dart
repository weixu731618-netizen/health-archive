import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../models/fake_data.dart';
import '../utils/format.dart';
import '../widgets/health_status_card.dart';
import 'kidney_detail_page.dart';
import 'metric_history_page.dart';

/// 身体页面：按身体系统查看健康数据。
/// 真实数据优先：某系统有真实指标则显示最新真实值；否则回退到 V0.2 假数据。
class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  List<HealthMetric> _real = [];
  bool _loading = true;
  String? _error;

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
        // 无数据库（如测试/预览环境）：不报错，展示 V0.2 假数据
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
      if (mounted) {
        setState(() {
          _real = list;
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

  // 某系统的真实最新一条
  List<HealthMetric> _realOf(String bodySystem) =>
      _real.where((m) => m.bodySystem == bodySystem).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('身体')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                '按照身体系统查看长期健康数据',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
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
            else
              for (final system in FakeData.bodySystems) ...[
                _buildSystemCard(context, system),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, BodySystem system) {
    final real = _realOf(system.name);

    // 真实数据优先：有真实值用真实值；否则用假数据的关键指标
    String? keyIndicator;
    String? statusText;
    if (real.isNotEmpty) {
      final latest = real.first;
      keyIndicator = '${_fmt(latest.value)} ${latest.unit}';
      statusText = latest.status;
    } else if (system.keyIndicator != null) {
      keyIndicator = system.keyIndicator;
      statusText = system.status;
    }

    return HealthStatusCard(
      title: system.name,
      status: statusText ?? system.status,
      subtitle: keyIndicator == null ? null : '关键指标：$keyIndicator',
      onTap: system.name == '肾脏' && real.isEmpty
          ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KidneyDetailPage()),
              )
          : () => _openSystemDetail(context, system.name, real),
    );
  }

  void _openSystemDetail(
      BuildContext context, String systemName, List<HealthMetric> real) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BodySystemDetailPage(
          systemName: systemName,
          metrics: real,
          fallback: FakeData.bodySystems
              .firstWhere((s) => s.name == systemName),
        ),
      ),
    );
  }
}

/// 某身体系统下所有指标（真实优先，最新在上）
class BodySystemDetailPage extends StatefulWidget {
  final String systemName;
  final List<HealthMetric> metrics;
  final BodySystem fallback;

  const BodySystemDetailPage({
    super.key,
    required this.systemName,
    required this.metrics,
    required this.fallback,
  });

  @override
  State<BodySystemDetailPage> createState() => _BodySystemDetailPageState();
}

class _BodySystemDetailPageState extends State<BodySystemDetailPage> {
  late List<HealthMetric> _metrics = widget.metrics;

  Future<void> _reload() async {
    final repo = appRepository;
    if (repo == null) return;
    final list = await repo.getMetricsByBodySystem(widget.systemName);
    if (mounted) setState(() => _metrics = list);
  }

  @override
  Widget build(BuildContext context) {
    // 按指标 id 分组，某一指标的最新值 + 其历史都在里面
    final groups = <String, List<HealthMetric>>{};
    for (final m in _metrics) {
      groups.putIfAbsent(m.metricId, () => []).add(m);
    }
    // 排序组内按日期最新在上（repo 已按日期倒序返回，直接使用）

    return Scaffold(
      appBar: AppBar(title: Text(widget.systemName)),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                '点击某个指标可查看历史记录，历史记录页可再次点击编辑或删除',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            if (_metrics.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fallback.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      if (widget.fallback.keyIndicator != null)
                        Text(
                          '关键指标：${widget.fallback.keyIndicator}',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        '暂无真实录入数据，以上为 V0.2 示例数据',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final group in groups.entries)
                for (final m in group.value) ...[
                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        m.metricName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        '${_fmt(m.value)} ${m.unit} · ${formatDate(m.measuredAt)} · ${m.status}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textSecondary),
                      onTap: () => _openHistory(m),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
          ],
        ),
      ),
    );
  }

  Future<void> _openHistory(HealthMetric m) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MetricHistoryPage(
          metricId: m.metricId,
          metricName: m.metricName,
          unit: m.unit,
        ),
      ),
    );
    if (mounted) _reload();
  }
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
