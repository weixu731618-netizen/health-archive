import 'package:flutter/cupertino.dart';
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

  testWidgets('首页：铃铛 + 添加报告，不再有「最近」', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
    // 两个导入入口：拍报告（第一优先级）+ 上传截图或 PDF（统一识别，自动分流）
    expect(find.text('拍报告'), findsOneWidget);
    expect(find.text('上传截图或 PDF'), findsOneWidget);
    // 「最近」整块已移除（那是「记录」Tab 的职责）
    expect(find.text('本人档案'), findsNothing);
    expect(find.text('最近'), findsNothing);
    // 「健康档案完成度」「该做的」已从首页移除
    expect(find.textContaining('健康档案完成度'), findsNothing);
    expect(find.textContaining('该做的'), findsNothing);
    // 血压 / 血糖 / 体重 不再常驻首页
    expect(find.textContaining('记一次血压'), findsNothing);
  });

  testWidgets('App 启动后底部只保留 3 个 Tab，没有悬浮 + 按钮', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);

    final Finder navBar = find.byType(CupertinoTabBar);
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
    // 底部大型悬浮 + 已删除，Tab Bar 只负责页面切换。
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('身体页无数据时只显示空状态，不铺一堆「未检查」部位', (tester) async {
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoTabBar),
        matching: find.text('身体'),
      ),
    );
    await tester.pumpAndSettle();

    // 空状态：一句话 + 单个「添加健康资料」按钮，不铺器官清单、不出现「风险 / 未检查」。
    expect(find.text('还没有身体健康记录'), findsOneWidget);
    expect(find.text('添加健康资料'), findsOneWidget);
    expect(find.text('身体图谱'), findsNothing);
    expect(find.textContaining('风险'), findsNothing);
    expect(find.textContaining('未检查'), findsNothing);
  });

  testWidgets('空记录页不展示历史假报告', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(CupertinoTabBar),
        matching: find.text('记录'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有健康记录'), findsOneWidget);
    expect(find.text('添加第一条记录'), findsOneWidget);
    expect(find.text('生化检查'), findsNothing);
    expect(find.text('深圳某医院'), findsNothing);
    expect(find.text('ALT'), findsNothing);
  });

  testWidgets('记录页右上角 + 弹出添加菜单，报告 → 拍照进入拍摄页', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 进「记录」页
    await tester.tap(find.descendant(
      of: find.byType(CupertinoTabBar),
      matching: find.text('记录'),
    ));
    await tester.pumpAndSettle();

    // 点右上角 + → 底部菜单浮出（复用首页那套添加菜单）
    await tester.tap(find.byIcon(CupertinoIcons.add));
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
    expect(find.text('把整份报告放进画面，横竖均可，确保文字清晰。'), findsOneWidget);
  });

  testWidgets('右上角头像菜单里直接有「关于健康档案」，一步打开', (tester) async {
    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 右上角头像 → 账户菜单（不再有「设置」这层套娃）
    await tester.tap(find.byType(ProfileSwitcher));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNothing);
    expect(find.text('数据与隐私'), findsOneWidget);

    await tester.tap(find.text('关于健康档案'));
    await tester.pumpAndSettle();

    expect(find.text('版本 1.9.15+44'), findsOneWidget);
    expect(find.textContaining('删掉首页「最近」'), findsOneWidget);
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
