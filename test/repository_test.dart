// 数据层端到端测试：使用内存数据库验证 录入→查询→更新→删除 闭环。
// 若宿主机缺少 sqlite 原生库导致打开内存库失败，此测试会被跳过并说明原因。
// 隐藏 drift 导出的 isNotNull，避免与 flutter_test 的匹配器冲突
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('检查指标：录入→查询→更新→删除 闭环', () async {
    // 录入
    final inserted = await repo.insertMetric(
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

    expect(inserted.id, isNotNull);

    // 查询
    final all = await repo.getAllMetrics();
    expect(all, hasLength(1));
    expect(all.first.value, 6.8);
    expect(all.first.status, '偏高');

    final bySystem = await repo.getMetricsByBodySystem('血糖代谢');
    expect(bySystem, hasLength(1));

    final history = await repo.getMetricHistory('HBA1C');
    expect(history, hasLength(1));

    // 更新
    final updated = inserted.copyWith(value: 6.5, status: '正常');
    final ok = await repo.updateMetric(updated);
    expect(ok, isTrue);
    final after = await repo.getMetricHistory('HBA1C');
    expect(after.first.value, 6.5);
    expect(after.first.status, '正常');

    // 删除
    final del = await repo.deleteMetric(inserted.id);
    expect(del, greaterThan(0));
    expect(await repo.getAllMetrics(), isEmpty);
  });

  test('日常记录：录入→查询→更新→删除 闭环', () async {
    final inserted = await repo.insertDaily(
      type: 'blood_pressure',
      value1: 128,
      value2: 82,
      unit: 'mmHg',
      measuredAt: DateTime(2026, 8, 19),
    );
    expect(inserted.id, isNotNull);

    final all = await repo.getAllDailyRecords();
    expect(all, hasLength(1));
    expect(all.first.value2, 82);

    final updated = inserted.copyWith(value1: 120, value2: const Value(78));
    expect(await repo.updateDaily(updated), isTrue);
    final after = await repo.getAllDailyRecords();
    expect(after.first.value1, 120);

    expect(await repo.deleteDaily(inserted.id), greaterThan(0));
    expect(await repo.getAllDailyRecords(), isEmpty);
  });

  test('getDailyRecordsByType：按类型过滤，倒序', () async {
    await repo.insertDaily(
        type: 'blood_pressure',
        value1: 130,
        value2: 85,
        unit: 'mmHg',
        measuredAt: DateTime(2026, 8, 10));
    await repo.insertDaily(
        type: 'blood_pressure',
        value1: 122,
        value2: 78,
        unit: 'mmHg',
        measuredAt: DateTime(2026, 8, 20));
    await repo.insertDaily(
        type: 'blood_glucose',
        value1: 6.4,
        unit: 'mmol/L',
        measuredAt: DateTime(2026, 8, 15));

    final bp = await repo.getDailyRecordsByType('blood_pressure');
    expect(bp, hasLength(2));
    // 倒序：最新在前
    expect(bp.first.measuredAt, DateTime(2026, 8, 20));

    final glu = await repo.getDailyRecordsByType('blood_glucose');
    expect(glu, hasLength(1));
    expect(glu.first.value1, 6.4);

    expect(await repo.getDailyRecordsByType('heart_rate'), isEmpty);
  });
}
