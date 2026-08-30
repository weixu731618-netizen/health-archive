/// 慢性病病种字典。
///
/// 目标：把「疾病史」从一段自由文本，升级成可结构化管理的对象——
/// 标准病种名 + 稳定 code + 分级/分期选项 + 相关指标/日常项。
/// 这是「以疾病为中心」组织(慢病专页 / 达标判定 / 随访排期)的地基。
///
/// 只覆盖已定范围内的慢性病，不外扩；找不到的病仍可自由文本录入(conditionCode 留空)。
library;

import 'metric_dictionary.dart';

/// 病种大类。
enum ChronicCategory {
  /// 代谢一组：主管理对象。
  metabolic,

  /// 靶器官 / 并发：多为代谢失控的结局，偏随访 + 二级预防。
  targetOrgan,

  /// 其他常见慢病。
  other,
}

String chronicCategoryLabel(ChronicCategory c) {
  switch (c) {
    case ChronicCategory.metabolic:
      return '代谢相关';
    case ChronicCategory.targetOrgan:
      return '心脑血管 / 靶器官';
    case ChronicCategory.other:
      return '其他慢性病';
  }
}

/// 一条慢性病病种定义。
class ChronicConditionDef {
  /// 稳定英文标识，全表唯一，用于关联指标 / 用药 / 报告 / 随访模板。
  final String code;

  /// 中文标准名。
  final String name;

  final ChronicCategory category;

  /// 附加别名(不含标准名本身)。
  final List<String> aliases;

  /// 分级维度的名字，如「分级」「分期」「GOLD 分级」；无分级时为 null。
  final String? stagingLabel;

  /// 可选的分级 / 分期取值；空 = 不分级。
  final List<String> stages;

  /// 相关的检查指标(metric_dictionary 的 metricId)。
  final List<String> relatedMetricIds;

  /// 相关的日常记录类型(weight / blood_pressure / blood_glucose / heart_rate)。
  final List<String> relatedDailyTypes;

  /// 一句话管理要点(非诊断)。
  final String note;

  const ChronicConditionDef({
    required this.code,
    required this.name,
    required this.category,
    this.aliases = const [],
    this.stagingLabel,
    this.stages = const [],
    this.relatedMetricIds = const [],
    this.relatedDailyTypes = const [],
    this.note = '',
  });

  bool get hasStaging => stages.isNotEmpty;

  bool matches(String rawName) {
    final key = _norm(rawName);
    if (key.isEmpty) return false;
    if (_norm(code) == key) return true;
    if (_norm(name) == key) return true;
    for (final a in aliases) {
      if (_norm(a) == key) return true;
    }
    return false;
  }
}

String _norm(String s) {
  const remove = [' ', '\t', '(', ')', '（', '）', '-', '－', '—', '/', '／', '型'];
  var out = s.trim().toLowerCase();
  for (final ch in remove) {
    out = out.replaceAll(ch, '');
  }
  return out;
}

/// 日常记录已支持的类型(与 DailyEntryType 对齐)。
const Set<String> kKnownDailyTypes = {
  'weight',
  'waist',
  'blood_pressure',
  'blood_glucose',
  'heart_rate',
};

// ignore: constant_identifier_names
const List<ChronicConditionDef> CHRONIC_CONDITION_DICTIONARY = [
  // ===================== 代谢相关 =====================
  ChronicConditionDef(
    code: 'hypertension',
    name: '高血压',
    category: ChronicCategory.metabolic,
    aliases: ['原发性高血压', 'HTN', '高血压病'],
    stagingLabel: '分级',
    stages: ['1 级', '2 级', '3 级', '单纯收缩期高血压'],
    relatedMetricIds: ['CREA', 'EGFR', 'K', 'NA'],
    relatedDailyTypes: ['blood_pressure', 'heart_rate'],
    note: '重点看家庭血压达标与波动，定期查肝肾功能、电解质。',
  ),
  ChronicConditionDef(
    code: 'type2_diabetes',
    name: '2型糖尿病',
    category: ChronicCategory.metabolic,
    aliases: ['2 型糖尿病', 'T2DM', '糖尿病', '成人型糖尿病'],
    stagingLabel: '并发症情况',
    stages: ['无并发症', '合并微血管并发症', '合并大血管并发症', '合并多种并发症'],
    relatedMetricIds: ['HBA1C', 'FPG', 'GA', 'UACR', 'INS', 'CPEP'],
    relatedDailyTypes: ['blood_glucose', 'weight'],
    note: '每 3 个月看糖化，每年查眼底、尿白蛋白肌酐比、足部。',
  ),
  ChronicConditionDef(
    code: 'type1_diabetes',
    name: '1型糖尿病',
    category: ChronicCategory.metabolic,
    aliases: ['1 型糖尿病', 'T1DM', '胰岛素依赖型糖尿病'],
    stagingLabel: '并发症情况',
    stages: ['无并发症', '合并微血管并发症', '合并大血管并发症'],
    relatedMetricIds: ['HBA1C', 'FPG', 'CPEP'],
    relatedDailyTypes: ['blood_glucose', 'weight'],
    note: '关注血糖波动与低血糖，糖化目标个体化。',
  ),
  ChronicConditionDef(
    code: 'prediabetes',
    name: '糖尿病前期',
    category: ChronicCategory.metabolic,
    aliases: ['糖调节受损', 'IGT', 'IFG', '空腹血糖受损', '糖耐量减低'],
    stagingLabel: '类型',
    stages: ['空腹血糖受损', '糖耐量减低', '两者兼有'],
    relatedMetricIds: ['HBA1C', 'FPG'],
    relatedDailyTypes: ['blood_glucose', 'weight'],
    note: '以生活方式干预为主，每年复查血糖、糖化。',
  ),
  ChronicConditionDef(
    code: 'dyslipidemia',
    name: '血脂异常',
    category: ChronicCategory.metabolic,
    aliases: ['高脂血症', '高血脂', '血脂紊乱'],
    stagingLabel: '类型',
    stages: ['高胆固醇型', '高甘油三酯型', '混合型', '低高密度脂蛋白型'],
    relatedMetricIds: ['TC', 'TG', 'LDLC', 'HDLC'],
    note: 'LDL-C 目标随心血管风险分层不同，需按危险因素设定。',
  ),
  ChronicConditionDef(
    code: 'hyperuricemia',
    name: '高尿酸血症',
    category: ChronicCategory.metabolic,
    aliases: ['血尿酸升高', 'HUA'],
    relatedMetricIds: ['UA', 'CREA', 'EGFR'],
    note: '关注血尿酸达标与肾功能，低嘌呤饮食、多饮水。',
  ),
  ChronicConditionDef(
    code: 'gout',
    name: '痛风',
    category: ChronicCategory.metabolic,
    aliases: ['痛风性关节炎'],
    stagingLabel: '分期',
    stages: ['急性发作期', '间歇期', '慢性痛风石期'],
    relatedMetricIds: ['UA', 'CREA', 'EGFR'],
    note: '长期降尿酸达标是关键，血尿酸目标通常 < 360 μmol/L。',
  ),
  ChronicConditionDef(
    code: 'nafld',
    name: '非酒精性脂肪性肝病',
    category: ChronicCategory.metabolic,
    aliases: ['脂肪肝', '非酒精性脂肪肝', '代谢相关脂肪性肝病', 'NAFLD', 'MAFLD'],
    stagingLabel: '分期',
    stages: ['单纯性脂肪肝', '脂肪性肝炎', '肝纤维化', '肝硬化'],
    relatedMetricIds: ['ALT', 'AST', 'GGT', 'TG'],
    relatedDailyTypes: ['weight', 'waist'],
    note: '以减重和控制代谢指标为主，定期查肝功能、肝脏超声。',
  ),
  ChronicConditionDef(
    code: 'overweight',
    name: '超重',
    category: ChronicCategory.metabolic,
    relatedDailyTypes: ['weight', 'waist'],
    note: '关注体重、腰围趋势与代谢指标。',
  ),
  ChronicConditionDef(
    code: 'obesity',
    name: '肥胖',
    category: ChronicCategory.metabolic,
    stagingLabel: '程度',
    stages: ['1 度', '2 度', '3 度'],
    relatedDailyTypes: ['weight', 'waist'],
    note: '关注体重、腰围趋势与代谢指标。',
  ),
  ChronicConditionDef(
    code: 'metabolic_syndrome',
    name: '代谢综合征',
    category: ChronicCategory.metabolic,
    aliases: ['MS', 'X 综合征'],
    relatedMetricIds: ['FPG', 'HBA1C', 'TG', 'HDLC', 'UA'],
    relatedDailyTypes: ['blood_pressure', 'weight'],
    note: '腹型肥胖 + 血糖 / 血脂 / 血压异常的组合，整体管理。',
  ),

  // ===================== 心脑血管 / 靶器官 =====================
  ChronicConditionDef(
    code: 'ckd',
    name: '慢性肾脏病',
    category: ChronicCategory.targetOrgan,
    aliases: ['慢性肾病', 'CKD', '慢性肾功能不全'],
    stagingLabel: '分期',
    stages: ['G1 期', 'G2 期', 'G3a 期', 'G3b 期', 'G4 期', 'G5 期'],
    relatedMetricIds: ['CREA', 'EGFR', 'BUN', 'UACR', 'PRO-U', 'K', 'CA', 'P', 'HGB'],
    relatedDailyTypes: ['blood_pressure'],
    note: '按 eGFR 分期，关注血压、尿蛋白、电解质与贫血。',
  ),
  ChronicConditionDef(
    code: 'chd',
    name: '冠心病',
    category: ChronicCategory.targetOrgan,
    aliases: ['冠状动脉粥样硬化性心脏病', 'CHD', '冠状动脉疾病'],
    stagingLabel: '类型',
    stages: ['稳定型心绞痛', '不稳定型心绞痛', '陈旧性心肌梗死', 'PCI 术后', 'CABG 术后'],
    relatedMetricIds: ['LDLC', 'TC', 'TG', 'APOB', 'LPA', 'HSCRP'],
    relatedDailyTypes: ['blood_pressure', 'heart_rate'],
    note: '二级预防用药坚持 + 危险因素达标；胸痛加重及时就医。',
  ),
  ChronicConditionDef(
    code: 'heart_failure',
    name: '心力衰竭',
    category: ChronicCategory.targetOrgan,
    aliases: ['慢性心衰', 'CHF', '心功能不全'],
    stagingLabel: 'NYHA 分级',
    stages: ['I 级', 'II 级', 'III 级', 'IV 级'],
    relatedMetricIds: ['NTPROBNP', 'K', 'CREA', 'EGFR'],
    relatedDailyTypes: ['weight', 'blood_pressure', 'heart_rate'],
    note: '每日称体重看液体潴留，关注气促、水肿变化。',
  ),
  ChronicConditionDef(
    code: 'atrial_fibrillation',
    name: '心房颤动',
    category: ChronicCategory.targetOrgan,
    aliases: ['房颤', 'AF', 'AFib'],
    stagingLabel: '类型',
    stages: ['阵发性', '持续性', '长期持续性', '永久性'],
    relatedDailyTypes: ['heart_rate', 'blood_pressure'],
    note: '关注心率控制与抗凝(如在用)，定期评估卒中风险。',
  ),
  ChronicConditionDef(
    code: 'stroke',
    name: '脑卒中',
    category: ChronicCategory.targetOrgan,
    aliases: ['中风', '脑梗死', '脑出血', '脑血管意外', 'TIA', '短暂性脑缺血发作'],
    stagingLabel: '类型',
    stages: ['缺血性', '出血性', '短暂性脑缺血发作(TIA)'],
    relatedMetricIds: ['LDLC', 'HBA1C'],
    relatedDailyTypes: ['blood_pressure'],
    note: '二级预防(抗栓 / 降脂 / 控压 / 控糖)为主，识别复发预警症状。',
  ),
  ChronicConditionDef(
    code: 'copd',
    name: '慢性阻塞性肺疾病',
    category: ChronicCategory.targetOrgan,
    aliases: ['慢阻肺', 'COPD', '慢性阻塞性肺病'],
    stagingLabel: 'GOLD 分级',
    stages: ['GOLD 1 级', 'GOLD 2 级', 'GOLD 3 级', 'GOLD 4 级'],
    note: '关注急性加重次数、咳喘变化，规律吸入用药、戒烟。',
  ),
  ChronicConditionDef(
    code: 'osteoporosis',
    name: '骨质疏松',
    category: ChronicCategory.targetOrgan,
    aliases: ['骨质疏松症', 'OP'],
    stagingLabel: '程度',
    stages: ['骨量减少', '骨质疏松', '严重骨质疏松'],
    relatedMetricIds: ['BMD_T', 'VITD', 'CA', 'P', 'ALP'],
    note: '按骨密度 T 值判定，关注钙磷、维生素 D 与跌倒风险。',
  ),

  // ===================== 其他慢性病 =====================
  ChronicConditionDef(
    code: 'hypothyroidism',
    name: '甲状腺功能减退',
    category: ChronicCategory.other,
    aliases: ['甲减', '甲状腺功能低下', '桥本甲状腺炎'],
    stagingLabel: '程度',
    stages: ['亚临床', '临床'],
    relatedMetricIds: ['TSH', 'FT3', 'FT4', 'TPOAB', 'TGAB'],
    note: '按 TSH 调整替代剂量，定期复查甲功。',
  ),
  ChronicConditionDef(
    code: 'hyperthyroidism',
    name: '甲状腺功能亢进',
    category: ChronicCategory.other,
    aliases: ['甲亢', '毒性弥漫性甲状腺肿', 'Graves 病'],
    stagingLabel: '程度',
    stages: ['亚临床', '临床'],
    relatedMetricIds: ['TSH', 'FT3', 'FT4'],
    note: '关注甲功与肝功能、血常规(抗甲状腺药副作用)。',
  ),
  ChronicConditionDef(
    code: 'thyroid_nodule',
    name: '甲状腺结节',
    category: ChronicCategory.other,
    stagingLabel: 'TI-RADS 分类',
    stages: ['3 类', '4 类', '5 类', '术后'],
    relatedMetricIds: ['TSH'],
    note: '按超声分类定随访间隔，多数良性、定期复查即可。',
  ),
  ChronicConditionDef(
    code: 'chronic_hepatitis_b',
    name: '慢性乙型肝炎',
    category: ChronicCategory.other,
    aliases: ['慢性乙肝', '乙肝', 'CHB', '乙型肝炎病毒携带'],
    stagingLabel: '分期',
    stages: ['免疫耐受期', '免疫清除期', '低(非)复制期', '再活动期', '肝硬化'],
    relatedMetricIds: ['ALT', 'AST', 'TBIL', 'ALB', 'HBVDNA', 'AFP'],
    note: '定期查肝功能、乙肝病毒载量、肝脏超声与甲胎蛋白。',
  ),
  ChronicConditionDef(
    code: 'chronic_gastritis',
    name: '慢性胃炎',
    category: ChronicCategory.other,
    aliases: ['萎缩性胃炎', '非萎缩性胃炎'],
    stagingLabel: '类型',
    stages: ['非萎缩性', '萎缩性', '伴肠化生', '伴异型增生'],
    note: '按胃镜与病理随访，萎缩 / 肠化需定期复查胃镜。',
  ),
  ChronicConditionDef(
    code: 'peptic_ulcer',
    name: '消化性溃疡',
    category: ChronicCategory.other,
    aliases: ['胃溃疡', '十二指肠溃疡'],
    stagingLabel: '类型',
    stages: ['胃溃疡', '十二指肠溃疡', '复合性溃疡'],
    note: '规范疗程 + 根除幽门螺杆菌(如阳性)，复查愈合情况。',
  ),
  ChronicConditionDef(
    code: 'hp_infection',
    name: '幽门螺杆菌感染',
    category: ChronicCategory.other,
    aliases: ['幽门螺旋杆菌感染', 'HP 感染', 'Hp 阳性'],
    note: '按方案根除后 4–8 周复查(呼气试验)确认。',
  ),
  ChronicConditionDef(
    code: 'depression',
    name: '抑郁症',
    category: ChronicCategory.other,
    aliases: ['抑郁障碍', '抑郁'],
    stagingLabel: '程度',
    stages: ['轻度', '中度', '重度'],
    note: '按医嘱规律用药与随访，关注情绪与睡眠变化，勿自行停药。',
  ),
  ChronicConditionDef(
    code: 'anxiety_disorder',
    name: '焦虑障碍',
    category: ChronicCategory.other,
    aliases: ['焦虑症', '广泛性焦虑'],
    stagingLabel: '程度',
    stages: ['轻度', '中度', '重度'],
    note: '按医嘱用药与心理干预，关注症状与功能影响。',
  ),
  ChronicConditionDef(
    code: 'malignancy',
    name: '恶性肿瘤',
    category: ChronicCategory.other,
    aliases: ['癌症', '肿瘤', '癌'],
    stagingLabel: '分期',
    stages: ['I 期', 'II 期', 'III 期', 'IV 期', '术后随访', '缓解 / 无病生存'],
    note: '按肿瘤科随访计划复查影像与肿瘤标志物。',
  ),
];

/// 按 code 精确查找。
ChronicConditionDef? findChronicCondition(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final c in CHRONIC_CONDITION_DICTIONARY) {
    if (c.code == code) return c;
  }
  return null;
}

/// 按原始名称 / 别名匹配病种；找不到返回 null(仍可自由文本录入)。
ChronicConditionDef? matchChronicCondition(String rawName) {
  for (final c in CHRONIC_CONDITION_DICTIONARY) {
    if (c.matches(rawName)) return c;
  }
  return null;
}

/// 某大类下的病种(按字典内顺序)。
List<ChronicConditionDef> chronicConditionsByCategory(ChronicCategory category) =>
    [for (final c in CHRONIC_CONDITION_DICTIONARY) if (c.category == category) c];

/// 病种关联的、在指标字典里真实存在的指标定义。
List<MetricDefinition> metricsForCondition(String code) {
  final def = findChronicCondition(code);
  if (def == null) return const [];
  return [
    for (final id in def.relatedMetricIds)
      if (findMetricDefinition(id) case final m?) m,
  ];
}
