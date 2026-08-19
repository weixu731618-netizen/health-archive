import 'package:flutter/material.dart';

import '../main.dart';
import '../models/metric_dictionary.dart';

/// 弹出「选择指标」的底部面板（BottomSheet），按身体系统分组展示指标字典。
/// 返回用户选择的 MetricDefinition；取消返回 null。
Future<MetricDefinition?> showMetricSelector(BuildContext context) async {
  final result = await showModalBottomSheet<MetricDefinition>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const MetricSelectorSheet(),
  );
  return result;
}

class MetricSelectorSheet extends StatefulWidget {
  const MetricSelectorSheet({super.key});

  @override
  State<MetricSelectorSheet> createState() => _MetricSelectorSheetState();
}

class _MetricSelectorSheetState extends State<MetricSelectorSheet> {
  String _keyword = '';

  // 按身体系统分组，保持顺序
  List<MapEntry<String, List<MetricDefinition>>> get _groups {
    final Map<String, List<MetricDefinition>> map = {};
    for (final m in METRIC_DICTIONARY) {
      if (_keyword.isNotEmpty && !m.metricName.contains(_keyword)) continue;
      map.putIfAbsent(m.bodySystem, () => []).add(m);
    }
    // 有序输出（按字典首次出现顺序）
    final seen = <String>[];
    final entries = <MapEntry<String, List<MetricDefinition>>>[];
    for (final m in METRIC_DICTIONARY) {
      final list = map[m.bodySystem];
      if (list == null || seen.contains(m.bodySystem)) continue;
      seen.add(m.bodySystem);
      entries.add(MapEntry(m.bodySystem, list));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.72;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '选择指标',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _keyword = v.trim()),
              decoration: InputDecoration(
                hintText: '搜索指标名称',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6EAED)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                for (final group in _groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      group.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  for (final def in group.value)
                    ListTile(
                      title: Text(
                        def.metricName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        def.unit,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, def),
                    ),
                ],
                if (groupsAreEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        '没有匹配的指标',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get groupsAreEmpty {
    for (final g in _groups) {
      if (g.value.isNotEmpty) return false;
    }
    return true;
  }
}
