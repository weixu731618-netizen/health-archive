// Round 3b：非核心 / 仅提示指标进器官详情页展示，但不参与器官判定 / 趋势 /
// 首页需关注。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/models/body_area_health.dart';
import 'package:health_archive/models/metric_dictionary.dart';

final _now = DateTime(2026, 9, 1);

HealthMetric _m(
  String id, {
  required String name,
  required String status,
  required String bodySystem,
  double value = 1,
  int daysAgo = 1,
}) =>
    HealthMetric(
      id: (id.hashCode ^ name.hashCode ^ daysAgo) & 0x7fffffff,
      profileId: 1,
      metricId: id,
      metricName: name,
      value: value,
      unit: 'x',
      status: status,
      bodySystem: bodySystem,
      measuredAt: _now.subtract(Duration(days: daysAgo)),
      sourceType: 'report_import',
      createdAt: _now,
      matchType: id == 'UNKNOWN' ? 'unmatched' : 'exact',
      verificationStatus: 'user_confirmed',
    );

BodyAreaHealthSummary _area(List<HealthMetric> ms, String name) =>
    buildBodyAreaHealthFromMetrics(ms).firstWhere((a) => a.name == name);

void main() {
  group('guessSystemForRawName', () {
    test('血常规分类项归血液，肝肾糖归对应系统，认不出归其他', () {
      expect(guessSystemForRawName('中性粒细胞百分比'), '血液');
      expect(guessSystemForRawName('网织红细胞比率'), '血液');
      expect(guessSystemForRawName('直接胆红素'), '肝脏');
      expect(guessSystemForRawName('尿素氮'), '肾脏');
      expect(guessSystemForRawName('餐后血糖'), '血糖代谢');
      expect(guessSystemForRawName('莫名其妙的项目'), '其他');
    });
  });

  group('非核心指标不驱动器官判定', () {
    test('UNKNOWN 项进 area.metrics 但 standardized=false，不影响 status', () {
      final ms = [
        _m('HGB', name: '血红蛋白', status: '正常', bodySystem: '血液'),
        _m('UNKNOWN',
            name: '中性粒细胞百分比', status: '偏高', bodySystem: '血液'),
      ];
      final blood = _area(ms, '血液系统');
      expect(blood.status, '正常'); // UNKNOWN 的「偏高」不算数
      expect(blood.abnormalCount, 0);
      final noncore =
          blood.metrics.firstWhere((m) => m.name == '中性粒细胞百分比');
      expect(noncore.standardized, isFalse);
      expect(blood.metrics.any((m) => m.name == '血红蛋白'), isTrue);
    });

    test('advisoryOnly 指标（肿瘤标志物）超范围不把器官判成需关注', () {
      final ms = [
        _m('CEA', name: '癌胚抗原', status: '偏高', bodySystem: '肿瘤标志物'),
      ];
      // CEA 归「其他」器官（bodyAreaForSystem('肿瘤标志物') == '其他'）
      final other = _area(ms, '其他');
      expect(other.status, '数据不足'); // advisory 不参与判定
      final chip = other.metrics.firstWhere((m) => m.name == '癌胚抗原');
      expect(chip.advisoryOnly, isTrue);
      expect(chip.counts, isFalse);
    });

    test('核心指标照常驱动判定', () {
      final ms = [
        _m('ALT', name: '丙氨酸氨基转移酶', status: '偏高', bodySystem: '肝脏'),
      ];
      final liver = _area(ms, '肝胆');
      expect(liver.status, '需关注');
      expect(liver.abnormalCount, 1);
    });
  });

  test('affectedBodyAreasForMetrics 不把只含 UNKNOWN/其他 的报告拽进「其他」', () {
    final ms = [
      _m('UNKNOWN', name: '莫名项目', status: '偏高', bodySystem: '其他'),
    ];
    expect(affectedBodyAreasForMetrics(ms), isEmpty);
    // 但 UNKNOWN 落到真实系统时算关联
    final ms2 = [
      _m('UNKNOWN', name: '网织红细胞比率', status: '偏高', bodySystem: '血液'),
    ];
    expect(affectedBodyAreasForMetrics(ms2), contains('血液系统'));
  });
}
