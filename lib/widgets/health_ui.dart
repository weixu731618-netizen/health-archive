import 'package:flutter/cupertino.dart';

import '../main.dart';
import 'ios_tap.dart';

/// 现代 iOS（Health / Fitness / 天气 风）的视觉语言：
/// 白色圆角卡片、足量留白、极轻阴影、无发丝分隔线，整卡可点。
/// 用来取代旧式「inset 列表 + 每行 chevron + 发丝线」的设置页风格。

/// 卡片：白底、大圆角、内边距足、极轻阴影，无描边。
class HealthCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const HealthCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return IosTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

/// 大号 section 标题；可选右侧「查看全部」——整屏基本唯一的 chevron。
class HealthSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const HealthSectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(4, 28, 4, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            IosTap(
              onTap: onAction,
              child: Row(
                children: [
                  Text(actionLabel!,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.primary)),
                  const Icon(CupertinoIcons.chevron_forward,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 大数字摘要：大 value + 小 label。
class StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final CrossAxisAlignment align;

  const StatBlock({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

/// 卡片内的一行内容（无发丝线、无 chevron），行与行之间用留白区隔。
/// [leading] 常放色点 / 图标，[trailing] 常放状态胶囊或小字。
class HealthRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const HealthRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return IosTap(onTap: onTap, child: row);
  }
}

/// 表单里带标签的一行：label 在左（定宽），输入 / 值 在右。放在 [HealthCard] 里。
class HealthFieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  const HealthFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textSecondary)),
          ),
          Expanded(child: child),
        ],
      ),
    );
    if (onTap == null) return row;
    return IosTap(onTap: onTap, child: row);
  }
}

/// 单选胶囊组（替代 Material 的 ChoiceChip / Wrap）。无水波纹。
class ChoicePills extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  /// 允许再点一次已选项取消（回到 null）。
  final bool toggle;

  const ChoicePills({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.toggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          ChoicePill(
            label: o,
            selected: value == o,
            onTap: () => onChanged(toggle && value == o ? null : o),
          ),
      ],
    );
  }
}

/// 单个选项胶囊。
class ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IosTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFD9DEE3),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            )),
      ),
    );
  }
}

/// iOS 滚轮日期选择器（底部弹层），取代 Material 的 `showDatePicker` 整屏日历。
/// 返回选中的日期（只保留年月日），取消返回 null。
Future<DateTime?> pickCupertinoDate(
  BuildContext context, {
  DateTime? initial,
  DateTime? minimumDate,
  DateTime? maximumDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
}) {
  FocusScope.of(context).unfocus();
  final now = DateTime.now();
  DateTime temp = initial ?? DateTime(now.year, now.month, now.day);
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (ctx) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(ctx),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    mode == CupertinoDatePickerMode.date
                        ? DateTime(temp.year, temp.month, temp.day)
                        : temp,
                  ),
                  child: const Text('完成',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: temp,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                onDateTimeChanged: (d) => temp = d,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 一个小圆点（状态信号），Health 风里用来代替一列 chevron / 一堆文字色。
class Dot extends StatelessWidget {
  final Color color;
  final double size;
  const Dot(this.color, {super.key, this.size = 8});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
