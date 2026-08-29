// 第三阶段：MetricValue 来源体系 —— 归一化 / 标签 / wire 值 / 未来预留项。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/metric_source.dart';

void main() {
  test('历史 / 别名 wire 值都能归一化到规范枚举', () {
    expect(metricSourceKindFromWire('manual'), MetricSourceKind.manual);
    expect(metricSourceKindFromWire('daily'), MetricSourceKind.dailyRecord);
    expect(metricSourceKindFromWire('daily_record'), MetricSourceKind.dailyRecord);
    // 历史库里 OCR 结构化指标存的是 report_import
    expect(metricSourceKindFromWire('report_import'), MetricSourceKind.reportOcr);
    expect(metricSourceKindFromWire('report_ocr'), MetricSourceKind.reportOcr);
    expect(metricSourceKindFromWire('future_ocr'), MetricSourceKind.reportOcr);
    expect(
        metricSourceKindFromWire('future_hospital'), MetricSourceKind.importedFile);
    expect(metricSourceKindFromWire('apple_health'), MetricSourceKind.appleHealth);
    expect(metricSourceKindFromWire('healthkit'), MetricSourceKind.appleHealth);
    expect(metricSourceKindFromWire('device'), MetricSourceKind.device);
    expect(metricSourceKindFromWire(null), MetricSourceKind.unknown);
    expect(metricSourceKindFromWire('乱七八糟'), MetricSourceKind.unknown);
  });

  test('wire 值往返稳定，OCR 仍沿用历史值避免数据迁移', () {
    for (final kind in MetricSourceKind.values) {
      expect(metricSourceKindFromWire(metricSourceWire(kind)), kind,
          reason: '$kind 的 wire 值应能被解析回同一枚举');
    }
    expect(metricSourceWire(MetricSourceKind.reportOcr), 'report_import');
    expect(metricSourceWire(MetricSourceKind.appleHealth), 'apple_health');
    expect(metricSourceWire(MetricSourceKind.device), 'device');
  });

  test('展示标签', () {
    expect(metricSourceLabelFromWire('manual'), '手工录入');
    expect(metricSourceLabelFromWire('report_import'), '报告导入');
    expect(metricSourceLabelFromWire('daily'), '日常记录');
    expect(metricSourceLabel(MetricSourceKind.appleHealth), 'Apple Health');
    expect(metricSourceLabel(MetricSourceKind.device), '设备导入');
  });

  test('记录页可见的来源筛选项不含未实现来源', () {
    expect(visibleRecordSourceFilters, contains(MetricSourceKind.reportOcr));
    expect(visibleRecordSourceFilters, contains(MetricSourceKind.manual));
    expect(visibleRecordSourceFilters, contains(MetricSourceKind.dailyRecord));
    expect(
        visibleRecordSourceFilters, isNot(contains(MetricSourceKind.appleHealth)));
    expect(visibleRecordSourceFilters, isNot(contains(MetricSourceKind.device)));
  });
}
