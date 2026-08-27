import 'package:flutter/material.dart';

import '../main.dart';

/// 根据数值状态文字返回对应的状态颜色。
/// 支持的数值状态：正常 / 偏高 / 偏低 / 数据不足 / 需要关注 / 异常
/// 颜色永远不是唯一的信息表达方式 —— 卡片上始终同时显示状态文字。
Color valueStatusColor(String status) {
  if (status.contains('正常')) return AppColors.normal;
  if (status.contains('偏高') || status.contains('异常') || status.contains('偏低')) {
    return AppColors.abnormal;
  }
  if (status.contains('不足')) return AppColors.insufficient;
  if (status.contains('关注') ||
      status.contains('上升') ||
      status.contains('下降') ||
      status.contains('轻微')) {
    return AppColors.warning;
  }
  return AppColors.insufficient;
}

/// 根据趋势状态返回方向图标。
/// 支持的数值状态：稳定 / 上升 / 持续上升 / 下降 / 持续下降
IconData trendIcon(String trend) {
  if (trend.contains('上升')) return Icons.trending_up;
  if (trend.contains('下降')) return Icons.trending_down;
  return Icons.trending_flat; // 稳定
}

/// 一个小型状态标签（圆角胶囊，文字 + 颜色）
class StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const StatusChip({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// 通用状态卡片：
/// - title：卡片标题（如「肾脏」）
/// - status：状态文字（如「1 项需关注」）
/// - value：可选的醒目大数值（如「480 μmol/L」）
/// - subtitle：可选的小字说明（如「关键指标：尿酸 480 μmol/L」）
/// - compact：紧凑模式（两列网格里使用，标题在上、状态在下）
/// - onTap：可选的点击行为
class HealthStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final String? value;
  final String? subtitle;
  final bool compact;
  final VoidCallback? onTap;

  const HealthStatusCard({
    super.key,
    required this.title,
    required this.status,
    this.value,
    this.subtitle,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = valueStatusColor(status);

    final Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (value != null) ...[
              const SizedBox(height: 10),
              Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            StatusChip(text: status, color: valueStatusColor(status)),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusChip(text: status, color: statusColor),
              ],
            ),
          ],
          if (!compact && value != null) ...[
            const SizedBox(height: 12),
            Text(
              value!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Card(child: content);
    }
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
