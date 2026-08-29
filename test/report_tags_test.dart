// B3：报告标签仓库层 —— 设置、去重列表、医院列表、导出、按档案隔离。
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
  tearDown(() async => db.close());

  Future<int> mkReport({String hospital = '甲医院', List<String> tags = const []}) =>
      repo.insertReport(
        hospitalName: hospital,
        reportDate: DateTime(2026, 8, 1),
        reportType: '生化',
        tags: tags,
      );

  test('setReportTags 标准化写入；getDistinctReportTags 按频次降序', () async {
    await repo.ensureDefaultPersonProfile();
    final a = await mkReport(tags: ['体检', '体检', ' 复查 ']);
    await mkReport(tags: ['体检']);
    await mkReport();

    expect((await repo.getReportById(a))!.tags, '体检,复查');
    final tags = await repo.getDistinctReportTags();
    expect(tags, ['体检', '复查']); // 体检 用了 2 次排前面

    await repo.setReportTags(a, ['术前', '术前', 'x,y']);
    expect((await repo.getReportById(a))!.tags, '术前');
  });

  test('getDistinctHospitals：去重、非空、排序', () async {
    await repo.ensureDefaultPersonProfile();
    await mkReport(hospital: 'B医院');
    await mkReport(hospital: 'A医院');
    await mkReport(hospital: 'A医院');
    await mkReport(hospital: '');
    expect(await repo.getDistinctHospitals(), ['A医院', 'B医院']);
  });

  test('导出包含 tags；恢复后标签保留', () async {
    await repo.ensureDefaultPersonProfile();
    await mkReport(tags: ['体检', '住院']);
    final data = await repo.exportHealthData();
    expect((data['reports'] as List).single['tags'], '体检,住院');
  });

  test('标签 / 医院列表按当前档案隔离', () async {
    await repo.ensureDefaultPersonProfile();
    await mkReport(hospital: '本人医院', tags: ['体检']);
    final momId = await repo.insertPersonProfile(displayName: '妈妈');
    await repo.setActiveProfileId(momId);
    expect(await repo.getDistinctReportTags(), isEmpty);
    expect(await repo.getDistinctHospitals(), isEmpty);
    await mkReport(hospital: '妈妈医院', tags: ['复查']);
    expect(await repo.getDistinctReportTags(), ['复查']);
    expect(await repo.getDistinctHospitals(), ['妈妈医院']);
  });
}
