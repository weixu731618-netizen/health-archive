import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold;

import '../main.dart';

/// iOS 大标题页脚手架：顶部 [CupertinoSliverNavigationBar]（下滑时收缩成居中小标题，
/// 带发丝线 + 毛玻璃），正文以 slivers 传入。取代 Material 的 `Scaffold` + `AppBar`。
///
/// - [trailing]：导航栏右侧（一个 widget；多个自己用 Row 包）。
/// - [onRefresh]：非空则加 [CupertinoSliverRefreshControl]（下拉刷新）。
/// - [bottomBar]：固定在底部的条（原 `Scaffold.bottomNavigationBar`）。
/// - [padding]：包在 slivers 外层的 [SliverPadding]，默认左右 16、底部 24。
class IosLargeTitleScaffold extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Future<void> Function()? onRefresh;
  final List<Widget> children;
  final Widget? bottomBar;
  final EdgeInsets padding;

  const IosLargeTitleScaffold({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.onRefresh,
    this.bottomBar,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24),
  });

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(title),
          trailing: trailing,
          backgroundColor: AppColors.background.withValues(alpha: 0.85),
        ),
        if (onRefresh != null)
          CupertinoSliverRefreshControl(onRefresh: onRefresh),
        SliverPadding(
          padding: padding,
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
      ],
    );
    // 用 Material 的 Scaffold 承载（提供 DefaultTextStyle / IconTheme /
    // ScaffoldMessenger），导航栏本身是 Cupertino 的大标题 sliver。
    return Scaffold(
      backgroundColor: AppColors.background,
      body: scroll,
      bottomNavigationBar: bottomBar,
    );
  }
}
