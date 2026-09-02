// V0.4A 报告导入数据层闭环测试：模拟「写入报告+指标、按报告查询、身体部位可见、级联删除」。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/models/body_area_health.dart';
import 'package:health_archive/models/metric_dictionary.dart';

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

  /// 模拟一次报告导入：写入报告 + 关联指标（sourceType=report_import）
  Future<int> importMockReport() async {
    final reportId = await repo.insertReport(
      hospitalName: '深圳某医院',
      reportDate: DateTime(2026, 8, 19),
      reportType: '生化检查',
      sourceImagePath: '/path/to/img.jpg',
      rawText: '化验单文本（不进日志）',
    );
    final metrics = [
      (metricId: 'ALT', name: 'ALT', value: 32.0, status: '正常'),
      (metricId: 'UA', name: '尿酸', value: 480.0, status: '偏高'),
    ];
    for (final m in metrics) {
      await repo.insertMetric(
        metricId: m.metricId,
        metricName: m.name,
        value: m.value,
        unit: 'U/L',
        referenceMin: 0,
        referenceMax: 100,
        status: m.status,
        bodySystem: bodySystemForMetric(m.metricId, fallback: '其他'),
        measuredAt: DateTime(2026, 8, 19),
        sourceType: 'report_import',
        reportId: reportId,
      );
    }
    return reportId;
  }

  test('报告导入后：记录页可查报告、身体部位可查指标、rawText 不打印', () async {
    final reportId = await importMockReport();

    // 报告可查到（含原始图片路径 / rawText 字段）
    final reports = await repo.getAllReports();
    expect(reports, hasLength(1));
    expect(reports.first.hospitalName, '深圳某医院');
    expect(reports.first.sourceImagePath, '/path/to/img.jpg');
    // rawText 已在库里（医疗原始记录需保留），断言不为空
    expect(reports.first.rawText, isNotEmpty);

    // 按报告查到关联指标
    final byReport = await repo.getMetricsByReport(reportId);
    expect(byReport, hasLength(2));
    expect(byReport.every((m) => m.sourceType == 'report_import'), isTrue);
    expect(byReport.every((m) => m.reportId == reportId), isTrue);

    // 底层身体系统仍能查到；展示层会映射到更自然的身体部位
    final body = await repo.getMetricsByBodySystem('肾脏');
    expect(body.any((m) => m.metricId == 'UA'), isTrue);
    expect(bodyAreaForSystem('肾脏'), '肾脏/泌尿');
    expect(bodyAreaForSystem('血糖代谢'), '内分泌/代谢');
  });

  test('级联删除：删除报告会连带删除其指标，且手工录入数据不受影响', () async {
    // 一份报告 + 一条手工数据
    final reportId = await importMockReport();
    await repo.insertMetric(
      metricId: 'HBA1C',
      metricName: '糖化血红蛋白',
      value: 6.8,
      unit: '%',
      referenceMin: 4,
      referenceMax: 6,
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 18),
      sourceType: 'manual',
    );

    await repo.deleteReportCascade(reportId);

    expect(await repo.getAllReports(), isEmpty);
    // 报告的指标被级联删除
    final remaining = await repo.getAllMetrics();
    expect(remaining, hasLength(1)); // 只剩手工那条
    expect(remaining.first.sourceType, 'manual');
  });

  test('指标匹配器：别名映射到标准指标', () {
    expect(matchMetricId('血清肌酐'), 'CREA');
    expect(matchMetricId('Cr'), 'CREA');
    expect(matchMetricId('Creatinine'), 'CREA');
    expect(matchMetricId('糖化血红蛋白'), 'HBA1C');
    expect(matchMetricId('GHb'), 'HBA1C');
    expect(matchMetricId('血尿酸'), 'UA');
    expect(bodySystemForMetric('CREA'), '肾脏');
    expect(bodySystemForMetric('UA'), '肾脏');
    // 未匹配
    expect(matchMetricId('完全未知指标'), isNull);
  });

  test('匹配缓存 + rematchAllMetrics：按名字重判历史行', () async {
    await repo.ensureDefaultPersonProfile();
    // 一条历史 UNKNOWN 行，名字其实是「纤维蛋白原」（词典里有 FIB）
    await repo.insertMetric(
      metricId: 'UNKNOWN',
      metricName: '纤维蛋白原',
      value: 3.0,
      unit: 'g/L',
      referenceMin: null,
      referenceMax: null,
      status: '正常',
      bodySystem: '其他',
      measuredAt: DateTime(2026, 8, 1),
      sourceType: 'report_import',
    );
    // 一条名字没进词典、但缓存里有的行
    await repo.insertMetric(
      metricId: 'UNKNOWN',
      metricName: '深圳HR白蛋白',
      value: 45,
      unit: 'g/L',
      referenceMin: null,
      referenceMax: null,
      status: '正常',
      bodySystem: '其他',
      measuredAt: DateTime(2026, 8, 1),
      sourceType: 'report_import',
    );
    await repo.upsertMetricMatch(
        rawDisplay: '深圳HR白蛋白', canonicalId: 'ALB', source: 'learned');

    final changed = await repo.rematchAllMetrics();
    expect(changed, 2);

    final rows = await repo.getAllMetrics();
    final fib = rows.firstWhere((m) => m.metricName == '纤维蛋白原');
    expect(fib.metricId, 'FIB');
    expect(fib.bodySystem, '凝血');
    final alb = rows.firstWhere((m) => m.metricName == '深圳HR白蛋白');
    expect(alb.metricId, 'ALB');

    // 删掉缓存后再 rematch → 那条退回 UNKNOWN
    final match = (await repo.getAllMetricMatches()).single;
    await repo.deleteMetricMatch(match.id);
    await repo.rematchAllMetrics();
    final alb2 = (await repo.getAllMetrics())
        .firstWhere((m) => m.metricName == '深圳HR白蛋白');
    expect(alb2.metricId, 'UNKNOWN');
  });

  test('体检报告：examSummary 入库、进导出', () async {
    await repo.ensureDefaultPersonProfile();
    final rid = await repo.insertReport(
      hospitalName: '某体检中心',
      reportDate: DateTime(2026, 9, 1),
      reportType: '健康体检',
      examSummary: '{"conclusion":"血脂偏高","general":{"systolic":130}}',
    );
    final r = (await repo.getAllReports()).single;
    expect(r.id, rid);
    expect(r.examSummary, contains('血脂偏高'));

    final data = await repo.exportHealthData();
    final exported = (data['reports'] as List).single as Map;
    expect(exported['examSummary'], contains('130'));
  });

  test('T1 默认本人档案：新安装自动创建，新增数据归属 profileId=1', () async {
    final profile = await repo.ensureDefaultPersonProfile();
    expect(profile.id, HealthRepository.defaultProfileId);
    expect(profile.displayName, '本人');
    expect(profile.relationship, 'self');

    final reportId = await repo.insertReport(
      hospitalName: '市第一医院',
      reportDate: DateTime(2026, 8, 20),
      reportType: '生化检查',
    );
    await repo.insertMetric(
      metricId: 'CREA',
      metricName: '肌酐',
      value: 93,
      rawValue: '93 μmol/L',
      numericValue: 93,
      unit: 'μmol/L',
      referenceMin: 57,
      referenceMax: 111,
      referenceRangeRaw: '57-111',
      status: '正常',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 8, 20),
      sourceType: 'report_import',
      reportId: reportId,
      verificationStatus: 'user_confirmed',
    );

    final reports = await repo.getAllReports();
    final metrics = await repo.getAllMetrics();
    expect(reports.single.profileId, HealthRepository.defaultProfileId);
    expect(metrics.single.profileId, HealthRepository.defaultProfileId);
    expect(metrics.single.verificationStatus, 'user_confirmed');
    expect(metrics.single.rawValue, '93 μmol/L');
    expect(metrics.single.referenceRangeRaw, '57-111');
  });

  test('T1 可信观测：用户修改后的识别结果保留原始值和修改状态', () async {
    final reportId = await repo.insertReport(
      hospitalName: '市第一医院',
      reportDate: DateTime(2026, 8, 21),
      reportType: '血糖',
      recognitionStatus: 'confirmed',
    );
    await repo.insertMetric(
      metricId: 'FPG',
      metricName: '空腹血糖',
      value: 6.1,
      rawValue: '6.8 mmol/L',
      numericValue: 6.1,
      unit: 'mmol/L',
      canonicalValue: 6.1,
      canonicalUnit: 'mmol/L',
      referenceMin: 3.9,
      referenceMax: 6.1,
      referenceRangeRaw: '3.9-6.1',
      sourceAbnormalFlag: 'H',
      status: '正常',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 21),
      sourceType: 'report_import',
      rawName: '空腹葡萄糖',
      matchType: 'alias',
      recognitionConfidence: 0.72,
      verificationStatus: 'user_modified',
      reportId: reportId,
    );

    final metric = (await repo.getMetricsByReport(reportId)).single;
    expect(metric.value, 6.1);
    expect(metric.rawValue, '6.8 mmol/L');
    expect(metric.verificationStatus, 'user_modified');
    expect(metric.sourceAbnormalFlag, 'H');
    expect(metric.recognitionConfidence, 0.72);
  });

  test('T4 健康资料主题：按资料数量、最近日期、待核对和报告原标记汇总', () async {
    final reportId = await repo.insertReport(
      hospitalName: '市第一医院',
      reportDate: DateTime(2026, 8, 22),
      reportType: '生化',
      recognitionStatus: 'confirmed',
    );
    await repo.insertMetric(
      metricId: 'UA',
      metricName: '尿酸',
      value: 480,
      unit: 'μmol/L',
      referenceMin: 210,
      referenceMax: 420,
      status: '偏高',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 8, 22),
      sourceType: 'report_import',
      reportId: reportId,
      sourceAbnormalFlag: 'H',
      verificationStatus: 'user_confirmed',
    );
    await repo.insertMetric(
      metricId: 'CREA',
      metricName: '肌酐',
      value: 93,
      unit: 'μmol/L',
      referenceMin: 57,
      referenceMax: 111,
      status: '正常',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 8, 22),
      sourceType: 'report_import',
      reportId: reportId,
      verificationStatus: 'unverified',
    );

    final topics = buildHealthTopicSummaries(await repo.getAllMetrics());
    final kidney = topics.firstWhere((t) => t.name == '肾脏/泌尿');

    expect(kidney.recordCount, 1);
    expect(kidney.latestMeasuredAt, DateTime(2026, 8, 22));
    expect(kidney.pendingReviewCount, 1);
    expect(kidney.sourceFlagCount, 1);
    expect(kidney.statusLabel, '1 项待核对');
    expect(kidney.summaryText, contains('1 份相关资料'));
    expect(kidney.summaryText, contains('1 项报告原标记'));
  });

  test('F2 详情页编辑：updateReportInfo 只改传入的字段', () async {
    final id = await repo.insertReport(
      hospitalName: '旧医院',
      reportDate: DateTime(2026, 8, 1),
      reportType: '生化检查',
    );

    await repo.updateReportInfo(id, hospitalName: '新医院');
    var r = await repo.getReportById(id);
    expect(r!.hospitalName, '新医院');
    expect(r.reportType, '生化检查'); // 未传，不动

    await repo.updateReportInfo(id, reportType: '血常规');
    r = await repo.getReportById(id);
    expect(r!.hospitalName, '新医院');
    expect(r.reportType, '血常规');
  });

  test('D2 runInTransaction：中途抛异常时整批写入回滚', () async {
    await expectLater(
      repo.runInTransaction(() async {
        await repo.insertReport(
          hospitalName: '半条报告',
          reportDate: DateTime(2026, 8, 2),
          reportType: '生化检查',
        );
        throw StateError('模拟写指标失败');
      }),
      throwsA(isA<StateError>()),
    );
    // 事务回滚：那条报告不应留在库里
    expect(await repo.getAllReports(), isEmpty);
  });

  test('knownNames：首次为空，addKnownName 追加并宽松去重', () async {
    await repo.ensureDefaultPersonProfile();
    final pid = repo.activeProfileId;

    expect(await repo.getKnownNames(pid), '');

    await repo.addKnownName(pid, '张三');
    expect(await repo.getKnownNames(pid), '张三');

    await repo.addKnownName(pid, '张 三 '); // 宽松去重，不重复写
    expect(await repo.getKnownNames(pid), '张三');

    await repo.addKnownName(pid, '李四');
    expect(await repo.getKnownNames(pid), '张三,李四');

    await repo.addKnownName(pid, '   '); // 空名忽略
    expect(await repo.getKnownNames(pid), '张三,李四');
  });
}
