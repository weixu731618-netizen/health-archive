import 'dart:async';

import 'package:flutter/cupertino.dart';

/// iOS 风轻提示：顶部滑入的深色胶囊条，约 2 秒后自动淡出。
/// 取代 Material 底部 `SnackBar`（安卓味太重）。
void showToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _active?.remove();
  _active = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      onGone: () {
        if (_active == entry) _active = null;
        entry.remove();
      },
    ),
  );
  _active = entry;
  overlay.insert(entry);
}

OverlayEntry? _active;

class _Toast extends StatefulWidget {
  final String message;
  final VoidCallback onGone;

  const _Toast({required this.message, required this.onGone});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _hold = Timer(const Duration(milliseconds: 2000), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _c.reverse();
    widget.onGone();
  }

  @override
  void dispose() {
    _hold?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _t,
          builder: (_, child) => Opacity(
            opacity: _t.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - _t.value) * -16),
              child: child,
            ),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xF01C1C1E),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
