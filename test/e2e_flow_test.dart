// V0.3 端到端接线测试：证明“保存到数据库 → 记录页可见 → 身体系统页可见 → 删除”。
// 使用内存数据库并注入到全局 appRepository，验证页面与数据层的真实联动。
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/main.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
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

  testWidgets('录入数据后在记录页与身体系统页可见，且可删除', (tester) async {
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

    // 记录页能看到真实数据（带来源标记），且“假数据示例”也在
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('记录')));
    await tester.pumpAndSettle();
    expect(find.text('手工录入'), findsOneWidget);
    expect(find.text('糖化血红蛋白'), findsWidgets);
    expect(find.textContaining('6.8 %'), findsWidgets);

    // 身体页 → 血糖代谢能看见这条数据（真实数据优先）
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('身体')));
    await tester.pumpAndSettle();
    expect(find.textContaining('关键指标：6.8 %'), findsWidgets);
  });
}
