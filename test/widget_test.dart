import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/main.dart';

void main() {
  testWidgets('首页显示健康摘要、近期关注卡片与身体系统关键指标', (tester) async {
    // 用较高的视口，让首页所有内容一次性构建出来，避免滚动分片
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 顶部问候卡 + 健康摘要（仅首页独有的文案）
    expect(find.text('下午好，徐先生'), findsOneWidget);
    expect(find.text('3 项需要关注 · 最近更新 1 天前'), findsOneWidget);

    // 近期关注卡片：数值状态 + 趋势（仅首页独有的文案）
    expect(find.text('持续上升'), findsOneWidget);
    expect(find.text('6.8%'), findsOneWidget);
    expect(find.text('最近三次结果呈上升趋势'), findsOneWidget);

    // 身体系统卡片：名称 + 关键指标 + 状态
    // （「身体」Tab 里也含同名系统与指标，故用 findsWidgets 断言首页网格中存在即可）
    expect(find.text('心血管'), findsWidgets);
    expect(find.text('LDL-C 3.6 mmol/L'), findsWidgets);
    expect(find.text('HbA1c 6.8%'), findsWidgets);
    expect(find.text('ALT 32 U/L'), findsWidgets);
    expect(find.text('尿酸 480 μmol/L'), findsWidgets);
  });

  testWidgets('App 启动后显示底部 5 个 Tab', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('健康档案'), findsOneWidget);

    final Finder navBar = find.byType(NavigationBar);
    for (final label in ['首页', '身体', '记录', '添加', '我的']) {
      expect(
        find.descendant(of: navBar, matching: find.text(label)),
        findsOneWidget,
        reason: '底部导航应包含「$label」',
      );
    }
  });

  testWidgets('身体页可以进入肾脏详情页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('身体'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('肾脏'));
    await tester.pumpAndSettle();

    expect(find.text('肌酐'), findsOneWidget);
    expect(find.text('历史趋势'), findsOneWidget);
  });

  testWidgets('记录页可以进入检查详情页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('记录'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('生化检查'));
    await tester.pumpAndSettle();

    expect(find.text('检查详情'), findsOneWidget);
    expect(find.text('ALT'), findsOneWidget);
  });

  testWidgets('点击拍摄检查报告进入拍摄页面', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('添加'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('拍摄检查报告'));
    // 不等待 settle（拍摄页可能因相机不可用一直加载）；推进几次路由过渡帧
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 进入拍摄页（该页独有文案）
    expect(find.text('对准化验单拍照，确保文字清晰'), findsOneWidget);
  });
}
