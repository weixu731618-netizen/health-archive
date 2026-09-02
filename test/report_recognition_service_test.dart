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

  test('参考上限被读成负数（"3.5--9.5" → referenceMax:-9.5）时纠回来，不再一律「偏高」',
      () {
    final report = structuredReportFromBackendJson({
      'metrics': [
        {
          'rawName': '血红蛋白',
          'numericValue': 142,
          'unit': 'g/L',
          'referenceMin': 130,
          'referenceMax': -175,
          'confidence': 0.99,
        },
        {
          'rawName': '中性粒细胞百分比',
          'numericValue': 17.4,
          'unit': '%',
          'referenceMin': 40,
          'referenceMax': -75,
          'confidence': 0.99,
        },
      ],
    }, null);
    // 142 在 130–175 内 → 正常（修复前会是「偏高」）
    expect(report.metrics[0].status, '正常');
    expect(report.metrics[0].referenceMax, 175);
    // 17.4 低于 40 → 偏低（修复前会是「偏高」）
    expect(report.metrics[1].status, '偏低');
  });

  test('化验单标注与按范围算出的状态冲突时，改用化验单标注', () {
    final report = structuredReportFromBackendJson({
      'metrics': [
        {
          // 范围没读准（当成 3.9–6.1），值 5.0 会算成"正常"，但化验单标了 ↑
          'rawName': '空腹血糖',
          'numericValue': 5.0,
          'unit': 'mmol/L',
          'referenceMin': 3.9,
          'referenceMax': 6.1,
          'originalStatus': '↑',
          'confidence': 0.9,
        },
        {
          // 化验单没标 → 不据此翻，保持按范围算的"正常"
          'rawName': 'C反应蛋白',
          'numericValue': 2.0,
          'unit': 'mg/L',
          'referenceMin': 0,
          'referenceMax': 8,
          'confidence': 0.9,
        },
      ],
    }, null);
    expect(report.metrics[0].status, '偏高');
    expect(report.metrics[0].statusFromLabFlag, isTrue);
    expect(report.metrics[1].status, '正常');
    expect(report.metrics[1].statusFromLabFlag, isFalse);
  });

  test('参考范围数量级明显不对时，退回用标准指标的典型范围判定', () {
    final report = structuredReportFromBackendJson({
      'metrics': [
        {
          // 空腹血糖典型 3.9–6.1；这里范围被读成 39–61（差一个数量级）
          'rawName': '空腹血糖',
          'numericValue': 5.2,
          'unit': 'mmol/L',
          'referenceMin': 39,
          'referenceMax': 61,
          'confidence': 0.9,
        },
      ],
    }, null);
    expect(report.metrics[0].matchedMetricId, 'FPG');
    // 用典型范围 3.9–6.1 判 → 5.2 正常（用错范围 39–61 会是"偏低"）
    expect(report.metrics[0].status, '正常');
  });

  test('匹配顺序：本地词典 > 归一化缓存 > 后端 DeepSeek 归一化 > 非核心', () {
    final report = structuredReportFromBackendJson({
      'metrics': [
        // 本地词典能精确匹配 → 'exact'，即使缓存里给了别的 id 也不理会
        {'rawName': 'ALT', 'numericValue': 30, 'unit': 'U/L'},
        // 词典匹配不上，但缓存里有 → 'cache'
        {'rawName': '深圳HR白蛋白', 'numericValue': 45, 'unit': 'g/L'},
        // 词典、缓存都没有，后端本轮 DeepSeek 给了 id 且单位兼容 → 'deepseek'
        {
          'rawName': '血色素测定',
          'numericValue': 140,
          'unit': 'g/L',
          'matchedMetricId': 'HGB',
          'canonicalSource': 'deepseek',
        },
        // 同上但单位对不上 → 不采纳，落非核心
        {
          'rawName': '某激素',
          'numericValue': 3,
          'unit': 'kg',
          'matchedMetricId': 'HGB',
          'canonicalSource': 'deepseek',
        },
      ],
    }, null, matchCache: {'深圳hr白蛋白': 'ALB', 'alt': 'AST'});

    expect(report.metrics[0].matchedMetricId, 'ALT');
    expect(report.metrics[0].matchType, 'exact');
    expect(report.metrics[1].matchedMetricId, 'ALB');
    expect(report.metrics[1].matchType, 'cache');
    expect(report.metrics[2].matchedMetricId, 'HGB');
    expect(report.metrics[2].matchType, 'deepseek');
    expect(report.metrics[3].matchedMetricId, isNull);
    expect(report.metrics[3].matchType, 'unmatched');
  });

  test('血红蛋白典型范围放宽到男女合并（115–175），女性 120 配上错范围也不误判', () {
    // 范围被 OCR 读成 g/dL 数量级（13–17），值 120（g/L，女性正常）。
    // 数量级交叉验 → 退回典型范围 115–175 → 正常（放宽前典型 130–175 → 偏高）。
    final report = structuredReportFromBackendJson({
      'metrics': [
        {
          'rawName': '血红蛋白',
          'numericValue': 120,
          'unit': 'g/L',
          'referenceMin': 13,
          'referenceMax': 17,
        },
      ],
    }, null);
    expect(report.metrics[0].matchedMetricId, 'HGB');
    expect(report.metrics[0].status, '正常');
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
