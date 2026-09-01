import 'package:flutter/cupertino.dart';

import '../main.dart';

enum _Kind { filled, tinted, plain }

/// iOS 风格按钮的三种常见形态，统一替换 Material 的
/// `FilledButton` / `FilledButton.tonal` / `OutlinedButton` / `TextButton`（含 `.icon` 版）。
///
/// - [IosButton.filled]：实心主色（对应 `FilledButton`）
/// - [IosButton.tinted]：浅色填充（对应 `FilledButton.tonal` / `OutlinedButton`）
/// - [IosButton.plain]：纯文字（对应 `TextButton`）
class IosButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool destructive;

  /// 撑满一行宽（表单主按钮常用）。
  final bool expand;
  final _Kind _kind;

  const IosButton.filled(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.expand = false,
  })  : destructive = false,
        _kind = _Kind.filled;

  const IosButton.tinted(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.expand = false,
    this.destructive = false,
  }) : _kind = _Kind.tinted;

  const IosButton.plain(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.expand = false,
    this.destructive = false,
  }) : _kind = _Kind.plain;

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? AppColors.abnormal : AppColors.primary;
    final fg = _kind == _Kind.filled ? CupertinoColors.white : tint;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: fg, fontSize: 15)),
        ),
      ],
    );
    final Widget btn = switch (_kind) {
      _Kind.filled =>
        CupertinoButton.filled(onPressed: onPressed, child: content),
      _Kind.tinted => CupertinoButton(
          color: tint.withValues(alpha: 0.12),
          onPressed: onPressed,
          child: content,
        ),
      _Kind.plain => CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onPressed: onPressed,
          child: content,
        ),
    };
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
