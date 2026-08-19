// V0.4A 报告导入数据层闭环测试：模拟「写入报告+指标、按报告查询、身体系统可见、级联删除」。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/models/metric_dictionary.dart';
import 'package:health_archive/models/report_models.dart';

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

  test('报告导入后：记录页可查报告、身体系统可查指标、rawText 不打印', () async {
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

    // 身体系统也能查到（真实数据优先的读取来源）
    final body = await repo.getMetricsByBodySystem('血糖代谢');
    expect(body.any((m) => m.metricId == 'UA'), isTrue);
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
    // 未匹配
    expect(matchMetricId('完全未知指标'), isNull);
  });
}
