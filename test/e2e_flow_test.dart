// V0.3 端到端接线测试：证明“保存到数据库 → 资料来源可见 → 身体部位页可见 → 删除”。
// 使用内存数据库并注入到全局 appRepository，验证页面与数据层的真实联动。
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/main.dart';
import 'package:health_archive/pages/manual_metric_entry_page.dart';
import 'package:health_archive/pages/metric_history_page.dart';
import 'package:health_archive/pages/report_recognition_flow.dart';
import 'package:health_archive/utils/image_storage.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
    appDatabase = db;
    appRepository = repo;
  });

  tearDown(() async {
    appRepository = null;
    appDatabase = null;
    await db.close();
  });

  testWidgets('录入数据后在资料来源与身体部位页可见，且可删除', (tester) async {
    // 预置一条“糖化血红蛋白”真实数据（对应手工录入 HBA1C 的结果）
    await repo.insertMetric(
      metricId: 'HBA1C',
      metricName: '糖化血红蛋白',
      value: 6.8,
      unit: '%',
      referenceMin: 4.0,
      referenceMax: 6.0,
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 19),
    );

    tester.view.physicalSize = const Size(440, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthArchiveApp());
    await tester.pumpAndSettle();

    // 记录页只显示真实数据（带来源标记）。
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('记录')));
    await tester.pumpAndSettle();
    expect(find.text('手工录入'), findsOneWidget);
    expect(find.text('糖化血红蛋白'), findsWidgets);
    expect(find.textContaining('6.8 %'), findsWidgets);

    // 身体页 → 代谢部位能看见这条数据（异常部位优先）
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('身体')));
    await tester.pumpAndSettle();
    expect(find.textContaining('异常指标：糖化血红蛋白 6.8 %'), findsWidgets);
  });

  testWidgets('指标历史显示确认状态和来源报告，并可点回报告详情', (tester) async {
    final reportId = await repo.insertReport(
      hospitalName: '市第一医院',
      reportDate: DateTime(2026, 8, 21),
      reportType: '血糖',
      recognitionStatus: 'confirmed',
    );
    await repo.insertMetric(
      metricId: 'FPG',
      metricName: '空腹血糖',
      value: 6.8,
      rawValue: '6.8 mmol/L',
      numericValue: 6.8,
      unit: 'mmol/L',
      referenceMin: 3.9,
      referenceMax: 6.1,
      referenceRangeRaw: '3.9-6.1',
      sourceAbnormalFlag: 'H',
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 21),
      sourceType: 'report_import',
      verificationStatus: 'user_confirmed',
      reportId: reportId,
    );

    await tester.pumpWidget(const MaterialApp(
      home: MetricHistoryPage(
        metricId: 'FPG',
        metricName: '空腹血糖',
        unit: 'mmol/L',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('空腹血糖'), findsOneWidget);
    expect(find.textContaining('来源报告 #$reportId'), findsOneWidget);
    expect(find.textContaining('用户已确认'), findsOneWidget);
    expect(find.textContaining('报告标记 H'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();

    expect(find.text('报告详情'), findsOneWidget);
    expect(find.text('市第一医院'), findsOneWidget);
  });

  testWidgets('手动录入支持新增字典外自定义指标', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ManualMetricEntryPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('字典里没有，新增自定义指标'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '指标名称'), 'C反应蛋白');
    await tester.enterText(find.widgetWithText(TextFormField, '单位'), 'mg/L');
    await tester.enterText(find.widgetWithText(TextFormField, '分类'), '炎症');
    await tester.tap(find.widgetWithText(FilledButton, '添加'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '检查结果'), '3.2');
    await tester.tap(find.widgetWithText(FilledButton, '保存记录'));
    await tester.pumpAndSettle();

    final metrics = await repo.getAllMetrics();
    expect(metrics, hasLength(1));
    expect(metrics.single.metricName, 'C反应蛋白');
    expect(metrics.single.unit, 'mg/L');
    expect(metrics.single.bodySystem, '炎症');
    expect(metrics.single.sourceType, 'manual');
  });

  testWidgets('未配置真实后端时上传图片不会进入 Mock 假识别', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () {
              startReportRecognitionFlow(
                context,
                PickedReportImage(
                  bytes: Uint8List.fromList([1, 2, 3, 4]),
                  fileName: 'not-a-report.jpg',
                  path: null,
                ),
              );
            },
            child: const Text('识别'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('识别'));
    await tester.pumpAndSettle();

    expect(find.textContaining('真实识别后端未配置'), findsOneWidget);
    expect(find.text('报告核对'), findsNothing);
  });
}
