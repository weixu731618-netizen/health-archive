import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_archive/main.dart';
import 'package:health_archive/pages/about_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRepository = null;
    appDatabase = null;
  });

  testWidgets('首页显示身体关注概览与优先关注部位', (tester) async {
    // 用较高的视口，让首页所有内容一次性构建出来，避免滚动分片
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 顶部身体关注概览
    expect(find.text('身体关注概览'), findsOneWidget);
    expect(find.text('当前个体'), findsOneWidget);
    expect(find.textContaining('个身体部位需关注'), findsOneWidget);

    // 首页首屏优先展示身体部位，而不是报告列表或单纯指标列表
    expect(find.text('健康资料主题'), findsOneWidget);
    expect(find.text('暂无相关检查资料'), findsWidgets);
    expect(find.text('优先关注部位'), findsOneWidget);
    expect(find.text('选择'), findsOneWidget);
    expect(find.text('全部身体部位'), findsOneWidget);
    expect(find.text('查看全部身体部位'), findsOneWidget);

    // 身体部位卡片：名称 + 关键指标 + 状态
    expect(find.text('心血管'), findsWidgets);
    expect(find.text('LDL-C 3.6 mmol/L'), findsWidgets);
    expect(find.text('HbA1c 6.8%'), findsWidgets);
    expect(find.text('ALT 32 U/L'), findsWidgets);
  });

  testWidgets('App 启动后显示底部 5 个 Tab', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('身体关注概览'), findsOneWidget);

    final Finder navBar = find.byType(NavigationBar);
    for (final label in ['首页', '身体', '记录', '添加', '我的']) {
      expect(
        find.descendant(of: navBar, matching: find.text(label)),
        findsOneWidget,
        reason: '底部导航应包含「$label」',
      );
    }
  });

  testWidgets('身体页可以进入肾脏泌尿详情页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('身体'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('肾脏/泌尿'));
    await tester.pumpAndSettle();

    expect(find.text('肌酐'), findsOneWidget);
    expect(find.text('需关注问题'), findsOneWidget);
    expect(find.text('历史趋势'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('不等同于医学诊断'),
      400,
    );
    expect(find.textContaining('不等同于医学诊断'), findsOneWidget);
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

    expect(find.text('报告详情'), findsOneWidget);
    expect(find.text('影响部位'), findsOneWidget);
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

  testWidgets('我的页隐藏云端备份入口并可进入关于页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('我的'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('账号与云端备份'), findsNothing);
    await tester.tap(find.text('关于健康档案'));
    await tester.pumpAndSettle();

    expect(find.text('版本 1.0.2+3'), findsOneWidget);
    expect(find.text('T5-T9 local test'), findsOneWidget);
  });

  testWidgets('关于页展示本地备份和识别后端状态', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    await tester.pumpAndSettle();

    expect(find.text('本地备份恢复'), findsOneWidget);
    expect(find.text('未配置真实识别后端'), findsOneWidget);
    expect(find.text('云端备份'), findsOneWidget);
    expect(find.text('本轮暂不启用，避免影响本机测试'), findsOneWidget);
  });
}
