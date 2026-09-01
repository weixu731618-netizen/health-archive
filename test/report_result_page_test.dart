// §11–§12：报告整理结果页 —— 指标数量 / 异常数量 / 涉及身体系统 的汇总展示。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/main.dart';
import 'package:health_archive/pages/report_result_page.dart';

void main() {
  setUp(() {
    appRepository = null; // 无库环境：历史对比跳过，静态汇总仍应渲染
    appDatabase = null;
  });

  ReportResultPage build(List<SavedMetricLine> metrics, Set<String> areas) =>
      ReportResultPage(
        reportId: 1,
        reportType: '生化检查',
        reportDate: DateTime(2026, 8, 20),
        hospitalName: '市第一医院',
        metrics: metrics,
        areas: areas,
        rawText: '',
        dateFromOcr: true,
      );

  testWidgets('汇总：识别 3 项 / 正常 1 / 需要关注 2 / 两个身体系统', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final metrics = [
      const SavedMetricLine(
          metricId: 'ALT',
          name: '丙氨酸氨基转移酶',
          status: '偏高',
          value: 62,
          unit: 'U/L',
          bodySystem: '肝脏'),
      const SavedMetricLine(
          metricId: 'CREA',
          name: '肌酐',
          status: '偏高',
          value: 105,
          unit: 'μmol/L',
          bodySystem: '肾脏'),
      const SavedMetricLine(
          metricId: 'K',
          name: '钾',
          status: '正常',
          value: 4.2,
          unit: 'mmol/L',
          bodySystem: '电解质'),
    ];

    await tester.pumpWidget(MaterialApp(
      home: build(metrics, {'肝胆', '肾脏/泌尿'}),
    ));
    await tester.pumpAndSettle();

    expect(find.text('已整理完成'), findsOneWidget);
    expect(find.text('3 项'), findsOneWidget); // 识别指标
    expect(find.text('1 项'), findsOneWidget); // 正常
    expect(find.text('2 项'), findsOneWidget); // 需要关注
    // 涉及身体：电解质(钾,正常)已归并到肾脏/泌尿；肝胆 1 项异常(ALT)、肾脏/泌尿 1 项异常(肌酐)
    expect(find.text('肝胆'), findsOneWidget);
    expect(find.text('肾脏/泌尿'), findsOneWidget);
    expect(find.text('1 项需要关注'), findsNWidgets(2));
    // 原件入口 + 长期价值提示
    expect(find.textContaining('比较变化'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
    expect(find.text('查看原始报告'), findsOneWidget);
  });

  testWidgets('报告含「复查」字样 → 结果页出现设置复查提醒入口', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: ReportResultPage(
        reportId: 2,
        reportType: '甲状腺功能',
        reportDate: DateTime(2026, 8, 20),
        hospitalName: '',
        metrics: const [
          SavedMetricLine(
              metricId: 'TSH',
              name: '促甲状腺激素',
              status: '偏高',
              value: 6.1,
              unit: 'mIU/L',
              bodySystem: '甲状腺'),
        ],
        areas: const {'内分泌/代谢'},
        rawText: '建议 3 个月后复查甲功',
        dateFromOcr: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('设置提醒'), findsOneWidget);
  });

  testWidgets('E5：报告写「无需复查」→ 不出现设置复查提醒入口', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: ReportResultPage(
        reportId: 4,
        reportType: '甲状腺功能',
        reportDate: DateTime(2026, 8, 20),
        hospitalName: '',
        metrics: const [],
        areas: const {},
        rawText: '结论：甲功正常，无需复查。',
        dateFromOcr: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('设置提醒'), findsNothing);
  });

  testWidgets('E4：核对页已关联复查 → 结果页不再提示设置提醒', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: ReportResultPage(
        reportId: 5,
        reportType: '甲状腺功能',
        reportDate: DateTime(2026, 8, 20),
        hospitalName: '',
        metrics: const [],
        areas: const {},
        rawText: '建议 3 个月后复查甲功',
        dateFromOcr: true,
        alreadyLinkedFollowup: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('设置提醒'), findsNothing);
  });

  testWidgets('后端没给检查日期 → 提示确认日期', (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: ReportResultPage(
        reportId: 3,
        reportType: '报告',
        reportDate: DateTime(2026, 8, 20),
        hospitalName: '',
        metrics: const [],
        areas: const {},
        rawText: '',
        dateFromOcr: false,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('没能识别出检查日期'), findsOneWidget);
    expect(find.text('确认检查日期'), findsOneWidget);
  });
}
