import 'package:flutter/widgets.dart';

/// 无水波纹的点击反馈：按下时整体轻微变淡（iOS 风格），用来替代 Material 的
/// [InkWell] / [Material] 涟漪。签名保留 [borderRadius] 只为替换时少改代码，
/// 本身不绘制任何 splash。
///
/// 按压态用 [ValueNotifier] + [ValueListenableBuilder] 驱动，不走 setState，
/// 因此手势进行中 [GestureDetector] 不会被重建，tap 不会被误判为 cancel。
class IosTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;

  const IosTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  @override
  State<IosTap> createState() => _IosTapState();
}

class _IosTapState extends State<IosTap> {
  final ValueNotifier<bool> _down = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _down.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _down.value = true : null,
      onTapUp: enabled ? (_) => _down.value = false : null,
      onTapCancel: enabled ? () => _down.value = false : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ValueListenableBuilder<bool>(
        valueListenable: _down,
        builder: (_, down, child) => AnimatedOpacity(
          duration: const Duration(milliseconds: 90),
          opacity: down ? 0.55 : 1.0,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
