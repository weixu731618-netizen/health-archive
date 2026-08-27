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
    expect(urineProtein.status, '未判断');

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
