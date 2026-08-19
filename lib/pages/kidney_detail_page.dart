import 'package:flutter/material.dart';

import '../main.dart';
import '../models/fake_data.dart';
import '../widgets/health_status_card.dart';
import '../widgets/record_tile.dart';
import '../widgets/section_title.dart';
import 'report_detail_page.dart';

/// 肾脏详情页：最近检查信息 / 关键指标 / 历史趋势 / 相关检查记录
class KidneyDetailPage extends StatelessWidget {
  const KidneyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('肾脏')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // 顶部信息：最近检查 / 已有历史数据
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(
                    child: _InfoColumn(label: '最近检查', value: '2026年8月18日'),
                  ),
                  SizedBox(
                    height: 32,
                    child: VerticalDivider(width: 1, color: Color(0xFFE6EAED)),
                  ),
                  Expanded(
                    child: _InfoColumn(label: '已有历史数据', value: '3年'),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: '关键指标'),
          for (final metric in FakeData.kidneyMetrics) ...[
            HealthStatusCard(
              title: metric.name,
              value: metric.value,
              status: metric.status,
            ),
            const SizedBox(height: 12),
          ],
          const SectionTitle(title: '历史趋势'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in FakeData.kidneyTrend)
                    _TrendRow(point: point),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.trending_up,
                          size: 18, color: AppColors.warning),
                      SizedBox(width: 6),
                      Text(
                        '最近三次结果呈上升趋势',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: '相关检查记录'),
          for (final record in FakeData.kidneyRecords) ...[
            RecordTile(
              item: record,
              showArrow: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportDetailPage()),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// 顶部信息的一列（标签在上，数值在下）
class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 历史趋势的一行：年份 + 横向条 + 数值
class _TrendRow extends StatelessWidget {
  final TrendPoint point;

  const _TrendRow({required this.point});

  @override
  Widget build(BuildContext context) {
    const int maxValue = 480; // 假数据里的最大值，用来计算条的长度

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              point.year,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 22,
                color: AppColors.primary.withValues(alpha: 0.15),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: point.value / maxValue,
                  child: Container(
                    color: AppColors.primary,
                    height: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            child: Text(
              '${point.value}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
