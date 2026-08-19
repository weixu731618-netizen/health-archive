import 'package:flutter/material.dart';

import '../main.dart';
import '../models/fake_data.dart';
import '../widgets/health_status_card.dart';
import '../widgets/record_tile.dart';
import '../widgets/section_title.dart';

/// 内容区域的最大宽度：Chrome / 平板等宽屏下避免卡片无限拉宽，
/// 同时限制网格列宽，保持适合阅读的排版。
const double _kContentMaxWidth = 720;

/// 首页：问候卡片 / 近期关注 / 身体系统 / 最近记录
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健康档案')),
      body: Center(
        // 宽屏限制内容宽度；窄屏占满
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const _GreetingCard(),
              const SectionTitle(title: '近期关注'),
              for (final metric in FakeData.homeMetrics) ...[
                _MetricCard(metric: metric),
                const SizedBox(height: 12),
              ],
              const SectionTitle(title: '身体系统'),
              // 两列表格布局，用 Wrap 让每行卡片按内容自适应高度，
              // 避免在窄屏或大字体下溢出（比固定 mainAxisExtent 更稳）。
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final system in FakeData.homeBodySystems)
                        SizedBox(
                          width: cardW,
                          child: HealthStatusCard(
                            title: system.name,
                            value: system.keyMetric,
                            status: system.status,
                            compact: true,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SectionTitle(title: '最近记录'),
              RecordTile(item: FakeData.records[0]),
              const SizedBox(height: 12),
              RecordTile(item: FakeData.records[1]),
            ],
          ),
        ),
      ),
    );
  }
}

/// 顶部问候卡片：下午好 + 姓名 + 健康摘要（3 项需要关注 · 最近更新 1 天前）
class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '下午好，徐先生',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.health_and_safety,
                    size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '3 项需要关注 · 最近更新 1 天前',
                    style: TextStyle(
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

/// 「近期关注」指标卡片（紧凑）：
/// 指标名 / 当前值 / 数值状态 / 趋势 / 一句说明
class _MetricCard extends StatelessWidget {
  final Metric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = valueStatusColor(metric.valueStatus);
    final Color trendColor = AppColors.textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：指标名 + 数值状态
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusChip(text: metric.valueStatus, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            // 第二行：当前值 + 趋势
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  metric.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(trendIcon(metric.trend), size: 18, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  metric.trend,
                  style: TextStyle(fontSize: 14, color: trendColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第三行：一句说明
            Text(
              metric.hint,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
