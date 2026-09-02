// iOS 结构优化：身体页一级导航只保留器官 / 身体系统，
// 指标分类（电解质 / 甲状腺 / 血糖…）下沉到所属系统内部。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/body_area_health.dart';

void main() {
  group('bodyAreaForSystem：指标分类下沉到器官 / 系统', () {
    test('电解质归入肾脏 / 泌尿，不再是一级节点', () {
      expect(bodyAreaForSystem('电解质'), '肾脏/泌尿');
    });

    test('甲状腺 / 血糖代谢归入内分泌 / 代谢', () {
      expect(bodyAreaForSystem('甲状腺'), '内分泌/代谢');
      expect(bodyAreaForSystem('血糖代谢'), '内分泌/代谢');
    });

    test('血液映射到血液系统', () {
      expect(bodyAreaForSystem('血液'), '血液系统');
    });

    test('未知 / 空 bodySystem 一律归「其他」，不自成一级', () {
      expect(bodyAreaForSystem('肿瘤标志物'), '其他');
      expect(bodyAreaForSystem('随便什么'), '其他');
      expect(bodyAreaForSystem(''), '其他');
    });

    test('一级列表全部是器官 / 身体系统，不含指标分类词', () {
      const forbidden = ['电解质', '血脂', '血糖', '肝功能', '肾功能', '肿瘤标志物'];
      for (final f in forbidden) {
        expect(coreBodyAreaOrder.contains(f), isFalse, reason: '$f 不应是一级节点');
      }
    });
  });

  group('日常记录 → 器官', () {
    test('血压 / 心率 → 心血管；血糖 / 体重 / 腰围 → 内分泌 / 代谢', () {
      expect(areasForDailyType('blood_pressure'), {'心血管'});
      expect(areasForDailyType('heart_rate'), {'心血管'});
      expect(areasForDailyType('blood_glucose'), {'内分泌/代谢'});
      expect(areasForDailyType('weight'), {'内分泌/代谢'});
      expect(areasForDailyType('waist'), {'内分泌/代谢'});
      expect(areasForDailyType('unknown'), isEmpty);
    });

    test('dailyReadingHint 一句话读数', () {
      expect(dailyReadingHint('blood_pressure', 138, 88), '血压 138/88');
      expect(dailyReadingHint('blood_glucose', 5.6, null), '血糖 5.6');
      expect(dailyReadingHint('weight', 62.0, null), '体重 62');
    });
  });

  group('metricGroupLabelForSystem：器官详情页内部的指标分类小标题', () {
    test('常见分类有稳定小标题', () {
      expect(metricGroupLabelForSystem('电解质'), '电解质');
      expect(metricGroupLabelForSystem('血糖代谢'), '血糖');
      expect(metricGroupLabelForSystem('肝脏'), '肝功能');
      expect(metricGroupLabelForSystem('血液'), '血常规');
    });

    test('未知分类回落到「其他指标」', () {
      expect(metricGroupLabelForSystem('xyz'), '其他指标');
    });
  });
}
