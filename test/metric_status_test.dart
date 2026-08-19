// computeStatus（状态判断）的单元测试：
// 覆盖完整范围、只有下限、只有上限、空范围 / 空值 等分支。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/metric_dictionary.dart';

void main() {
  group('computeStatus', () {
    test('上下限都有：正常判断', () {
      const range = ReferenceRange(min: 4.0, max: 6.0);
      expect(computeStatus(5.0, range), '正常');
      expect(computeStatus(6.8, range), '偏高');
      expect(computeStatus(3.0, range), '偏低');
      expect(computeStatus(6.0, range), '正常'); // 等于上限不算偏高
      expect(computeStatus(4.0, range), '正常'); // 等于下限不算偏低
    });

    test('只有下限（如 eGFR、HDL-C）：低于下限偏低，否则正常', () {
      final egfrRange = findMetricDefinition('EGFR')!.typicalRange;
      expect(egfrRange.min, 90);
      expect(egfrRange.max, isNull);
      expect(computeStatus(100, egfrRange), '正常');
      expect(computeStatus(70, egfrRange), '偏低');
      expect(computeStatus(90, egfrRange), '正常'); // 等于下限不偏低

      final hdlcRange = findMetricDefinition('HDLC')!.typicalRange;
      expect(computeStatus(1.5, hdlcRange), '正常');
      expect(computeStatus(0.8, hdlcRange), '偏低');
    });

    test('只有上限：高于上限偏高，否则正常', () {
      const range = ReferenceRange(min: null, max: 10.0);
      expect(computeStatus(5, range), '正常');
      expect(computeStatus(12, range), '偏高');
      expect(computeStatus(10, range), '正常'); // 等于上限不高
    });

    test('上下限都为空，或 value/range 为空：未判断', () {
      expect(computeStatus(6.8, null), '未判断');
      expect(computeStatus(null, const ReferenceRange(min: 4, max: 6)), '未判断');
      expect(computeStatus(6.8, const ReferenceRange()), '未判断');
      expect(computeStatus(6.8, const ReferenceRange(min: null, max: null)), '未判断');
    });
  });
}
