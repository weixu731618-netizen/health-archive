// B4：「给医生看的一页纸」汇总逻辑。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/utils/medical_summary.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
  });
  tearDown(() async => db.close());

  Future<MedicalSummary> build({DateTime? now}) async {
    final profile = await repo.getProfile();
    final diseases = await repo.getAllDiseases();
    final meds = await repo.getAllMedications();
    final metrics = await repo.getAllMetrics();
    final reports = await repo.getAllReports();
    final counts = <int, int>{};
    for (final r in reports) {
      counts[r.id] = (await repo.getMetricsByReport(r.id)).length;
    }
    return buildMedicalSummary(
      profile: profile,
      diseases: diseases,
      medications: meds,
      metrics: metrics,
      reports: reports,
      reportMetricCounts: counts,
      now: now,
    );
  }

  test('空档案 → isEmpty', () async {
    await repo.ensureDefaultPersonProfile();
    final s = await build();
    expect(s.isEmpty, isTrue);
  });

  test('汇总疾病 / 用药 / 异常指标趋势 / 近期报告', () async {
    await repo.ensureDefaultPersonProfile();
    await repo.upsertProfile(
        nickname: '徐先生',
        gender: '男',
        birthDate: DateTime(1986, 5, 12),
        heightCm: 172);

    await repo.insertDisease(name: '2型糖尿病', status: '确诊');
    await repo.insertDisease(name: '旧病', status: '已恢复'); // 应被排除

    await repo.insertMedication(
        name: '二甲双胍', dosage: '0.5', dosageUnit: 'g', timesPerDay: '2');
    await repo.insertMedication(name: '停用药', status: '已停用'); // 应被排除

    // 尿酸：两次，最新偏高且比上次低 → ↓
    await repo.insertMetric(
      metricId: 'UA',
      metricName: '尿酸',
      value: 508,
      unit: 'μmol/L',
      referenceMin: 210,
      referenceMax: 420,
      status: '偏高',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 6, 1),
    );
    await repo.insertMetric(
      metricId: 'UA',
      metricName: '尿酸',
      value: 442,
      unit: 'μmol/L',
      referenceMin: 210,
      referenceMax: 420,
      status: '偏高',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 8, 1),
    );
    // 肌酐正常 → 不进异常列表
    await repo.insertMetric(
      metricId: 'CREA',
      metricName: '肌酐',
      value: 90,
      unit: 'μmol/L',
      referenceMin: 57,
      referenceMax: 111,
      status: '正常',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 8, 1),
    );

    final rid = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: DateTime(2026, 8, 1),
      reportType: '生化检查',
    );
    await repo.insertMetric(
      metricId: 'FPG',
      metricName: '空腹血糖',
      value: 7.0,
      unit: 'mmol/L',
      referenceMin: 3.9,
      referenceMax: 6.1,
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 1),
      reportId: rid,
    );

    final s = await build(now: DateTime(2026, 8, 29));

    expect(s.personName, '徐先生');
    expect(s.ageSexLine, contains('40 岁'));
    expect(s.ageSexLine, contains('男'));
    expect(s.diseases, ['2型糖尿病（确诊）']);
    expect(s.medications, ['二甲双胍 0.5g 每日 2 次']);

    final ua = s.abnormalMetrics.firstWhere((m) => m.name == '尿酸');
    expect(ua.valueText, '442 μmol/L');
    expect(ua.trend, '↓');
    expect(ua.previousText, contains('508'));
    expect(ua.referenceText, '参考 210–420');
    expect(s.abnormalMetrics.any((m) => m.name == '肌酐'), isFalse);
    expect(s.abnormalMetrics.any((m) => m.name == '空腹血糖'), isTrue);

    expect(s.recentReports.single.hospital, '深圳市人民医院');
    expect(s.recentReports.single.metricCount, 1);

    final txt = s.toPlainText();
    expect(txt, contains('【疾病史】'));
    expect(txt, contains('二甲双胍'));
    expect(txt, contains('不含医疗诊断'));
  });
}
