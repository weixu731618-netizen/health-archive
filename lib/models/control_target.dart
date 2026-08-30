/// 慢病升级 步骤3：控制目标 + 达标判定。
///
/// 与「参考范围」不同：参考范围回答「这个值在健康人群里正不正常」，
/// 控制目标回答「按你的病，这个值有没有管到位」。同一指标的目标会因病而不同
/// （例：LDL-C 普通血脂异常目标 <3.4，糖尿病 <2.6，冠心病 / 卒中 <1.8）。
///
/// 目标值取自常见临床指南的**一般**建议，仅用于自我回顾，
/// 个体目标以医生为准（每条都带 [basis] 说明）。
library;

import 'chronic_condition_dictionary.dart';

/// 血压目标用的特殊 key。
const String kBloodPressureTargetKey = 'daily:blood_pressure';

enum TargetStatus {
  /// 达标。
  met,

  /// 接近目标（略超，差一点）。
  nearMiss,

  /// 未达标。
  notMet,

  /// 没有可评估的数据。
  noData,
}

String targetStatusLabel(TargetStatus s) {
  switch (s) {
    case TargetStatus.met:
      return '达标';
    case TargetStatus.nearMiss:
      return '接近目标';
    case TargetStatus.notMet:
      return '未达标';
    case TargetStatus.noData:
      return '暂无数据';
  }
}

class ControlTarget {
  /// metricId（如 'HBA1C'）或 [kBloodPressureTargetKey]。
  final String key;
  final String label;
  final String unit;

  /// 单值指标的达标区间（含端点）；用不到的一侧为 null。
  final double? min;
  final double? max;

  /// 血压专用：收缩压 / 舒张压上限。
  final double? systolicMax;
  final double? diastolicMax;

  /// null = 通用目标；非 null = 该病种下更贴切（通常更严格）的目标。
  final String? conditionCode;

  /// 同一 [key] 有多条时，取 [tightness] 最大的（越大越严格 / 越贴切）。
  final int tightness;

  /// 目标依据的一句话说明（非诊断、非医嘱）。
  final String basis;

  const ControlTarget({
    required this.key,
    required this.label,
    required this.unit,
    this.min,
    this.max,
    this.systolicMax,
    this.diastolicMax,
    this.conditionCode,
    this.tightness = 1,
    this.basis = '',
  });

  bool get isBloodPressure => key == kBloodPressureTargetKey;

  /// 目标的人话描述，如「≤ 7.0%」「130/80 mmHg 以内」「4.4–7.0 mmol/L」。
  String get text {
    if (isBloodPressure) {
      return '${_fmt(systolicMax)}/${_fmt(diastolicMax)} $unit 以内';
    }
    if (min != null && max != null) return '${_fmt(min)}–${_fmt(max)} $unit';
    if (max != null) return '≤ ${_fmt(max)} $unit';
    if (min != null) return '≥ ${_fmt(min)} $unit';
    return '按医生建议';
  }
}

String _fmt(double? v) {
  if (v == null) return '—';
  return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

// ignore: constant_identifier_names
const List<ControlTarget> CONTROL_TARGET_DICTIONARY = [
  // ---------- 血糖 ----------
  ControlTarget(
    key: 'HBA1C',
    label: '糖化血红蛋白',
    unit: '%',
    max: 7.0,
    conditionCode: 'type2_diabetes',
    tightness: 1,
    basis: '多数成人 2 型糖尿病的常见目标；老年或合并症者可放宽，以医生为准。',
  ),
  ControlTarget(
    key: 'HBA1C',
    label: '糖化血红蛋白',
    unit: '%',
    max: 7.0,
    conditionCode: 'type1_diabetes',
    tightness: 1,
    basis: '成人 1 型糖尿病的常见目标，需个体化并防低血糖。',
  ),
  ControlTarget(
    key: 'HBA1C',
    label: '糖化血红蛋白',
    unit: '%',
    max: 6.0,
    conditionCode: 'prediabetes',
    tightness: 1,
    basis: '糖尿病前期以生活方式把糖化控制在正常范围为目标。',
  ),
  ControlTarget(
    key: 'FPG',
    label: '空腹血糖',
    unit: 'mmol/L',
    min: 4.4,
    max: 7.0,
    conditionCode: 'type2_diabetes',
    tightness: 1,
    basis: '成人糖尿病常见空腹血糖控制区间。',
  ),
  ControlTarget(
    key: 'FPG',
    label: '空腹血糖',
    unit: 'mmol/L',
    min: 4.4,
    max: 7.0,
    conditionCode: 'type1_diabetes',
    tightness: 1,
    basis: '成人糖尿病常见空腹血糖控制区间。',
  ),
  ControlTarget(
    key: 'FPG',
    label: '空腹血糖',
    unit: 'mmol/L',
    max: 6.1,
    conditionCode: 'prediabetes',
    tightness: 1,
    basis: '糖尿病前期以空腹血糖回到正常为目标。',
  ),

  // ---------- 血脂（LDL-C 按风险分层，越高危越严格）----------
  ControlTarget(
    key: 'LDLC',
    label: '低密度脂蛋白胆固醇',
    unit: 'mmol/L',
    max: 3.4,
    conditionCode: 'dyslipidemia',
    tightness: 1,
    basis: '低 / 中危人群的一般目标。',
  ),
  ControlTarget(
    key: 'LDLC',
    label: '低密度脂蛋白胆固醇',
    unit: 'mmol/L',
    max: 2.6,
    conditionCode: 'type2_diabetes',
    tightness: 2,
    basis: '糖尿病属高危，LDL-C 目标通常更低。',
  ),
  ControlTarget(
    key: 'LDLC',
    label: '低密度脂蛋白胆固醇',
    unit: 'mmol/L',
    max: 1.8,
    conditionCode: 'chd',
    tightness: 3,
    basis: '冠心病属极高危，LDL-C 目标通常 <1.8 且较基线下降 ≥50%。',
  ),
  ControlTarget(
    key: 'LDLC',
    label: '低密度脂蛋白胆固醇',
    unit: 'mmol/L',
    max: 1.8,
    conditionCode: 'stroke',
    tightness: 3,
    basis: '缺血性卒中 / TIA 二级预防的常见 LDL-C 目标。',
  ),
  ControlTarget(
    key: 'TG',
    label: '甘油三酯',
    unit: 'mmol/L',
    max: 1.7,
    conditionCode: 'dyslipidemia',
    tightness: 1,
    basis: '甘油三酯的一般理想水平。',
  ),

  // ---------- 尿酸 ----------
  ControlTarget(
    key: 'UA',
    label: '血尿酸',
    unit: 'μmol/L',
    max: 420,
    conditionCode: 'hyperuricemia',
    tightness: 1,
    basis: '无症状高尿酸血症的常见控制目标。',
  ),
  ControlTarget(
    key: 'UA',
    label: '血尿酸',
    unit: 'μmol/L',
    max: 360,
    conditionCode: 'gout',
    tightness: 2,
    basis: '痛风患者长期降尿酸目标通常 <360，有痛风石者更低。',
  ),

  // ---------- 血压（日常记录）----------
  ControlTarget(
    key: kBloodPressureTargetKey,
    label: '血压',
    unit: 'mmHg',
    systolicMax: 140,
    diastolicMax: 90,
    conditionCode: 'hypertension',
    tightness: 1,
    basis: '一般高血压的常见起始目标；能耐受可更低。',
  ),
  ControlTarget(
    key: kBloodPressureTargetKey,
    label: '血压',
    unit: 'mmHg',
    systolicMax: 130,
    diastolicMax: 80,
    conditionCode: 'type2_diabetes',
    tightness: 2,
    basis: '合并糖尿病时血压目标通常更严格。',
  ),
  ControlTarget(
    key: kBloodPressureTargetKey,
    label: '血压',
    unit: 'mmHg',
    systolicMax: 130,
    diastolicMax: 80,
    conditionCode: 'ckd',
    tightness: 2,
    basis: '合并慢性肾脏病（尤其有蛋白尿）时血压目标通常更严格。',
  ),
];

/// 按用户当前的一组慢病 code，解出「每个指标应当用哪个目标」。
/// 同一指标有多个适用目标时，取 [ControlTarget.tightness] 最大的一条。
Map<String, ControlTarget> resolveControlTargets(Iterable<String> conditionCodes) {
  final codes = conditionCodes.toSet();
  final out = <String, ControlTarget>{};
  for (final t in CONTROL_TARGET_DICTIONARY) {
    if (t.conditionCode != null && !codes.contains(t.conditionCode)) continue;
    final cur = out[t.key];
    if (cur == null || t.tightness > cur.tightness) out[t.key] = t;
  }
  return out;
}

/// 判断单值指标是否达标。[nearBandRatio] 为「接近目标」的容差（默认超出 8%）。
TargetStatus evaluateTarget(
  ControlTarget target, {
  double? value,
  double? systolic,
  double? diastolic,
  double nearBandRatio = 0.08,
}) {
  if (target.isBloodPressure) {
    if (systolic == null || diastolic == null) return TargetStatus.noData;
    final sMax = target.systolicMax;
    final dMax = target.diastolicMax;
    if (sMax == null || dMax == null) return TargetStatus.noData;
    final sysOk = systolic <= sMax;
    final diaOk = diastolic <= dMax;
    if (sysOk && diaOk) return TargetStatus.met;
    final sysNear = systolic <= sMax * (1 + nearBandRatio);
    final diaNear = diastolic <= dMax * (1 + nearBandRatio);
    if (sysNear && diaNear) return TargetStatus.nearMiss;
    return TargetStatus.notMet;
  }

  if (value == null) return TargetStatus.noData;
  final lo = target.min;
  final hi = target.max;
  final aboveHi = hi != null && value > hi;
  final belowLo = lo != null && value < lo;
  if (!aboveHi && !belowLo) return TargetStatus.met;
  if (aboveHi && value <= hi * (1 + nearBandRatio)) return TargetStatus.nearMiss;
  if (belowLo && value >= lo * (1 - nearBandRatio)) return TargetStatus.nearMiss;
  return TargetStatus.notMet;
}

/// 某慢病自身「预设指标」里，有目标可评的那些 key（供专页「控制情况」用）。
List<String> targetKeysForCondition(String conditionCode) {
  final def = findChronicCondition(conditionCode);
  if (def == null) return const [];
  final keys = <String>[];
  for (final t in CONTROL_TARGET_DICTIONARY) {
    if (t.conditionCode != conditionCode) continue;
    keys.add(t.key);
  }
  // 去重，保持出现顺序。
  return keys.toSet().toList();
}
