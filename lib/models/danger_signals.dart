import '../data/app_database.dart';

/// 一条「建议尽快就医复核」的危险信号。不是诊断，只是把少数公认的危急值 /
/// 危险形态挑出来提醒。
class DangerSignal {
  final String metricName;
  final String valueText;
  final String message;

  const DangerSignal({
    required this.metricName,
    required this.valueText,
    required this.message,
  });
}

class _Rule {
  final List<String> any; // 名字需含其一
  final List<String> not; // 名字含其一则跳过
  final bool Function(double v) test;
  final String message;
  const _Rule(this.any, this.test, this.message, {this.not = const []});
}

// 危急值门槛按国内实验室常用单位与常见「危急值报告」清单取偏保守的一侧；
// 每条都带数量级下限，避免单位不一致（如 g/L ↔ g/dL）时误报。
final List<_Rule> _rules = [
  _Rule(['血红蛋白', 'hgb', 'hb', '血色素'], (v) => v >= 20 && v < 60,
      '血红蛋白重度偏低（重度贫血）'),
  _Rule(['血小板', 'plt'], (v) => v > 0 && v < 20, '血小板极低，出血风险高',
      not: ['压积', '分布', '平均', '大血小板', 'pct', 'pdw', 'mpv']),
  _Rule(['血小板', 'plt'], (v) => v >= 1000, '血小板极度增多',
      not: ['压积', '分布', '平均', '大血小板', 'pct', 'pdw', 'mpv']),
  _Rule(['白细胞', 'wbc'], (v) => v >= 30 && v < 1000, '白细胞极度增高',
      not: ['百分比', '比率', '酯酶', '尿']),
  _Rule(['白细胞', 'wbc'], (v) => v > 0 && v < 1.5, '白细胞极低，感染风险高',
      not: ['百分比', '比率', '酯酶', '尿']),
  _Rule(['中性粒细胞'], (v) => v >= 0 && v < 0.5, '中性粒细胞绝对值极低（粒细胞缺乏）',
      not: ['百分比', '比率']),
  _Rule([
    '原始细胞', '幼稚细胞', '原幼', '早幼粒', '中幼粒', '晚幼粒', '幼稚粒', '母细胞',
  ], (v) => v > 0, '外周血出现原始 / 幼稚细胞'),
  _Rule(['单克隆', 'm蛋白', 'm-蛋白', 'm条带', '单株'], (v) => v > 0,
      '检出单克隆蛋白条带'),
  _Rule(['嗜酸性粒细胞', 'eos'], (v) => v > 20 && v <= 100,
      '嗜酸性粒细胞百分比显著升高',
      not: ['绝对值', '计数', '#']),
  _Rule(['嗜酸性粒细胞', 'eos'], (v) => v > 1.5 && v <= 20,
      '嗜酸性粒细胞绝对值显著升高',
      not: ['百分比', '比率', '%']),
  _Rule(['钾', 'potassium', 'k+'], (v) => v > 6.0 && v < 20, '血钾过高（危急值）',
      not: ['尿', '碱']),
  _Rule(['钾', 'potassium', 'k+'], (v) => v > 0 && v < 2.8, '血钾过低（危急值）',
      not: ['尿', '碱']),
  _Rule(['钠', 'sodium', 'na+'], (v) => v >= 160 && v < 300, '血钠过高（危急值）',
      not: ['尿']),
  _Rule(['钠', 'sodium', 'na+'], (v) => v > 60 && v < 120, '血钠过低（危急值）',
      not: ['尿']),
  _Rule(['钙', 'calcium'], (v) => v >= 3.5 && v < 10, '血钙过高（高钙危象风险）',
      not: ['尿', '磷']),
  _Rule(['葡萄糖', '血糖', 'glucose'], (v) => v >= 22 && v < 200, '血糖极高',
      not: ['尿', '糖化', '化验']),
  _Rule(['葡萄糖', '血糖', 'glucose'], (v) => v > 0 && v < 2.8, '低血糖（危急值）',
      not: ['尿', '糖化']),
  _Rule(['肌酐', 'crea', 'creatinine'], (v) => v >= 442 && v < 5000,
      '血肌酐显著升高',
      not: ['尿', '清除率', '比']),
  _Rule(['inr', '国际标准化比值'], (v) => v >= 5.0 && v < 50,
      'INR 显著偏高，抗凝过度、出血风险'),
];

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// 从一批指标里挑出危险信号。同一指标最多出一条。不下诊断、不涉及影像。
List<DangerSignal> dangerSignalsForMetrics(Iterable<HealthMetric> metrics) {
  final out = <DangerSignal>[];
  final seen = <String>{};
  for (final m in metrics) {
    final name = m.metricName.toLowerCase();
    for (final r in _rules) {
      if (!r.any.any(name.contains)) continue;
      if (r.not.any(name.contains)) continue;
      if (!r.test(m.value)) continue;
      final key = '${m.metricName}|${r.message}';
      if (!seen.add(key)) continue;
      out.add(DangerSignal(
        metricName: m.metricName,
        valueText: '${_fmt(m.value)}${m.unit.isEmpty ? '' : ' ${m.unit}'}',
        message: r.message,
      ));
      break; // 一个指标命中一条即可
    }
  }
  return out;
}
