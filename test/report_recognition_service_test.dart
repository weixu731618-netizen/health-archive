import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/services/report_recognition_service.dart';

void main() {
  test('远程结构化 JSON 映射保留 numericValue/textValue/qualifier/originalStatus', () {
    final report = structuredReportFromBackendJson({
      'hospitalName': '市第一医院',
      'reportDate': '2026-08-25',
      'reportType': '生化',
      'patientName': '张三',
      'metrics': [
        {
          'rawName': '空腹葡萄糖',
          'numericValue': 6.8,
          'unit': 'mmol/L',
          'referenceMin': 3.9,
          'referenceMax': 6.1,
          'referenceText': '3.9-6.1',
          'originalStatus': 'H',
          'confidence': 0.82,
        },
        {
          'rawName': '尿蛋白',
          'textValue': '阴性',
          'qualifier': null,
          'unit': '',
          'referenceText': '阴性',
          'originalStatus': null,
          'confidence': 0.7,
        },
        {
          'rawName': 'C反应蛋白',
          'numericValue': 0.5,
          'qualifier': '<',
          'unit': 'mg/L',
          'confidence': 0.91,
        },
      ],
    }, '/tmp/report.jpg');

    expect(report.hospitalName, '市第一医院');
    expect(report.reportDate, DateTime(2026, 8, 25));
    expect(report.sourceImagePath, '/tmp/report.jpg');
    expect(report.metrics, hasLength(3));

    final glucose = report.metrics[0];
    expect(glucose.matchedMetricId, 'FPG');
    expect(glucose.numericValue, 6.8);
    expect(glucose.value, 6.8);
    expect(glucose.referenceText, '3.9-6.1');
    expect(glucose.originalStatus, 'H');
    expect(glucose.status, '偏高');

    final urineProtein = report.metrics[1];
    expect(urineProtein.matchedMetricId, 'PRO-U');
    expect(urineProtein.numericValue, isNull);
    expect(urineProtein.textValue, '阴性');
    expect(urineProtein.value, 0);
    // 定性结果「阴性」→ 正常（不再是「未判断」）。
    expect(urineProtein.status, '正常');

    final crp = report.metrics[2];
    expect(crp.numericValue, 0.5);
    expect(crp.qualifier, '<');
    expect(crp.unit, 'mg/L');
  });

  test('远程结构化优先使用本地可识别的 matchedMetricId 和 canonicalName', () {
    final report = structuredReportFromBackendJson({
      'metrics': [
        {
          'rawName': '血清项目 1',
          'canonicalName': '血清肌酐',
          'matchedMetricId': 'CREA',
          'numericValue': 93,
          'unit': 'umol/L',
          'confidence': 0.9,
        },
      ],
    }, null);

    expect(report.metrics, hasLength(1));
    expect(report.metrics.single.matchedMetricId, 'CREA');
    expect(report.metrics.single.canonicalName, '肌酐');
    expect(report.metrics.single.unit, 'μmol/L');
    expect(validateStructuredReportForReview(report), isNull);
  });

  test('远程结构化解析 rawText / patientGender / patientBirthDate', () {
    final report = structuredReportFromBackendJson({
      'hospitalName': '市中心医院',
      'reportType': 'B超',
      'patientName': '李四',
      'patientGender': '男',
      'patientBirthDate': '1980-03-15',
      'rawText': '肝脏大小形态正常\n胆囊未见结石',
      'metrics': [],
    }, null);
    expect(report.rawText, contains('肝脏大小形态正常'));
    expect(report.patientGender, '男');
    expect(report.patientBirthDate, DateTime(1980, 3, 15));
    // 0 指标不再是「失败」：结构化映射照常返回，交调用方按 metrics 是否为空分流。
    expect(report.metrics, isEmpty);
  });

  test('patientGender 非男/女 → 收敛为空；无 birthDate → null', () {
    final report = structuredReportFromBackendJson({
      'patientGender': 'unknown',
      'rawText': '',
      'metrics': [],
    }, null);
    expect(report.patientGender, '');
    expect(report.patientBirthDate, isNull);
  });

  test('解析 isMedical / imagingType（只认受限 12 类，其余→空）', () {
    final ct = structuredReportFromBackendJson({
      'isMedical': true,
      'imagingType': 'CT',
      'rawText': 'CT 平扫...',
      'metrics': [],
    }, null);
    expect(ct.isMedical, isTrue);
    expect(ct.imagingType, 'CT');

    final bogus = structuredReportFromBackendJson({
      'isMedical': true,
      'imagingType': '其他', // 不在 12 类里
      'metrics': [],
    }, null);
    expect(bogus.imagingType, '');

    final none = structuredReportFromBackendJson({'metrics': []}, null);
    expect(none.isMedical, isFalse);
    expect(none.imagingType, '');
  });

  test('mergeStructuredReports：imagingType/isMedical 也合并（首个非空 / 任一为真）', () {
    final p1 = structuredReportFromBackendJson(
        {'isMedical': false, 'imagingType': '', 'rawText': 'a', 'metrics': []}, null);
    final p2 = structuredReportFromBackendJson(
        {'isMedical': true, 'imagingType': 'B超', 'rawText': 'b', 'metrics': []}, null);
    final m = mergeStructuredReports([p1, p2]);
    expect(m.isMedical, isTrue);
    expect(m.imagingType, 'B超');
  });

  test('mergeStructuredReports：多页合并 —— 指标拼接去重、元信息取首个非空', () {
    final p1 = structuredReportFromBackendJson({
      'hospitalName': '市中心医院',
      'reportDate': '2026-03-02',
      'reportType': '血常规',
      'patientName': '徐威',
      'patientGender': '男',
      'rawText': '白细胞 4.9\n血红蛋白 150',
      'metrics': [
        {'rawName': '白细胞计数', 'numericValue': 4.9, 'unit': '*10^9/L', 'confidence': 0.9},
      ],
    }, null);
    final p2 = structuredReportFromBackendJson({
      'hospitalName': '', // 第二页没读到医院
      'reportType': '其他检验',
      'rawText': '总胆固醇 5.4',
      'metrics': [
        {'rawName': '白细胞计数', 'numericValue': 4.9, 'unit': '*10^9/L', 'confidence': 0.9}, // 与 p1 重复
        {'rawName': '总胆固醇', 'numericValue': 5.4, 'unit': 'mmol/L', 'confidence': 0.9},
      ],
    }, null);

    final merged = mergeStructuredReports([p1, p2], sourceImagePath: '/tmp/a.pdf');
    expect(merged.hospitalName, '市中心医院');
    expect(merged.reportDate, DateTime(2026, 3, 2));
    expect(merged.dateFromOcr, isTrue);
    expect(merged.reportType, '血常规'); // 跳过 p2 的「其他检验」
    expect(merged.patientName, '徐威');
    expect(merged.patientGender, '男');
    expect(merged.sourceImagePath, '/tmp/a.pdf');
    // 白细胞去重后只剩一条，加上总胆固醇 = 2 条
    expect(merged.metrics, hasLength(2));
    expect(
        merged.metrics.where((m) => m.rawName == '白细胞计数').length, 1);
    expect(merged.metrics.any((m) => m.rawName == '总胆固醇'), isTrue);
    expect(merged.rawText, contains('第 1 页'));
    expect(merged.rawText, contains('第 2 页'));
  });

  test('mergeStructuredReports：单页原样返回', () {
    final only = structuredReportFromBackendJson({'metrics': []}, null);
    expect(identical(mergeStructuredReports([only]), only), isTrue);
  });

  test('远程结构化空结果或无法匹配时不进入核对页', () {
    final empty = structuredReportFromBackendJson({'metrics': []}, null);
    expect(validateStructuredReportForReview(empty), contains('未识别到'));

    final unmatched = structuredReportFromBackendJson({
      'metrics': [
        {
          'rawName': '图片标题',
          'numericValue': 123,
          'unit': '',
          'confidence': 0.3,
        },
      ],
    }, null);
    expect(validateStructuredReportForReview(unmatched), contains('无法匹配'));
  });
}
