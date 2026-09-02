// 体检报告结构化：examSummary 解析 / 序列化 / 从后端 JSON 透传。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/report_models.dart';
import 'package:health_archive/services/report_recognition_service.dart';

void main() {
  test('ExamSummary fromJson / toJson round-trip', () {
    final j = {
      'conclusion': '血脂偏高，脂肪肝，建议复查。',
      'advice': ['低脂饮食', '3 个月后复查血脂'],
      'departments': [
        {'name': '内科', 'finding': '心律齐，未闻及杂音'},
        {'name': '外科', 'finding': '甲状腺未触及肿大'},
        {'name': '', 'finding': '空的丢掉'},
      ],
      'general': {
        'heightCm': 172,
        'weightKg': 70.5,
        'bmi': 23.8,
        'systolic': 130,
        'diastolic': 85,
        'pulse': 76,
      },
    };
    final e = ExamSummary.fromJson(j);
    expect(e.isEmpty, isFalse);
    expect(e.conclusion, contains('脂肪肝'));
    expect(e.advice, hasLength(2));
    expect(e.departments, hasLength(2)); // 空的被过滤
    expect(e.general.systolic, 130);
    expect(e.general.pulse, 76);

    final back = ExamSummary.fromJson(e.toJson());
    expect(back.conclusion, e.conclusion);
    expect(back.departments.map((d) => d.name), ['内科', '外科']);
    expect(back.general.bmi, 23.8);
  });

  test('空 / 无意义的 examSummary → isEmpty', () {
    expect(ExamSummary.fromJson({}).isEmpty, isTrue);
    expect(
        ExamSummary.fromJson({'advice': [], 'departments': [], 'general': {}})
            .isEmpty,
        isTrue);
  });

  test('structuredReportFromBackendJson 透传 examSummary，普通化验单为 null', () {
    final exam = structuredReportFromBackendJson({
      'reportType': '健康体检',
      'metrics': [
        {'rawName': '血红蛋白', 'numericValue': 142, 'unit': 'g/L'},
      ],
      'examSummary': {
        'conclusion': '总体良好',
        'general': {'systolic': 120, 'diastolic': 78},
      },
    }, null);
    expect(exam.examSummary, isNotNull);
    expect(exam.examSummary!.conclusion, '总体良好');
    expect(exam.examSummary!.general.diastolic, 78);
    expect(exam.metrics.single.matchedMetricId, 'HGB');

    final lab = structuredReportFromBackendJson({
      'reportType': '血常规',
      'metrics': [
        {'rawName': '血红蛋白', 'numericValue': 142, 'unit': 'g/L'},
      ],
    }, null);
    expect(lab.examSummary, isNull);
  });
}
