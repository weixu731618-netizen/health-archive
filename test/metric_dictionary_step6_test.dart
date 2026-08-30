// 慢病升级 步骤6：指标字典补齐 + 腰围日常项。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/chronic_condition_dictionary.dart';
import 'package:health_archive/models/metric_dictionary.dart';
import 'package:health_archive/pages/daily_health_entry_page.dart';

void main() {
  group('新增指标', () {
    test('关键慢病项都在字典里且能按别名匹配', () {
      const expected = {
        'UACR': ['尿白蛋白肌酐比', 'ACR', '白蛋白肌酐比值'],
        'GA': ['糖化白蛋白', 'GA'],
        'HSCRP': ['超敏C反应蛋白', 'hs-CRP'],
        'HCY': ['同型半胱氨酸', 'Hcy'],
        'LPA': ['脂蛋白(a)', 'Lp(a)'],
        'APOB': ['载脂蛋白B', 'ApoB'],
        'NTPROBNP': ['N末端B型钠尿肽前体', 'NT-proBNP'],
        'BMD_T': ['骨密度T值', 'T-score'],
        'TPOAB': ['甲状腺过氧化物酶抗体', 'TPOAb'],
        'HBVDNA': ['乙肝病毒DNA定量', 'HBV-DNA'],
        'AFP': ['甲胎蛋白', 'AFP'],
        'PSA': ['前列腺特异性抗原', 'PSA'],
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

    test('metricId 仍然全表唯一', () {
      final ids = METRIC_DICTIONARY.map((m) => m.metricId).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('糖尿病 / CKD / 冠心病关联到新指标', () {
      expect(findChronicCondition('type2_diabetes')!.relatedMetricIds,
          contains('UACR'));
      expect(findChronicCondition('ckd')!.relatedMetricIds, contains('UACR'));
      expect(findChronicCondition('chd')!.relatedMetricIds, contains('APOB'));
      // 这些指标必须能解析
      for (final id
          in findChronicCondition('chd')!.relatedMetricIds) {
        expect(findMetricDefinition(id), isNotNull);
      }
    });
  });

  group('腰围日常项', () {
    test('DailyEntryType 有 waist，dbType/单位正确', () {
      final waist = DailyEntryType.values
          .firstWhere((t) => t.dbType == 'waist');
      expect(waist.label, '腰围');
      expect(waist.defaultUnit, 'cm');
    });

    test('waist 在 kKnownDailyTypes 里，超重/肥胖/脂肪肝关联了它', () {
      expect(kKnownDailyTypes.contains('waist'), isTrue);
      expect(findChronicCondition('overweight')!.relatedDailyTypes,
          contains('waist'));
      expect(findChronicCondition('nafld')!.relatedDailyTypes,
          contains('waist'));
    });
  });
}
