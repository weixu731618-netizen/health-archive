// 慢病升级 步骤3：控制目标字典 + 解析 + 达标判定。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/models/chronic_condition_dictionary.dart';
import 'package:health_archive/models/control_target.dart';
import 'package:health_archive/models/metric_dictionary.dart';

void main() {
  group('目标字典完整性', () {
    test('每条目标的 key 要么是血压，要么能在指标字典里找到', () {
      for (final t in CONTROL_TARGET_DICTIONARY) {
        if (t.isBloodPressure) continue;
        expect(findMetricDefinition(t.key), isNotNull,
            reason: '目标 ${t.label} 的 key ${t.key} 不在指标字典');
      }
    });

    test('每条目标至少有一侧边界（血压则有收缩/舒张上限）', () {
      for (final t in CONTROL_TARGET_DICTIONARY) {
        if (t.isBloodPressure) {
          expect(t.systolicMax != null && t.diastolicMax != null, isTrue);
        } else {
          expect(t.min != null || t.max != null, isTrue,
              reason: '${t.label} 没有任何边界');
        }
      }
    });

    test('带 conditionCode 的目标，其病种在慢病字典里存在', () {
      for (final t in CONTROL_TARGET_DICTIONARY) {
        if (t.conditionCode == null) continue;
        expect(findChronicCondition(t.conditionCode), isNotNull,
            reason: '${t.label} 关联了不存在的病种 ${t.conditionCode}');
      }
    });
  });

  group('resolveControlTargets：取最严格', () {
    test('只有血脂异常 → LDL 目标 3.4', () {
      final m = resolveControlTargets({'dyslipidemia'});
      expect(m['LDLC']!.max, 3.4);
    });

    test('血脂异常 + 糖尿病 → LDL 目标收紧到 2.6', () {
      final m = resolveControlTargets({'dyslipidemia', 'type2_diabetes'});
      expect(m['LDLC']!.max, 2.6);
    });

    test('再加冠心病 → LDL 目标收紧到 1.8', () {
      final m =
          resolveControlTargets({'dyslipidemia', 'type2_diabetes', 'chd'});
      expect(m['LDLC']!.max, 1.8);
    });

    test('高血压 + 糖尿病 → 血压目标 130/80', () {
      final m = resolveControlTargets({'hypertension', 'type2_diabetes'});
      final bp = m[kBloodPressureTargetKey]!;
      expect(bp.systolicMax, 130);
      expect(bp.diastolicMax, 80);
    });

    test('没有相关病 → 不给该指标目标', () {
      final m = resolveControlTargets({'osteoporosis'});
      expect(m.containsKey('HBA1C'), isFalse);
    });
  });

  group('evaluateTarget：达标 / 接近 / 未达标', () {
    final hba1c = CONTROL_TARGET_DICTIONARY
        .firstWhere((t) => t.key == 'HBA1C' && t.conditionCode == 'type2_diabetes');

    test('单值：达标', () {
      expect(evaluateTarget(hba1c, value: 6.7), TargetStatus.met);
    });

    test('单值：略超 → 接近目标', () {
      // 7.0 * 1.08 = 7.56，7.3 落在接近区间
      expect(evaluateTarget(hba1c, value: 7.3), TargetStatus.nearMiss);
    });

    test('单值：明显超 → 未达标', () {
      expect(evaluateTarget(hba1c, value: 8.5), TargetStatus.notMet);
    });

    test('无数据 → noData', () {
      expect(evaluateTarget(hba1c), TargetStatus.noData);
    });

    final bp = CONTROL_TARGET_DICTIONARY.firstWhere(
        (t) => t.isBloodPressure && t.conditionCode == 'hypertension');

    test('血压：都达标', () {
      expect(evaluateTarget(bp, systolic: 128, diastolic: 78),
          TargetStatus.met);
    });

    test('血压：一项略超 → 接近目标', () {
      // 140*1.08=151.2, 90*1.08=97.2
      expect(evaluateTarget(bp, systolic: 146, diastolic: 88),
          TargetStatus.nearMiss);
    });

    test('血压：明显超 → 未达标', () {
      expect(evaluateTarget(bp, systolic: 165, diastolic: 100),
          TargetStatus.notMet);
    });

    test('血压：缺一个值 → noData', () {
      expect(evaluateTarget(bp, systolic: 120), TargetStatus.noData);
    });
  });

  test('targetKeysForCondition', () {
    expect(targetKeysForCondition('type2_diabetes'),
        containsAll(<String>['HBA1C', 'FPG', 'LDLC', kBloodPressureTargetKey]));
    expect(targetKeysForCondition('overweight'), isEmpty);
  });

  test('ControlTarget.text 人话描述', () {
    final ua = CONTROL_TARGET_DICTIONARY
        .firstWhere((t) => t.key == 'UA' && t.conditionCode == 'gout');
    expect(ua.text, '≤ 360 μmol/L');
    final bp = CONTROL_TARGET_DICTIONARY.firstWhere(
        (t) => t.isBloodPressure && t.conditionCode == 'hypertension');
    expect(bp.text, contains('140/90'));
  });
}
