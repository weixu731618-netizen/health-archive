import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/health_tips.dart';
import '../main.dart';

/// 首页「今日一则」卡片：每天一条（按日期取），可「换一则」。
/// 「换一则」的偏移量存在 SharedPreferences 里，跨启动保留。
/// 只显示一条，不做 Feed / 文章列表 / 无限下滑。
class HealthTipCard extends StatefulWidget {
  const HealthTipCard({super.key});

  @override
  State<HealthTipCard> createState() => _HealthTipCardState();
}

class _HealthTipCardState extends State<HealthTipCard> {
  static const String _prefKey = 'health_tip_offset';
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _restoreOffset();
  }

  Future<void> _restoreOffset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_prefKey);
      if (v != null && mounted) setState(() => _offset = v);
    } catch (_) {}
  }

  Future<void> _nextTip() async {
    setState(() => _offset += 1);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, _offset);
    } catch (_) {}
  }

  HealthTip get _tip {
    if (kHealthTips.isEmpty) {
      return const HealthTip('今日一则', '内容整理中。');
    }
    final daysSinceEpoch =
        DateTime.now().difference(DateTime(2020)).inDays;
    final idx = (daysSinceEpoch + _offset) % kHealthTips.length;
    return kHealthTips[idx];
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tip;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text('今日一则',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tip.title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4),
            ),
            const SizedBox(height: 6),
            Text(
              tip.body,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            if (kHealthTips.length > 1) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _nextTip,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('换一则'),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
