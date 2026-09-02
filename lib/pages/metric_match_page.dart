import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;

import '../data/app_database.dart';
import '../main.dart';
import '../models/metric_dictionary.dart';
import '../utils/format.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../widgets/ios_nav.dart';
import '../widgets/toast.dart';

/// 「匹配记录」：App 把没认出的项目名交给智能识别归一化后，会记下
/// `原始名 → 标准指标` 的映射，同名下次直接用。这一页让你看、删、以及在删掉
/// 错误映射后按名字重新匹配历史记录。
class MetricMatchPage extends StatefulWidget {
  const MetricMatchPage({super.key});

  @override
  State<MetricMatchPage> createState() => _MetricMatchPageState();
}

class _MetricMatchPageState extends State<MetricMatchPage> {
  List<MetricMatchCacheData> _rows = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) {
      setState(() => _loading = false);
      return;
    }
    final rows = await repo.getAllMetricMatches();
    rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  String _sourceLabel(String s) {
    switch (s) {
      case 'learned':
        return '你的更正';
      case 'manual':
        return '手动添加';
      default:
        return '智能识别';
    }
  }

  Future<void> _delete(MetricMatchCacheData row) async {
    final repo = appRepository;
    if (repo == null) return;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('删除这条匹配？'),
        content: Text(
          '「${row.rawDisplay}」以后不再自动识别为该指标。'
          '已入库的历史记录不受影响，除非你接着用下面的「重新匹配历史记录」。',
        ),
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
    if (ok != true) return;
    await repo.deleteMetricMatch(row.id);
    if (mounted) showToast(context, '已删除');
    await _load();
  }

  Future<void> _rematch() async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    try {
      final n = await repo.rematchAllMetrics();
      if (mounted) {
        showToast(context, n == 0 ? '没有需要更新的记录' : '已更新 $n 条记录');
      }
    } catch (_) {
      if (mounted) showToast(context, '操作失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IosLargeTitleScaffold(
      title: '匹配记录',
      onRefresh: _load,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Text(
            '这里是 App 学到的「报告上的项目名 → 标准指标」对应关系。'
            '发现认错了，删掉对应的一条即可；需要连历史记录一起改，用下方按钮。',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        IosButton.tinted(
          _busy ? '正在重新匹配…' : '按名字重新匹配历史记录',
          expand: true,
          onPressed: _busy ? null : _rematch,
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CupertinoActivityIndicator()),
          )
        else if (_rows.isEmpty)
          const _EmptyCard()
        else
          for (final row in _rows) ...[
            _MatchRow(
              row: row,
              sourceLabel: _sourceLabel(row.source),
              onDelete: () => _delete(row),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _MatchRow extends StatelessWidget {
  final MetricMatchCacheData row;
  final String sourceLabel;
  final VoidCallback onDelete;

  const _MatchRow({
    required this.row,
    required this.sourceLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final target = row.canonicalId == null
        ? (row.customName ?? '—')
        : (findMetricDefinition(row.canonicalId!)?.metricName ?? row.canonicalId!);
    return HealthCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row.rawDisplay}  →  $target',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '$sourceLabel · ${formatDate(row.createdAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: CupertinoButton(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
              onPressed: onDelete,
              child: const Icon(CupertinoIcons.delete,
                  size: 20, color: AppColors.abnormal),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const HealthCard(
      padding: EdgeInsets.all(20),
      child: Text(
        '还没有学到任何匹配。上传的报告里出现新的项目名、且被智能识别归到某个标准'
        '指标时，才会在这里记一条。',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
