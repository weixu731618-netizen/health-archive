import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/health_repository.dart';
import '../main.dart';
import '../utils/format.dart';
import 'manual_metric_entry_page.dart';

/// 某个指标的历史记录页：显示当前值 + 按日期排序的历史列表。
class MetricHistoryPage extends StatefulWidget {
  final String metricId;
  final String metricName;
  final String unit;

  const MetricHistoryPage({
    super.key,
    required this.metricId,
    required this.metricName,
    required this.unit,
  });

  @override
  State<MetricHistoryPage> createState() => _MetricHistoryPageState();
}

class _MetricHistoryPageState extends State<MetricHistoryPage> {
  List<HealthMetric> _records = [];
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
        // 无数据库（如测试/预览环境）：不报错，展示空历史
        if (mounted) {
          setState(() {
            _records = const [];
            _loading = false;
            _error = null;
          });
        }
        return;
      }
      final list = await repo.getMetricHistory(widget.metricId);
      if (mounted) {
        setState(() {
          _records = list;
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

  HealthMetric? get _latest => _records.isEmpty ? null : _records.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _load();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // 顶部：指标名 + 当前值
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.metricName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _latest == null
                          ? '暂无记录'
                          : '${_latest!.value} ${_latest!.unit}',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    if (_latest != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '最新：${formatDateCn(_latest!.measuredAt)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(_error!,
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else if (_records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('暂无历史记录',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ),
              )
            else
              for (final r in _records) ...[
                Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text(
                      '${fmtLocal(r.value)} ${r.unit}',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${formatDate(r.measuredAt)} · ${r.status}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    onTap: () => _editRecord(r),
                  ),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _editRecord(HealthMetric m) async {
    final repo = appRepository;
    if (repo == null) return;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('操作'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('编辑'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('删除'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (result == null) return;

    if (result) {
      // 编辑
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ManualMetricEntryPage(metric: m)),
      );
    } else {
      // 删除（二次确认）
      final confirm = await showDialog<bool>(
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
      if (confirm == true) {
        await repo.deleteMetric(m.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('已删除')));
      }
    }
    if (mounted) _load();
  }
}

String fmtLocal(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
