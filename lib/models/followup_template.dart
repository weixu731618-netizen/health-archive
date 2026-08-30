/// 慢病升级 步骤4：随访计划模板。
///
/// 每个慢病一套「该多久查一次什么」的建议清单。用于自动排期复查提醒
/// （见 services/followup_scheduler.dart）。间隔取常见指南的一般建议，
/// 具体随访节奏以医生为准。
library;

/// 随访项。
class FollowUpItem {
  /// 稳定标识（同一模板内唯一），如 'hba1c' / 'fundus' / 'renal_panel'。
  final String key;

  /// 展示名，如「糖化血红蛋白」「眼底检查」。
  final String label;

  /// 建议间隔。
  final Duration interval;

  /// 关联的化验指标 id（有则以最近一次记录为排期锚点）。
  final List<String> metricIds;

  /// 关联的日常记录类型。
  final List<String> dailyTypes;

  /// 无数值的检查项（眼底 / 足部 / 超声 / 肺功能 / 骨密度）——
  /// App 里没有对应指标，只能按「上次完成 / 确诊日期」推算。
  final bool isExam;

  final String note;

  const FollowUpItem({
    required this.key,
    required this.label,
    required this.interval,
    this.metricIds = const [],
    this.dailyTypes = const [],
    this.isExam = false,
    this.note = '',
  });

  String get intervalText {
    final d = interval.inDays;
    if (d <= 45) return '每月';
    if (d <= 100) return '每 3 个月';
    if (d <= 200) return '每半年';
    if (d <= 400) return '每年';
    return '每 ${(d / 365).round()} 年';
  }
}

class FollowUpTemplate {
  final String conditionCode;
  final List<FollowUpItem> items;
  const FollowUpTemplate(this.conditionCode, this.items);
}

const _d90 = Duration(days: 90);
const _d180 = Duration(days: 180);
const _d365 = Duration(days: 365);
const _d730 = Duration(days: 730);

// ignore: constant_identifier_names
const List<FollowUpTemplate> FOLLOWUP_TEMPLATES = [
  FollowUpTemplate('type2_diabetes', [
    FollowUpItem(
        key: 'hba1c',
        label: '糖化血红蛋白',
        interval: _d90,
        metricIds: ['HBA1C'],
        note: '血糖达标且稳定后可延长到每半年。'),
    FollowUpItem(
        key: 'lipid',
        label: '血脂四项',
        interval: _d365,
        metricIds: ['TC', 'TG', 'LDLC', 'HDLC']),
    FollowUpItem(
        key: 'renal',
        label: '肝肾功能 + 尿白蛋白',
        interval: _d365,
        metricIds: ['CREA', 'EGFR', 'ALT', 'PRO-U']),
    FollowUpItem(
        key: 'fundus', label: '眼底检查', interval: _d365, isExam: true),
    FollowUpItem(key: 'foot', label: '足部检查', interval: _d365, isExam: true),
  ]),
  FollowUpTemplate('type1_diabetes', [
    FollowUpItem(
        key: 'hba1c',
        label: '糖化血红蛋白',
        interval: _d90,
        metricIds: ['HBA1C']),
    FollowUpItem(
        key: 'renal',
        label: '肝肾功能 + 尿白蛋白',
        interval: _d365,
        metricIds: ['CREA', 'EGFR', 'PRO-U']),
    FollowUpItem(
        key: 'fundus', label: '眼底检查', interval: _d365, isExam: true),
  ]),
  FollowUpTemplate('prediabetes', [
    FollowUpItem(
        key: 'glucose',
        label: '空腹血糖 + 糖化',
        interval: _d365,
        metricIds: ['FPG', 'HBA1C']),
  ]),
  FollowUpTemplate('hypertension', [
    FollowUpItem(
        key: 'bp_review',
        label: '回顾家庭血压',
        interval: _d90,
        dailyTypes: ['blood_pressure']),
    FollowUpItem(
        key: 'panel',
        label: '肝肾功能 / 电解质 / 血脂 / 血糖',
        interval: _d365,
        metricIds: ['CREA', 'EGFR', 'K', 'NA', 'LDLC', 'FPG']),
    FollowUpItem(key: 'ecg', label: '心电图', interval: _d365, isExam: true),
  ]),
  FollowUpTemplate('dyslipidemia', [
    FollowUpItem(
        key: 'lipid',
        label: '血脂四项',
        interval: _d180,
        metricIds: ['TC', 'TG', 'LDLC', 'HDLC'],
        note: '起始 / 调整用药后 6–12 周应复查一次。'),
    FollowUpItem(
        key: 'liver',
        label: '肝功能（他汀安全性）',
        interval: _d365,
        metricIds: ['ALT', 'AST']),
  ]),
  FollowUpTemplate('hyperuricemia', [
    FollowUpItem(
        key: 'ua',
        label: '血尿酸',
        interval: _d90,
        metricIds: ['UA'],
        note: '达标稳定后可延长到每半年。'),
    FollowUpItem(
        key: 'renal',
        label: '肝肾功能',
        interval: _d365,
        metricIds: ['CREA', 'EGFR', 'ALT']),
  ]),
  FollowUpTemplate('gout', [
    FollowUpItem(
        key: 'ua', label: '血尿酸', interval: _d90, metricIds: ['UA']),
    FollowUpItem(
        key: 'renal',
        label: '肝肾功能',
        interval: _d365,
        metricIds: ['CREA', 'EGFR', 'ALT']),
  ]),
  FollowUpTemplate('nafld', [
    FollowUpItem(
        key: 'liver',
        label: '肝功能',
        interval: _d180,
        metricIds: ['ALT', 'AST', 'GGT']),
    FollowUpItem(
        key: 'liver_us', label: '肝脏超声', interval: _d365, isExam: true),
  ]),
  FollowUpTemplate('ckd', [
    FollowUpItem(
        key: 'renal',
        label: '肌酐 / eGFR / 尿蛋白',
        interval: _d180,
        metricIds: ['CREA', 'EGFR', 'PRO-U'],
        note: '分期越晚复查越频，G4–G5 常每 1–3 个月。'),
    FollowUpItem(
        key: 'labs',
        label: '电解质 / 血红蛋白 / 钙磷',
        interval: _d180,
        metricIds: ['K', 'NA', 'HGB', 'CA', 'P']),
  ]),
  FollowUpTemplate('chd', [
    FollowUpItem(
        key: 'lipid',
        label: '血脂四项',
        interval: _d180,
        metricIds: ['TC', 'TG', 'LDLC', 'HDLC'],
        note: 'LDL-C 达标前建议每 3–6 个月复查。'),
    FollowUpItem(
        key: 'bp_glucose',
        label: '血压 / 血糖回顾',
        interval: _d180,
        dailyTypes: ['blood_pressure'],
        metricIds: ['FPG', 'HBA1C']),
  ]),
  FollowUpTemplate('stroke', [
    FollowUpItem(
        key: 'lipid',
        label: '血脂四项',
        interval: _d180,
        metricIds: ['TC', 'TG', 'LDLC', 'HDLC']),
    FollowUpItem(
        key: 'bp_review',
        label: '回顾血压',
        interval: _d90,
        dailyTypes: ['blood_pressure']),
  ]),
  FollowUpTemplate('copd', [
    FollowUpItem(
        key: 'spirometry', label: '肺功能', interval: _d365, isExam: true),
  ]),
  FollowUpTemplate('osteoporosis', [
    FollowUpItem(
        key: 'bmd', label: '骨密度', interval: _d730, isExam: true),
    FollowUpItem(
        key: 'ca_p', label: '血钙 / 磷', interval: _d365, metricIds: ['CA', 'P']),
  ]),
  FollowUpTemplate('hypothyroidism', [
    FollowUpItem(
        key: 'thyroid',
        label: '甲功',
        interval: _d180,
        metricIds: ['TSH', 'FT3', 'FT4'],
        note: '调整替代剂量期间应每 4–6 周复查。'),
  ]),
  FollowUpTemplate('hyperthyroidism', [
    FollowUpItem(
        key: 'thyroid',
        label: '甲功',
        interval: _d90,
        metricIds: ['TSH', 'FT3', 'FT4']),
    FollowUpItem(
        key: 'safety',
        label: '肝功能 / 血常规',
        interval: _d90,
        metricIds: ['ALT', 'AST', 'WBC', 'NEUT'],
        note: '抗甲状腺药可能影响肝功能与白细胞。'),
  ]),
  FollowUpTemplate('thyroid_nodule', [
    FollowUpItem(
        key: 'thyroid_us',
        label: '甲状腺超声',
        interval: _d365,
        isExam: true,
        note: '按 TI-RADS 分类，高分类间隔更短。'),
  ]),
  FollowUpTemplate('chronic_hepatitis_b', [
    FollowUpItem(
        key: 'liver',
        label: '肝功能',
        interval: _d180,
        metricIds: ['ALT', 'AST', 'TBIL', 'ALB']),
    FollowUpItem(
        key: 'hbv_us',
        label: 'HBV-DNA + 肝脏超声 + 甲胎蛋白',
        interval: _d180,
        isExam: true),
  ]),
  FollowUpTemplate('malignancy', [
    FollowUpItem(
        key: 'onco_review',
        label: '肿瘤科复查（影像 + 标志物）',
        interval: _d90,
        isExam: true,
        note: '具体项目与间隔以肿瘤科随访方案为准。'),
  ]),
];

FollowUpTemplate? followUpTemplateFor(String? conditionCode) {
  if (conditionCode == null) return null;
  for (final t in FOLLOWUP_TEMPLATES) {
    if (t.conditionCode == conditionCode) return t;
  }
  return null;
}
