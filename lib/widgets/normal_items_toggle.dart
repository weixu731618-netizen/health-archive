import 'package:flutter/cupertino.dart';

/// 展开/收起“正常记录”的按钮：异常和需关注的项始终展示在前，
/// 正常（含数据不足）的项默认折叠，点击后再展开。
class NormalItemsToggle extends StatelessWidget {
  final bool expanded;
  final int hiddenCount;
  final VoidCallback onTap;

  const NormalItemsToggle({
    super.key,
    required this.expanded,
    required this.hiddenCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hiddenCount == 0) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 4),
        minimumSize: const Size(0, 36),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                expanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 15),
            const SizedBox(width: 6),
            Text(expanded ? '收起' : '展开其余 $hiddenCount 项正常记录'),
          ],
        ),
      ),
    );
  }
}
