// 慢病升级 步骤1：病种字典完整性 + 疾病史新字段落库。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/models/chronic_condition_dictionary.dart';
import 'package:health_archive/models/metric_dictionary.dart';

void main() {
  group('病种字典完整性', () {
    test('code 非空且全表唯一', () {
      final codes = <String>[];
      for (final c in CHRONIC_CONDITION_DICTIONARY) {
        expect(c.code.trim(), isNotEmpty, reason: '${c.name} 缺 code');
        expect(c.name.trim(), isNotEmpty);
        codes.add(c.code);
      }
      expect(codes.toSet().length, codes.length, reason: 'code 有重复');
    });

    test('有 stages 就必须有 stagingLabel，反之亦然', () {
      for (final c in CHRONIC_CONDITION_DICTIONARY) {
        expect(c.hasStaging, c.stagingLabel != null,
            reason: '${c.name} 的 stages 与 stagingLabel 不一致');
      }
    });

    test('relatedMetricIds 全部能在指标字典里找到', () {
      for (final c in CHRONIC_CONDITION_DICTIONARY) {
        for (final id in c.relatedMetricIds) {
          expect(findMetricDefinition(id), isNotNull,
              reason: '${c.name} 关联了不存在的指标 $id');
        }
      }
    });

    test('relatedDailyTypes 只用已支持的日常类型', () {
      for (final c in CHRONIC_CONDITION_DICTIONARY) {
        for (final t in c.relatedDailyTypes) {
          expect(kKnownDailyTypes.contains(t), isTrue,
              reason: '${c.name} 用了未知日常类型 $t');
        }
      }
    });

    test('三大类都非空，且划分不重不漏', () {
      var sum = 0;
      for (final cat in ChronicCategory.values) {
        final list = chronicConditionsByCategory(cat);
        expect(list, isNotEmpty, reason: '$cat 为空');
        sum += list.length;
      }
      expect(sum, CHRONIC_CONDITION_DICTIONARY.length);
    });
  });

  group('查找 / 匹配', () {
    test('findChronicCondition 按 code', () {
      expect(findChronicCondition('hypertension')?.name, '高血压');
      expect(findChronicCondition('ckd')?.stagingLabel, '分期');
      expect(findChronicCondition('不存在'), isNull);
      expect(findChronicCondition(null), isNull);
    });

    test('matchChronicCondition 按名 / 别名', () {
      expect(matchChronicCondition('高血压')?.code, 'hypertension');
      expect(matchChronicCondition('2型糖尿病')?.code, 'type2_diabetes');
      expect(matchChronicCondition('T2DM')?.code, 'type2_diabetes');
      expect(matchChronicCondition('糖尿病')?.code, 'type2_diabetes'); // 别名
      expect(matchChronicCondition('脂肪肝')?.code, 'nafld');
      expect(matchChronicCondition('从来没听过的病'), isNull);
    });

    test('metricsForCondition 返回真实指标定义', () {
      final ms = metricsForCondition('type2_diabetes');
      expect(ms.map((m) => m.metricId), contains('HBA1C'));
      expect(metricsForCondition('overweight'), isEmpty);
      expect(metricsForCondition('不存在'), isEmpty);
    });
  });

  group('疾病史新字段落库', () {
    late AppDatabase db;
    late HealthRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = HealthRepository(db);
    });
    tearDown(() => db.close());

    test('insertDisease 带 conditionCode / stage / diagnosisBasis 可读回', () async {
      await repo.ensureDefaultPersonProfile();
      await repo.insertDisease(
        name: '2型糖尿病',
        conditionCode: 'type2_diabetes',
        stage: '合并微血管并发症',
        diagnosisBasis: '2022-03 协和内分泌 OGTT + 糖化 7.8%',
        status: '当前存在',
      );
      // 自由文本病：conditionCode 留空
      await repo.insertDisease(name: '偏头痛', status: '不确定');

      final all = await repo.getAllDiseases();
      expect(all, hasLength(2));

      final chronic = await repo.getChronicDiseases();
      expect(chronic, hasLength(1));
      expect(chronic.single.name, '2型糖尿病');
      expect(chronic.single.conditionCode, 'type2_diabetes');
      expect(chronic.single.stage, '合并微血管并发症');
      expect(chronic.single.diagnosisBasis, contains('OGTT'));
    });

    test('导出包含新字段', () async {
      await repo.ensureDefaultPersonProfile();
      await repo.insertDisease(
        name: '高血压',
        conditionCode: 'hypertension',
        stage: '1 级',
      );
      final data = await repo.exportHealthData();
      final d = (data['diseases'] as List).single as Map;
      expect(d['conditionCode'], 'hypertension');
      expect(d['stage'], '1 级');
      expect(d.containsKey('diagnosisBasis'), isTrue);
    });
  });

  group('步骤2：疾病 ↔ 用药 / 报告 关联', () {
    late AppDatabase db;
    late HealthRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = HealthRepository(db);
    });
    tearDown(() => db.close());

    test('getMedicationsForCondition 只返回显式关联的药', () async {
      await repo.ensureDefaultPersonProfile();
      await repo.insertMedication(
          name: '二甲双胍', conditionCode: 'type2_diabetes');
      await repo.insertMedication(
          name: '氨氯地平', conditionCode: 'hypertension');
      await repo.insertMedication(name: '维生素C'); // 未关联

      final dm = await repo.getMedicationsForCondition('type2_diabetes');
      expect(dm.map((m) => m.name), ['二甲双胍']);
    });

    test('getReportsForCondition：显式关联 + 含相关指标自动匹配', () async {
      await repo.ensureDefaultPersonProfile();
      final def = findChronicCondition('type2_diabetes')!;

      // 报告 A：手动关联到糖尿病
      final rA = await repo.insertReport(
        hospitalName: '协和',
        reportDate: DateTime(2026, 6, 1),
        reportType: '内分泌随访',
        conditionCode: 'type2_diabetes',
      );
      // 报告 B：没手动关联，但含糖化血红蛋白（糖尿病相关指标）
      final rB = await repo.insertReport(
        hospitalName: '社区中心',
        reportDate: DateTime(2026, 7, 1),
        reportType: '生化',
      );
      await repo.insertMetric(
        metricId: 'HBA1C',
        metricName: '糖化血红蛋白',
        value: 7.2,
        unit: '%',
        referenceMin: 4,
        referenceMax: 6,
        status: '偏高',
        bodySystem: '血糖代谢',
        measuredAt: DateTime(2026, 7, 1),
        reportId: rB,
      );
      // 报告 C：无关（只有血常规指标）
      final rC = await repo.insertReport(
        hospitalName: '体检中心',
        reportDate: DateTime(2026, 5, 1),
        reportType: '血常规',
      );
      await repo.insertMetric(
        metricId: 'HGB',
        metricName: '血红蛋白',
        value: 150,
        unit: 'g/L',
        referenceMin: 130,
        referenceMax: 175,
        status: '正常',
        bodySystem: '血液',
        measuredAt: DateTime(2026, 5, 1),
        reportId: rC,
      );

      final got = await repo.getReportsForCondition(
          'type2_diabetes', def.relatedMetricIds);
      final ids = got.map((r) => r.id).toSet();
      expect(ids, containsAll(<int>[rA, rB]));
      expect(ids, isNot(contains(rC)));
    });

    test('setReportCondition 可设置与清除', () async {
      await repo.ensureDefaultPersonProfile();
      final rid = await repo.insertReport(
        hospitalName: '协和',
        reportDate: DateTime(2026, 6, 1),
        reportType: '生化',
      );
      await repo.setReportCondition(rid, 'ckd');
      expect((await repo.getReportById(rid))!.conditionCode, 'ckd');
      await repo.setReportCondition(rid, null);
      expect((await repo.getReportById(rid))!.conditionCode, isNull);
    });

    test('导出：medications / reports 带 conditionCode', () async {
      await repo.ensureDefaultPersonProfile();
      await repo.insertMedication(name: '氨氯地平', conditionCode: 'hypertension');
      await repo.insertReport(
        hospitalName: '协和',
        reportDate: DateTime(2026, 6, 1),
        reportType: '生化',
        conditionCode: 'hypertension',
      );
      final data = await repo.exportHealthData();
      expect((data['medications'] as List).single['conditionCode'],
          'hypertension');
      expect(
          (data['reports'] as List).single['conditionCode'], 'hypertension');
    });
  });
}
