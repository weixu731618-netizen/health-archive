// 危险信号（危急值提醒）：命中该出、正常值不出、单位对不上不误报。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/models/danger_signals.dart';

HealthMetric _m(String name, double value, {String unit = ''}) => HealthMetric(
      id: name.hashCode & 0x7fffffff,
      profileId: 1,
      metricId: 'X',
      metricName: name,
      value: value,
      unit: unit,
      status: '偏高',
      bodySystem: '其他',
      measuredAt: DateTime(2026, 9, 1),
      sourceType: 'report_import',
      createdAt: DateTime(2026, 9, 1),
      matchType: 'exact',
      verificationStatus: 'user_confirmed',
    );

List<String> _msgs(List<HealthMetric> ms) =>
    dangerSignalsForMetrics(ms).map((s) => s.message).toList();

void main() {
  test('命中危急值', () {
    expect(_msgs([_m('血红蛋白', 52, unit: 'g/L')]).single, contains('重度贫血'));
    expect(_msgs([_m('血小板计数', 12, unit: '10^9/L')]).single, contains('出血风险'));
    expect(_msgs([_m('血钾', 6.5, unit: 'mmol/L')]).single, contains('血钾过高'));
    expect(_msgs([_m('葡萄糖', 25, unit: 'mmol/L')]).single, contains('血糖极高'));
    expect(_msgs([_m('中性粒细胞绝对值', 0.3)]).single, contains('粒细胞缺乏'));
    expect(_msgs([_m('原始细胞', 2, unit: '%')]).single, contains('原始 / 幼稚细胞'));
    expect(_msgs([_m('INR', 6.0)]).single, contains('抗凝过度'));
  });

  test('正常值不出信号', () {
    expect(_msgs([_m('血红蛋白', 140, unit: 'g/L')]), isEmpty);
    expect(_msgs([_m('血小板计数', 200, unit: '10^9/L')]), isEmpty);
    expect(_msgs([_m('血钾', 4.2, unit: 'mmol/L')]), isEmpty);
    expect(_msgs([_m('葡萄糖', 5.2, unit: 'mmol/L')]), isEmpty);
    expect(_msgs([_m('原始细胞', 0)]), isEmpty);
  });

  test('单位对不上（数量级不符）不误报', () {
    // 血红蛋白若是 g/dL（约 5.2）不在 [20,60) → 不当重度贫血
    expect(_msgs([_m('血红蛋白', 5.2, unit: 'g/dL')]), isEmpty);
    // 肌酐 mg/dL（约 1.0）不在 [442,5000) → 不报
    expect(_msgs([_m('肌酐', 1.0, unit: 'mg/dL')]), isEmpty);
  });

  test('百分比 / 绝对值区分，不重复', () {
    // 嗜酸性粒细胞百分比 25% → 百分比那条
    final pct = dangerSignalsForMetrics([_m('嗜酸性粒细胞百分比', 25, unit: '%')]);
    expect(pct.single.message, contains('百分比'));
    // 嗜酸性粒细胞绝对值 3.0 → 绝对值那条
    final abs =
        dangerSignalsForMetrics([_m('嗜酸性粒细胞绝对值', 3.0, unit: '10^9/L')]);
    expect(abs.single.message, contains('绝对值'));
  });

  test('血小板压积 / 分布宽度 不被当成血小板计数', () {
    expect(_msgs([_m('血小板压积', 0.15, unit: '%')]), isEmpty);
    expect(_msgs([_m('血小板分布宽度', 12, unit: 'fL')]), isEmpty);
  });

  test('尿钾 / 尿糖 不被当成血钾 / 血糖', () {
    expect(_msgs([_m('尿钾', 8, unit: 'mmol/L')]), isEmpty);
  });
}
