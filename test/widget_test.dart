import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_archive/main.dart';
import 'package:health_archive/pages/about_page.dart';
import 'package:health_archive/widgets/profile_switcher.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRepository = null;
    appDatabase = null;
  });

  testWidgets('极简首页：铃铛 + 今日一则', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    // AppBar 提醒铃铛
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    // 正文只有「今日一则」卡片
    expect(find.text('今日一则'), findsOneWidget);
    // 待办卡 / 姓名 / 需关注列表都不在
    expect(find.text('今天没有待办提醒'), findsNothing);
    expect(find.text('当前个体'), findsNothing);
    expect(find.text('需关注'), findsNothing);
    expect(find.text('查看全部身体部位'), findsNothing);
  });

  testWidgets('App 启动后显示底部 3 个 Tab 与悬浮添加按钮', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);

    final Finder navBar = find.byType(NavigationBar);
    for (final label in ['首页', '身体', '记录']) {
      expect(
        find.descendant(of: navBar, matching: find.text(label)),
        findsOneWidget,
        reason: '底部导航应包含「$label」',
      );
    }
    // 「我的」不再占底部 Tab，收进右上角头像。
    expect(find.descendant(of: navBar, matching: find.text('我的')), findsNothing);
    expect(find.descendant(of: navBar, matching: find.text('添加')), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
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

    expect(find.text('肌酐'), findsNothing);
    expect(find.text('暂无可用于判断的检查指标'), findsOneWidget);
    expect(find.text('需关注问题'), findsOneWidget);
    expect(find.text('历史趋势'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('不等同于医学诊断'),
      400,
    );
    expect(find.textContaining('不等同于医学诊断'), findsOneWidget);
  });

  testWidgets('空记录页不展示历史假报告', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('记录'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('还没有录入数据'), findsOneWidget);
    expect(find.text('生化检查'), findsNothing);
    expect(find.text('深圳某医院'), findsNothing);
    expect(find.text('ALT'), findsNothing);
  });

  testWidgets('+ 弹出添加菜单，化验单 → 拍照进入拍摄页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 点 + → 底部菜单浮出（不再是整屏页面）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('添加健康数据'), findsOneWidget);

    // 化验单 → 顺序弹「拍照 / 上传」
    await tester.tap(find.text('拍化验单 / 上传'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('拍照'));
    // 不等待 settle（拍摄页可能因相机不可用一直加载）；推进几次路由过渡帧
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 进入拍摄页（该页独有文案）
    expect(find.text('对准化验单拍照，确保文字清晰'), findsOneWidget);
  });

  testWidgets('从右上角头像进入设置，可打开关于页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 右上角头像入口（首页 AppBar）→ 弹出菜单 → 设置
    await tester.tap(find.byType(ProfileSwitcher));
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('账号与云端备份'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('关于健康档案'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('关于健康档案'));
    await tester.pumpAndSettle();

    expect(find.text('版本 1.6.3+13'), findsOneWidget);
    expect(find.text('「+」改成底部轻量菜单：拍摄/上传化验单合并为一项'), findsOneWidget);
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
