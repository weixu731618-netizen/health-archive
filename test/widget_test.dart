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

  testWidgets('首页：铃铛 + 添加报告 + 最近', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    // 拍报告为第一优先级 + 两个次级入口
    // （空数据时「最近」空状态里也有一个「拍报告」按钮，故 findsWidgets）
    expect(find.text('拍报告'), findsWidgets);
    expect(find.text('相册 / 文件'), findsOneWidget);
    expect(find.text('添加影像'), findsOneWidget);
    // 首页顶部不再有「徐先生 档案」头 / 「添加健康资料」分区标题
    expect(find.text('添加健康资料'), findsNothing);
    expect(find.text('本人档案'), findsNothing);
    expect(find.text('最近'), findsOneWidget);
    // 「健康档案完成度」「该做的」已从首页移除
    expect(find.textContaining('健康档案完成度'), findsNothing);
    expect(find.textContaining('该做的'), findsNothing);
    // 血压 / 血糖 / 体重 不再常驻首页
    expect(find.textContaining('记一次血压'), findsNothing);
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

  testWidgets('身体页无数据时只显示空状态，不铺一堆「未检查」部位', (tester) async {
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('身体'),
      ),
    );
    await tester.pumpAndSettle();

    // 空状态：一句话 + 拍报告，不出现器官清单、不出现「风险 / 未检查」字样。
    expect(find.text('还没有身体健康记录'), findsOneWidget);
    expect(find.text('拍报告'), findsOneWidget);
    expect(find.text('身体记录'), findsNothing);
    expect(find.textContaining('风险'), findsNothing);
    expect(find.textContaining('未检查'), findsNothing);
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

    expect(find.textContaining('还没有健康资料'), findsOneWidget);
    expect(find.text('生化检查'), findsNothing);
    expect(find.text('深圳某医院'), findsNothing);
    expect(find.text('ALT'), findsNothing);
  });

  testWidgets('+ 弹出添加菜单，报告 → 拍照进入拍摄页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 点 + → 底部菜单浮出（不再是整屏页面）
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('添加健康数据'), findsOneWidget);

    // 报告 → 顺序弹「拍照 / 上传」
    await tester.tap(find.text('拍报告 / 上传'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('拍照'));
    // 不等待 settle（拍摄页可能因相机不可用一直加载）；推进几次路由过渡帧
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 进入拍摄页（该页独有文案）
    expect(find.text('对准报告拍照，确保文字清晰'), findsOneWidget);
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

    expect(find.text('版本 1.8.0+18'), findsOneWidget);
    expect(find.textContaining('器官导航'), findsOneWidget);
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
