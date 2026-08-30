// 调试用示例数据播种器的自检：确认灌进去的数据能被各聚合逻辑正常消费。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/dev/sample_data_seeder.dart';
import 'package:health_archive/models/body_area_health.dart';
import 'package:health_archive/models/chronic_condition_dictionary.dart';

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

  test('播种后：一个「糖尿病 + 高血压」的克制演示档案', () async {
    await SampleDataSeeder.run(repo);

    final profile = await repo.getProfile();
    expect(profile?.nickname, '徐先生');

    final reports = await repo.getAllReports();
    expect(reports.length, greaterThanOrEqualTo(3));

    final metrics = await repo.getAllMetrics();
    expect(metrics.length, greaterThanOrEqualTo(15));
    // 有异常指标，才有「需关注」内容
    expect(metrics.any((m) => m.status == '偏高' || m.status == '偏低'), isTrue);
    // 糖化血红蛋白多次记录 → 有趋势
    expect((await repo.getMetricHistory('HBA1C')).length,
        greaterThanOrEqualTo(3));

    final dailies = await repo.getAllDailyRecords();
    expect(dailies.map((d) => d.type).toSet(),
        containsAll(<String>['weight', 'blood_pressure', 'blood_glucose']));

    // 疾病史：正好两个慢病，都关联到字典
    final diseases = await repo.getAllDiseases();
    expect(diseases.length, 2);
    expect(
        diseases.every((d) => findChronicCondition(d.conditionCode) != null),
        isTrue);
    expect(diseases.map((d) => d.conditionCode),
        containsAll(<String>['type2_diabetes', 'hypertension']));

    // 用药两种，都关联到慢病
    final meds = await repo.getAllMedications();
    expect(meds.length, 2);
    expect(meds.every((m) => (m.conditionCode ?? '').isNotEmpty), isTrue);

    // 过敏史一条
    expect((await repo.getAllAllergies()).length, 1);

    // 聚合逻辑不报错
    final areas = buildBodyAreaHealthFromMetrics(metrics);
    expect(areas, isNotEmpty);
  });

  test('重复播种：先清空再写入，不累积', () async {
    await SampleDataSeeder.run(repo);
    final firstCount = (await repo.getAllReports()).length;
    await SampleDataSeeder.run(repo);
    expect((await repo.getAllReports()).length, firstCount);
    expect((await repo.getAllDiseases()).length, 2);
  });
}
