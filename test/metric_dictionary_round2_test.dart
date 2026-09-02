// Round 2：核心指标词典扩充 —— 新增项可匹配、无 id / 别名冲突、
// 血常规绝对值项补上了参考范围、百分比不被误当核心。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/metric_dictionary.dart';
import 'package:health_archive/models/body_area_health.dart';

void main() {
  group('Round 2 词典扩充', () {
    test('新增核心项都在字典里且能按别名匹配', () {
      const expected = {
        'GLB': ['球蛋白', 'GLB'],
        'IBIL': ['间接胆红素', 'I-BIL'],
        'TBA': ['总胆汁酸', 'TBA'],
        'CYSC': ['胱抑素C', 'CysC'],
        'CO2CP': ['二氧化碳结合力', 'TCO2'],
        'RPG': ['随机血糖', 'RBG'],
        'NONHDLC': ['非高密度脂蛋白胆固醇', 'non-HDL-C'],
        'CK': ['肌酸激酶', 'CPK'],
        'CKMB': ['肌酸激酶同工酶', 'CK-MB'],
        'CTNI': ['肌钙蛋白I', 'cTnI'],
        'TT3': ['总三碘甲状腺原氨酸', 'TT3'],
        'TT4': ['总甲状腺素', '总T4'],
        'PT': ['凝血酶原时间', 'PT'],
        'INR': ['国际标准化比值', 'INR'],
        'APTT': ['活化部分凝血活酶时间', 'aPTT'],
        'FIB': ['纤维蛋白原', 'Fibrinogen'],
        'DDIMER': ['D-二聚体', 'D-Dimer'],
        'SF': ['铁蛋白', 'Ferritin'],
        'VB12': ['维生素B12', 'B12'],
        'FOLATE': ['叶酸', 'Folate'],
        'TSAT': ['转铁蛋白饱和度', '铁饱和度'],
        'CRP': ['C反应蛋白', 'CRP'],
        'ESR': ['红细胞沉降率', '血沉'],
        'AMY': ['淀粉酶', 'Amylase'],
        'LIP': ['脂肪酶', 'Lipase'],
        'PTH': ['甲状旁腺激素', 'iPTH'],
        'CYFRA211': ['细胞角蛋白19片段', 'CYFRA21-1'],
        'NSE': ['神经元特异性烯醇化酶', 'NSE'],
        'SCC': ['鳞状细胞癌抗原', 'SCCA'],
        'CA724': ['糖类抗原72-4', 'CA72-4'],
      };
      for (final entry in expected.entries) {
        final def = findMetricDefinition(entry.key);
        expect(def, isNotNull, reason: '缺指标 ${entry.key}');
        for (final alias in entry.value) {
          expect(matchMetricId(alias), entry.key,
              reason: '别名 $alias 未匹配到 ${entry.key}');
        }
      }
    });

    test('metricId 全表唯一', () {
      final ids = METRIC_DICTIONARY.map((m) => m.metricId).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('别名归一化后不跨指标冲突', () {
      final seen = <String, String>{};
      for (final m in METRIC_DICTIONARY) {
        final keys = <String>{
          m.metricId,
          m.metricName,
          ...m.aliases,
        }.map((s) => s.toLowerCase().replaceAll(
            RegExp(r'[ \t()\-－—＿_／/]'), ''));
        for (final k in keys) {
          if (k.isEmpty) continue;
          final prev = seen[k];
          expect(prev == null || prev == m.metricId, isTrue,
              reason: '归一化键 "$k" 同时属于 $prev 和 ${m.metricId}');
          seen[k] = m.metricId;
        }
      }
    });

    test('血常规绝对值项补上了参考范围', () {
      for (final id in ['NEUT', 'LYMPH', 'MONO', 'EOS', 'BASO']) {
        final r = findMetricDefinition(id)!.typicalRange;
        expect(r.max, isNotNull, reason: '$id 缺上限');
      }
    });

    test('百分比不会被当成绝对值核心指标', () {
      expect(matchMetricId('中性粒细胞百分比'), isNull);
      expect(matchMetricId('淋巴细胞比率'), isNull);
    });

    test('凝血项归到血液系统', () {
      expect(bodyAreaForSystem(findMetricDefinition('PT')!.bodySystem),
          '血液系统');
    });

    test('肿瘤标志物 / 急性指标标了 advisoryOnly', () {
      for (final id in [
        'CEA', 'CA199', 'CA125', 'CA153', 'PSA', 'AFP',
        'NTPROBNP', 'CKMB', 'CTNI', 'DDIMER', 'CYFRA211', 'NSE', 'SCC', 'CA724',
      ]) {
        expect(findMetricDefinition(id)!.advisoryOnly, isTrue, reason: id);
      }
      // 普通指标不是 advisory
      expect(findMetricDefinition('ALT')!.advisoryOnly, isFalse);
      expect(findMetricDefinition('CRP')!.advisoryOnly, isFalse);
    });
  });
}
