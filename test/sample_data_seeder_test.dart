// 调试用示例数据播种器的自检：确认灌进去的数据能被各聚合逻辑正常消费。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/dev/sample_data_seeder.dart';
import 'package:health_archive/models/body_area_health.dart';

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

  test('播种后：各模块都有可展示的数据', () async {
    await SampleDataSeeder.run(repo);

    final profile = await repo.getProfile();
    expect(profile?.nickname, '徐先生');

    final reports = await repo.getAllReports();
    expect(reports.length, greaterThanOrEqualTo(6));
    // 至少一份影像报告（有结论文字、无关联指标）
    final imaging = <MedicalReport>[
      for (final r in reports)
        if ((await repo.getMetricsByReport(r.id)).isEmpty) r
    ];
    expect(imaging, isNotEmpty);
    expect(imaging.every((r) => (r.rawText ?? '').isNotEmpty), isTrue);

    final metrics = await repo.getAllMetrics();
    expect(metrics.length, greaterThanOrEqualTo(20));
    // 有异常指标，首页 / 身体页才有「需关注」内容
    expect(metrics.any((m) => m.status == '偏高' || m.status == '偏低'), isTrue);
    // 同一指标有多次记录，指标历史才有趋势
    final uaHistory = await repo.getMetricHistory('UA');
    expect(uaHistory.length, greaterThanOrEqualTo(2));

    final dailies = await repo.getAllDailyRecords();
    expect(dailies.map((d) => d.type).toSet(),
        containsAll(<String>['weight', 'blood_pressure', 'blood_glucose']));

    expect((await repo.getAllDiseases()).length, greaterThanOrEqualTo(4));
    expect((await repo.getAllMedications()).length, greaterThanOrEqualTo(4));

    // 身体部位 / 健康主题聚合不报错且有异常部位
    final areas = buildBodyAreaHealthFromMetrics(metrics);
    expect(areas.any((a) => a.status == '异常' || a.status == '需关注'), isTrue);
    expect(buildHealthTopicSummaries(metrics), isNotEmpty);
  });

  test('重复播种：先清空再写入，不累积', () async {
    await SampleDataSeeder.run(repo);
    final firstCount = (await repo.getAllReports()).length;
    await SampleDataSeeder.run(repo);
    expect((await repo.getAllReports()).length, firstCount);
  });
}
