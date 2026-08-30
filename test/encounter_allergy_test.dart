// 慢病升级 步骤5：就诊记录 + 过敏史 + 报告归属就诊。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/services/snapshot_importer.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
  });
  tearDown(() => db.close());

  group('就诊记录', () {
    test('新增 / 查询 / 关联报告 / 删除时报告保留但解除关联', () async {
      await repo.ensureDefaultPersonProfile();
      final encId = await repo.insertEncounter(
        visitDate: DateTime(2026, 6, 1),
        hospitalName: '协和',
        department: '内分泌',
        diagnosis: '2型糖尿病随访',
        advice: '继续二甲双胍，3 个月后复查糖化',
        conditionCode: 'type2_diabetes',
      );
      final rId = await repo.insertReport(
        hospitalName: '协和',
        reportDate: DateTime(2026, 6, 1),
        reportType: '生化',
      );
      await repo.setReportEncounter(rId, encId);

      expect((await repo.getAllEncounters()).single.department, '内分泌');
      expect((await repo.getReportsForEncounter(encId)).single.id, rId);
      expect((await repo.getReportById(rId))!.encounterId, encId);

      await repo.deleteEncounter(encId);
      expect(await repo.getAllEncounters(), isEmpty);
      // 报告还在，只是 encounterId 清空
      expect((await repo.getReportById(rId))!.encounterId, isNull);
    });

    test('按当前档案隔离', () async {
      await repo.ensureDefaultPersonProfile();
      await repo.insertEncounter(
          visitDate: DateTime(2026, 6, 1), hospitalName: '本人医院');
      final momId = await repo.insertPersonProfile(displayName: '妈妈');
      await repo.setActiveProfileId(momId);
      expect(await repo.getAllEncounters(), isEmpty);
    });
  });

  group('过敏史', () {
    test('CRUD', () async {
      await repo.ensureDefaultPersonProfile();
      final id = await repo.insertAllergy(
        substance: '青霉素',
        category: '药物',
        reaction: '皮疹',
        severity: '重',
      );
      var all = await repo.getAllAllergies();
      expect(all.single.substance, '青霉素');
      expect(all.single.severity, '重');

      await repo.updateAllergy(all.single.copyWith(severity: '中'));
      all = await repo.getAllAllergies();
      expect(all.single.severity, '中');

      await repo.deleteAllergy(id);
      expect(await repo.getAllAllergies(), isEmpty);
    });
  });

  group('备份往返', () {
    test('encounters / allergies / report.encounterId 完整往返（含 id 重映射）',
        () async {
      await repo.ensureDefaultPersonProfile();
      final encId = await repo.insertEncounter(
        visitDate: DateTime(2026, 6, 1),
        hospitalName: '协和',
        department: '内分泌',
        conditionCode: 'type2_diabetes',
      );
      final rId = await repo.insertReport(
        hospitalName: '协和',
        reportDate: DateTime(2026, 6, 1),
        reportType: '生化',
      );
      await repo.setReportEncounter(rId, encId);
      await repo.insertAllergy(substance: '海鲜', category: '食物');

      final snapshot = await repo.exportHealthData();
      // 导出不含自动随访提醒但要含 encounters / allergies
      expect(snapshot['encounters'], isA<List>());
      expect((snapshot['encounters'] as List).single['department'], '内分泌');
      expect((snapshot['allergies'] as List).single['substance'], '海鲜');

      final msg = await SnapshotImporter.restore(repo, snapshot);
      expect(msg, contains('成功'));

      final encs = await repo.getAllEncounters();
      expect(encs.single.hospitalName, '协和');
      // 报告重新关联到新的 encounter id
      final reports = await repo.getAllReports();
      expect(reports.single.encounterId, encs.single.id);
      expect((await repo.getAllAllergies()).single.substance, '海鲜');
    });
  });
}
