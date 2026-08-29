// A2：单份报告「分享 / 导出原件」的内容组装逻辑测试。
// 只测纯逻辑（buildReportSharePayload / reportShareCaption）；真正唤起系统分享面板
// 的 shareReport() 依赖平台通道，不在单元测试里跑。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/utils/report_export.dart';

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

  Future<MedicalReport> makeReport({
    String hospitalName = '市中心医院',
    String reportType = 'CT',
    String? sourceImagePath,
    String? rawText,
  }) async {
    final id = await repo.insertReport(
      hospitalName: hospitalName,
      reportDate: DateTime(2026, 8, 20),
      reportType: reportType,
      sourceImagePath: sourceImagePath,
      rawText: rawText,
    );
    return (await repo.getReportById(id))!;
  }

  test('说明行：医院 · 类型 · 日期，缺项自动跳过', () async {
    final full = await makeReport();
    expect(reportShareCaption(full), '市中心医院 · CT · 2026-08-20');

    final noHospital = await makeReport(hospitalName: '');
    expect(reportShareCaption(noHospital), 'CT · 2026-08-20');

    final noType = await makeReport(hospitalName: '协和', reportType: '');
    expect(reportShareCaption(noType), '协和 · 2026-08-20');
  });

  test('有原图：导出原图文件，分享文本只带说明行（不塞 OCR 全文）', () async {
    final report = await makeReport(
      sourceImagePath: '/tmp/report_1.jpg',
      rawText: '一大段 OCR 全文……',
    );
    final payload = buildReportSharePayload(report, fileExists: (_) => true);

    expect(payload.hasAnything, isTrue);
    expect(payload.filePaths, ['/tmp/report_1.jpg']);
    expect(payload.text, '市中心医院 · CT · 2026-08-20');
  });

  test('原图路径存在于库里但文件已丢失：退化为分享文字', () async {
    final report = await makeReport(
      sourceImagePath: '/tmp/gone.jpg',
      rawText: '双肺纹理清晰，未见明显异常。',
    );
    final payload = buildReportSharePayload(report, fileExists: (_) => false);

    expect(payload.hasAnything, isTrue);
    expect(payload.filePaths, isEmpty);
    expect(payload.text, contains('市中心医院 · CT · 2026-08-20'));
    expect(payload.text, contains('双肺纹理清晰，未见明显异常。'));
  });

  test('无原图、只有文字（影像报告只填了结论）：分享文字', () async {
    final report = await makeReport(rawText: '心电图：窦性心律，大致正常。');
    final payload = buildReportSharePayload(report, fileExists: (_) => false);

    expect(payload.hasAnything, isTrue);
    expect(payload.filePaths, isEmpty);
    expect(payload.text, contains('心电图：窦性心律，大致正常。'));
  });

  test('既无原图也无文字：没有可导出的内容', () async {
    final report = await makeReport();
    final payload = buildReportSharePayload(report, fileExists: (_) => false);

    expect(payload.hasAnything, isFalse);
    expect(payload.filePaths, isEmpty);
    expect(payload.text, isEmpty);
  });
}
