/// 标准健康指标字典（V0.4D 扩充）。
///
/// 目标：同一个医学指标，无论医院怎么叫（cname / 缩写 / 别名），
/// 都尽量归到同一个 `metricId` 与 `canonicalName`，以便形成统一历史曲线。
/// 新增指标只需在此追加一条，不用改多个页面。
library;

/// 参考范围（min/max 均为可空；只有一侧也给判断）
class ReferenceRange {
  final double? min;
  final double? max;

  const ReferenceRange({this.min, this.max});
}

/// 一条标准指标定义
class MetricDefinition {
  final String metricId; // 例如 HBA1C
  final String metricName; // canonicalName，例如 糖化血红蛋白
  final String unit; // 例如 %
  final String bodySystem; // 例如 血糖代谢
  final ReferenceRange typicalRange; // 常见参考范围
  final List<String> aliases; // 附加别名（不含 canonicalName）

  /// 仅提示、不报警：肿瘤标志物 / 急性指标（cTnI、D-二聚体、CK-MB、NT-proBNP 等）。
  /// 超范围时器官详情页照常显示，但不进首页「需关注」红点、不自动生成复查提醒；
  /// 措辞用「建议结合临床复查」。
  final bool advisoryOnly;

  const MetricDefinition({
    required this.metricId,
    required this.metricName,
    required this.unit,
    required this.bodySystem,
    this.typicalRange = const ReferenceRange(),
    this.aliases = const [],
    this.advisoryOnly = false,
  });

  /// 是否与原始名称匹配（用于本地匹配）。
  /// 顺序：标准 id / canonicalName / 别名，均做忽略大小写 + 去空白、横杠、括号的标准化。
  bool matches(String rawName) {
    final key = _norm(rawName);
    if (_norm(metricId) == key) return true;
    if (_norm(metricName) == key) return true;
    for (final a in aliases) {
      if (_norm(a) == key) return true;
    }
    return false;
  }
}

String _norm(String s) {
  const remove = [' ', '\t', '(', ')', '-', '－', '—', '＿', '＿', '_', '／', '/'];
  var out = s.trim().toLowerCase();
  for (final ch in remove) {
    out = out.replaceAll(ch, '');
  }
  return out;
}

/// 按原始名称精确/别名匹配标准指标；找不到返回 null。
MetricDefinition? matchMetric(String rawName) {
  final key = _norm(rawName);
  if (key.isEmpty) return null;
  for (final m in METRIC_DICTIONARY) {
    if (m.matches(rawName)) return m;
  }
  // 兜底：纯 metricId 匹配
  return null;
}

/// 历史兼容：返回 metricId（未匹配返回 null）
String? matchMetricId(String rawName) {
  final def = matchMetric(rawName);
  return def?.metricId;
}

/// 根据指标 id 返回字典定义；找不到时返回 null
MetricDefinition? findMetricDefinition(String metricId) {
  for (final m in METRIC_DICTIONARY) {
    if (m.metricId == metricId) return m;
  }
  return null;
}

/// 推导指标所属身体系统
String bodySystemForMetric(String? metricId, {String fallback = '其他'}) {
  if (metricId != null) {
    final def = findMetricDefinition(metricId);
    if (def != null) return def.bodySystem;
  }
  return fallback;
}

/// 未匹配核心词典的指标：按原始名里的关键词粗猜身体系统，让它在器官详情页
/// 至少归到对的「其他指标」区（而不是一律堆进「其他」）。猜不出返回 '其他'。
/// 返回值是 `bodySystem` 级别的字符串，仍要过 [bodyAreaForSystem] 才是一级器官。
String guessSystemForRawName(String rawName) {
  final n = rawName.toLowerCase();
  bool has(List<String> ks) => ks.any(n.contains);
  if (has([
    '红细胞', '白细胞', '血小板', '血红蛋白', '中性粒', '淋巴细胞', '单核细胞',
    '嗜酸', '嗜碱', '网织红', '血细胞', '红细胞压积', '红细胞比容', 'rbc', 'wbc',
    'plt', 'hgb', 'hct', 'mcv', 'mch', 'rdw', 'mpv', 'pdw', '粒细胞', '铁蛋白',
    '凝血', 'aptt', 'inr', '纤维蛋白', '二聚体', '血沉', '沉降率',
  ])) {
    return '血液';
  }
  if (has([
    '转氨酶', '胆红素', '胆汁酸', '白蛋白', '球蛋白', 'alt', 'ast', 'ggt',
    'γ-gt', '碱性磷酸酶', 'alp', '总蛋白', '谷丙', '谷草',
  ])) {
    return '肝脏';
  }
  if (has([
    '肌酐', '尿素', '尿酸', 'egfr', '滤过率', '胱抑素', '微量白蛋白', '尿蛋白',
    '钾', '钠', '氯', '钙', '磷', '镁', '二氧化碳结合力',
  ])) {
    return '肾脏';
  }
  if (has([
    '葡萄糖', '血糖', '糖化', '胰岛素', 'c肽', '果糖胺', 'hba1c',
  ])) {
    return '血糖代谢';
  }
  if (has([
    '胆固醇', '甘油三酯', '高密度', '低密度', '载脂蛋白', 'ldl', 'hdl',
    '同型半胱氨酸', '脂蛋白', '肌钙蛋白', '肌酸激酶', 'bnp',
  ])) {
    return '心血管';
  }
  if (has(['甲状腺', 'tsh', 'ft3', 'ft4', '促甲状腺'])) return '甲状腺';
  if (has(['淀粉酶', '脂肪酶'])) return '胰腺';
  if (has(['尿', '比重', '酸碱度', '亚硝酸盐', '尿胆原', '酮体'])) return '尿常规';
  return '其他';
}

/// 基础单位标准化（只显示格式统一，不做数值换算）。
/// 例：umol/L、µmol/L、μmol/L → μmol/L；10^9/L、×10^9/L、10⁹/L → ×10⁹/L
String normalizeUnit(String unit) {
  var u = unit.trim();
  final lower = u.toLowerCase();
  if (lower == 'umol/l' || lower == 'umol ') return 'μmol/L';
  if (lower.contains('umol') &&
      (lower.contains('/l') || lower.endsWith('umol'))) {
    return 'μmol/L';
  }
  if (u == 'µmol/l' || u == 'μmol/l' || u == 'umol/L') return 'μmol/L';
  if (u.contains('/l') && u.contains('µmol')) return 'μmol/L';
  if (u.contains('/l') && u.contains('μmol')) return 'μmol/L';
  if (lower.contains('10^9') ||
      lower.contains('×10^9') ||
      lower.contains('x10^9') ||
      lower.contains('10⁹')) {
    return '×10⁹/L';
  }
  return u;
}

/// 根据数值与参考范围计算状态（本地方判定，不信任模型）。
String computeStatus(double? value, ReferenceRange? range) {
  if (value == null || range == null) return '未判断';
  final min = range.min;
  final max = range.max;

  if (min != null && max == null) {
    if (value < min) return '偏低';
    return '正常';
  }
  if (max != null && min == null) {
    if (value > max) return '偏高';
    return '正常';
  }
  if (min != null && max != null) {
    if (value > max) return '偏高';
    if (value < min) return '偏低';
    return '正常';
  }
  return '未判断';
}

/// 定性结果（阴性 / 阳性 / +/- / 微量…）判定状态。
/// 化验单的尿常规试纸项、部分免疫项没有数值,只有定性结果,[computeStatus]
/// 会一律返回「未判断」——这里补一层文字判定。判不了返回 null(保持未判断)。
///
/// [textValue] 是识别到的结果文字;[referenceText] 是参考区间文字(常写「阴性」)。
String? computeQualitativeStatus(String? textValue, {String referenceText = ''}) {
  final t = (textValue ?? '').trim().toLowerCase().replaceAll(' ', '');
  if (t.isEmpty) return null;

  // 明确阳性 / 异常侧(含弱阳性、微量;'+'～'++++')
  const positiveExact = ['+', '++', '+++', '++++', '(+)', '（+）', '+-', '±'];
  const positiveContains = [
    '阳性', '弱阳', '可疑', '微量', 'trace', 'positive', 'abnormal', '检出'
  ];
  // 明确阴性 / 正常侧
  const negativeExact = ['-', '(-)', '（-）', '0'];
  const negativeContains = ['阴性', '正常', 'negative', '未见', '未检出', 'normal'];

  bool eq(List<String> list) => list.contains(t);
  bool has(List<String> list) => list.any((k) => t.contains(k));

  if (eq(positiveExact) || has(positiveContains)) return '需关注';
  if (eq(negativeExact) || has(negativeContains)) return '正常';
  return null;
}

/// 首批标准指标字典（目标 50~100 个；可继续追加）。
// ignore: constant_identifier_names
const List<MetricDefinition> METRIC_DICTIONARY = [
  // ===================== 血糖代谢 =====================
  MetricDefinition(
    metricId: 'HBA1C',
    metricName: '糖化血红蛋白',
    unit: '%',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(min: 4.0, max: 6.0),
    aliases: [
      'HbA1c', 'HbA1C', '糖化血红蛋白A1c', 'GHb', '糖化血红蛋白A1C',
      // OCR 常把 "1" 误读成小写 "l" 或大写 "I"，补充别名兜底
      'HbAlc', 'HbAIc', '糖化血红蛋白Alc', '糖化血红蛋白AIc',
    ],
  ),
  MetricDefinition(
    metricId: 'FPG',
    metricName: '空腹血糖',
    unit: 'mmol/L',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(min: 3.9, max: 6.1),
    aliases: ['空腹葡萄糖', 'FPG', 'FBG', 'Glucose Fasting', '空腹血糖值'],
  ),
  MetricDefinition(
    metricId: 'UA',
    metricName: '尿酸',
    unit: 'μmol/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 210, max: 420),
    aliases: ['血尿酸', 'UA', 'Uric Acid', 'SUA'],
  ),
  // ===================== 肾脏 =====================
  MetricDefinition(
    metricId: 'CREA',
    metricName: '肌酐',
    unit: 'μmol/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 57, max: 97),
    aliases: ['血清肌酐', 'Cr', 'CREA', 'Creatinine', 'SCr', '肌酐值'],
  ),
  MetricDefinition(
    metricId: 'EGFR',
    metricName: '估算肾小球滤过率',
    unit: 'mL/min/1.73m²',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 90, max: null),
    aliases: ['eGFR', 'EGFR', '肾小球滤过率', '肾小球滤过率估算值', 'GFR'],
  ),
  MetricDefinition(
    metricId: 'BUN',
    metricName: '尿素氮',
    unit: 'mmol/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 3.1, max: 8),
    aliases: ['BUN', '血尿素氮', '尿素'],
  ),
  // ===================== 肝脏 =====================
  MetricDefinition(
    metricId: 'ALT',
    metricName: '丙氨酸氨基转移酶',
    unit: 'U/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 9, max: 50),
    aliases: ['ALT', 'GPT', '谷丙转氨酶', '丙氨酸转氨酶'],
  ),
  MetricDefinition(
    metricId: 'AST',
    metricName: '天门冬氨酸氨基转移酶',
    unit: 'U/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 8, max: 40),
    aliases: ['AST', 'GOT', '谷草转氨酶', '天门冬氨酸氨基转移酶'],
  ),
  MetricDefinition(
    metricId: 'GGT',
    metricName: 'γ-谷氨酰转移酶',
    unit: 'U/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 10, max: 60),
    aliases: ['GGT', 'γ-GT', '谷氨酰转肽酶', 'γ-谷氨酰基转移酶', 'γ谷氨酰转移酶'],
  ),
  MetricDefinition(
    metricId: 'ALP',
    metricName: '碱性磷酸酶',
    unit: 'U/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 45, max: 125),
    aliases: ['ALP', '碱性磷酸酶', 'Alkaline Phosphatase'],
  ),
  MetricDefinition(
    metricId: 'TBIL',
    metricName: '总胆红素',
    unit: 'μmol/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 5, max: 21),
    aliases: ['TBIL', '总胆红素', 'T-BIL', 'Total Bilirubin'],
  ),
  MetricDefinition(
    metricId: 'DBIL',
    metricName: '直接胆红素',
    unit: 'μmol/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 0, max: 7),
    aliases: ['DBIL', '直接胆红素', 'D-BIL', 'Direct Bilirubin'],
  ),
  MetricDefinition(
    metricId: 'TP',
    metricName: '总蛋白',
    unit: 'g/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 65, max: 85),
    aliases: ['TP', '总蛋白', 'Total Protein'],
  ),
  MetricDefinition(
    metricId: 'ALB',
    metricName: '白蛋白',
    unit: 'g/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 40, max: 55),
    aliases: ['ALB', '白蛋白', 'Albumin'],
  ),
  // ===================== 血脂 / 心血管 =====================
  MetricDefinition(
    metricId: 'LDLC',
    metricName: '低密度脂蛋白胆固醇',
    unit: 'mmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 0, max: 3.4),
    aliases: ['LDL-C', 'LDLC', '低密度脂蛋白', 'LDL胆固醇', 'Low Density Lipoprotein'],
  ),
  MetricDefinition(
    metricId: 'HDLC',
    metricName: '高密度脂蛋白胆固醇',
    unit: 'mmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 1.0, max: 1.6),
    aliases: ['HDL-C', 'HDLC', '高密度脂蛋白', 'HDL胆固醇', 'High Density Lipoprotein'],
  ),
  MetricDefinition(
    metricId: 'TG',
    metricName: '甘油三酯',
    unit: 'mmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 0, max: 1.7),
    aliases: ['TG', '三酰甘油', 'Triglycerides'],
  ),
  MetricDefinition(
    metricId: 'TC',
    metricName: '总胆固醇',
    unit: 'mmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 0, max: 5.2),
    aliases: ['TC', 'Cholesterol', 'Total Cholesterol'],
  ),
  // ===================== 血液（血常规）=====================
  MetricDefinition(
    metricId: 'WBC',
    metricName: '白细胞计数',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 4, max: 10),
    aliases: ['WBC', '白细胞', '白细胞总数', 'White Blood Cell'],
  ),
  // 血红蛋白 / 红细胞 / 压积的参考范围男女差别大。报告基本都印了随患者性别的
  // 范围，优先用那个；这里的典型范围只在报告完全没印范围时兜底，故取「男女合并」
  // 的宽区间，避免把正常女性判成偏低。
  MetricDefinition(
    metricId: 'RBC',
    metricName: '红细胞计数',
    unit: '×10¹²/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 3.8, max: 5.8),
    aliases: ['RBC', '红细胞', '红细胞总数', 'Red Blood Cell'],
  ),
  MetricDefinition(
    metricId: 'HGB',
    metricName: '血红蛋白',
    unit: 'g/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 115, max: 175),
    aliases: ['HGB', 'Hb', '血色素', 'Hemoglobin'],
  ),
  MetricDefinition(
    metricId: 'HCT',
    metricName: '红细胞压积',
    unit: '%',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 35, max: 50),
    aliases: ['HCT', '红细胞比容', 'Hematocrit'],
  ),
  MetricDefinition(
    metricId: 'MCV',
    metricName: '平均红细胞体积',
    unit: 'fL',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 80, max: 100),
    aliases: ['MCV', '平均红细胞体积', 'Red Cell Volume Mean'],
  ),
  MetricDefinition(
    metricId: 'MCH',
    metricName: '平均红细胞血红蛋白量',
    unit: 'pg',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 27, max: 34),
    aliases: ['MCH', '平均红细胞血红蛋白量'],
  ),
  MetricDefinition(
    metricId: 'MCHC',
    metricName: '平均红细胞血红蛋白浓度',
    unit: 'g/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 316, max: 354),
    aliases: ['MCHC', '平均血红蛋白浓度'],
  ),
  MetricDefinition(
    metricId: 'PLT',
    metricName: '血小板计数',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 125, max: 350),
    aliases: ['PLT', '血小板', 'Platelet'],
  ),
  MetricDefinition(
    metricId: 'NEUT',
    metricName: '中性粒细胞绝对值',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 1.8, max: 6.3),
    // 只放绝对值/计数说法；「中性粒细胞百分比 / 比率」是另一测量，归非核心。
    aliases: [
      'NEUT',
      'NEUT#',
      'NE#',
      '中性粒细胞',
      '中性粒细胞绝对值',
      '中性粒细胞计数',
      'Neutrophil'
    ],
  ),
  MetricDefinition(
    metricId: 'LYMPH',
    metricName: '淋巴细胞绝对值',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 1.1, max: 3.2),
    aliases: [
      'LYMPH',
      'LYMPH#',
      'LY#',
      '淋巴细胞',
      '淋巴细胞绝对值',
      '淋巴细胞计数',
      'Lymphocyte'
    ],
  ),
  MetricDefinition(
    metricId: 'MONO',
    metricName: '单核细胞绝对值',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 0.1, max: 0.6),
    aliases: [
      'MONO',
      'MONO#',
      'MO#',
      '单核细胞',
      '单核细胞绝对值',
      '单核细胞计数',
      'Monocyte'
    ],
  ),
  MetricDefinition(
    metricId: 'EOS',
    metricName: '嗜酸性粒细胞绝对值',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 0.02, max: 0.52),
    aliases: [
      'EOS',
      'EOS#',
      'EO#',
      '嗜酸性粒细胞',
      '嗜酸性粒细胞绝对值',
      '嗜酸细胞计数',
      'Eosinophil'
    ],
  ),
  MetricDefinition(
    metricId: 'BASO',
    metricName: '嗜碱性粒细胞绝对值',
    unit: '×10⁹/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 0, max: 0.06),
    aliases: [
      'BASO',
      'BASO#',
      'BA#',
      '嗜碱性粒细胞',
      '嗜碱性粒细胞绝对值',
      '嗜碱细胞计数',
      'Basophil'
    ],
  ),
  // ===================== 电解质 =====================
  MetricDefinition(
    metricId: 'K',
    metricName: '钾',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 3.5, max: 5.5),
    aliases: ['K', '血钾', '钾离子', 'Potassium'],
  ),
  MetricDefinition(
    metricId: 'NA',
    metricName: '钠',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 135, max: 145),
    aliases: ['Na', 'NA', '血钠', '钠离子', 'Sodium'],
  ),
  MetricDefinition(
    metricId: 'CL',
    metricName: '氯',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 96, max: 106),
    aliases: ['Cl', 'CL', '血氯', 'Chloride'],
  ),
  MetricDefinition(
    metricId: 'CA',
    metricName: '钙',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 2.1, max: 2.6),
    aliases: ['Ca', 'CA', '血钙', 'Calcium'],
  ),
  MetricDefinition(
    metricId: 'P',
    metricName: '磷',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 0.8, max: 1.5),
    aliases: ['P', '血磷', 'Phosphorus'],
  ),
  MetricDefinition(
    metricId: 'MG',
    metricName: '镁',
    unit: 'mmol/L',
    bodySystem: '电解质',
    typicalRange: ReferenceRange(min: 0.7, max: 1.1),
    aliases: ['Mg', 'MG', '血镁', 'Magnesium'],
  ),
  // ===================== 甲状腺 =====================
  MetricDefinition(
    metricId: 'TSH',
    metricName: '促甲状腺激素',
    unit: 'mIU/L',
    bodySystem: '甲状腺',
    typicalRange: ReferenceRange(min: 0.27, max: 4.2),
    aliases: ['TSH', '促甲状腺激素', '甲状腺刺激素'],
  ),
  MetricDefinition(
    metricId: 'FT3',
    metricName: '游离三碘甲状腺原氨酸',
    unit: 'pmol/L',
    bodySystem: '甲状腺',
    aliases: ['FT3', '游离T3', '游离三碘甲状腺原氨酸'],
  ),
  MetricDefinition(
    metricId: 'FT4',
    metricName: '游离甲状腺素',
    unit: 'pmol/L',
    bodySystem: '甲状腺',
    aliases: ['FT4', '游离T4', '游离甲状腺素'],
  ),
  // ===================== 尿常规（常用）=====================
  MetricDefinition(
    metricId: 'GLU-U',
    metricName: '尿糖',
    unit: 'mmol/L',
    bodySystem: '尿常规',
    aliases: ['尿糖', 'GLU', '尿葡萄糖'],
  ),
  MetricDefinition(
    metricId: 'PRO-U',
    metricName: '尿蛋白',
    unit: 'g/L',
    bodySystem: '肾脏',
    aliases: ['尿蛋白', 'PRO', 'PRO-尿'],
  ),
  MetricDefinition(
    metricId: 'LEU-U',
    metricName: '尿白细胞',
    unit: '/μL',
    bodySystem: '尿常规',
    aliases: ['尿白细胞', 'LEU', '尿白细胞酯酶'],
  ),
  // —— 尿常规试纸条其余常见项（多为定性：阴性/阳性/±/+）——
  MetricDefinition(
    metricId: 'BLD-U',
    metricName: '尿隐血',
    unit: '',
    bodySystem: '尿常规',
    aliases: ['隐血', '尿潜血', '潜血', 'BLD', 'ERY', 'BLOOD', '尿红细胞'],
  ),
  MetricDefinition(
    metricId: 'BIL-U',
    metricName: '尿胆红素',
    unit: '',
    bodySystem: '尿常规',
    aliases: ['尿胆红素', '胆红素', 'BIL', 'U-BIL', 'Bilirubin'],
  ),
  MetricDefinition(
    metricId: 'URO-U',
    metricName: '尿胆原',
    unit: '',
    bodySystem: '尿常规',
    aliases: ['尿胆原', '尿胆素原', 'URO', 'UBG', 'Urobilinogen'],
  ),
  MetricDefinition(
    metricId: 'KET-U',
    metricName: '尿酮体',
    unit: '',
    bodySystem: '尿常规',
    aliases: ['酮体', '尿酮', 'KET', 'KETONE', '尿酮体定性'],
  ),
  MetricDefinition(
    metricId: 'NIT-U',
    metricName: '尿亚硝酸盐',
    unit: '',
    bodySystem: '尿常规',
    aliases: ['亚硝酸盐', '亚硝酸盐试验', 'NIT', 'NITRITE'],
  ),
  MetricDefinition(
    metricId: 'VC-U',
    metricName: '尿维生素C',
    unit: 'mmol/L',
    bodySystem: '尿常规',
    aliases: ['维生素C', '维生素c', '抗坏血酸', 'VC', 'VITC', 'Vit-C', 'Ascorbic Acid', '尿维C'],
  ),
  MetricDefinition(
    metricId: 'SG-U',
    metricName: '尿比重',
    unit: '',
    bodySystem: '尿常规',
    typicalRange: ReferenceRange(min: 1.003, max: 1.030),
    aliases: ['比重', '尿比重', 'SG', 'S.G', 'Specific Gravity'],
  ),
  MetricDefinition(
    metricId: 'PH-U',
    metricName: '尿酸碱度',
    unit: '',
    bodySystem: '尿常规',
    typicalRange: ReferenceRange(min: 4.5, max: 8.0),
    aliases: ['酸碱度', 'PH', 'pH', '尿pH', '尿液酸碱度', '酸碱度(PH)'],
  ),
  // ===================== 空腹血糖/其他常用糖代谢 =====================
  MetricDefinition(
    metricId: 'INS',
    metricName: '胰岛素',
    unit: 'mU/L',
    bodySystem: '血糖代谢',
    aliases: ['INS', '胰岛素', 'Insulin'],
  ),
  MetricDefinition(
    metricId: 'CPEP',
    metricName: 'C肽',
    unit: 'nmol/L',
    bodySystem: '血糖代谢',
    aliases: ['C肽', 'C-Peptide', 'CPEP'],
  ),
  // ===================== 慢病升级 步骤6：补齐慢病常用项 =====================
  // —— 血糖代谢 ——
  MetricDefinition(
    metricId: 'GA',
    metricName: '糖化白蛋白',
    unit: '%',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(min: 11, max: 17),
    aliases: ['GA', '糖化血清白蛋白', 'GSP'],
  ),
  MetricDefinition(
    metricId: 'OGTT2H',
    metricName: '口服葡萄糖耐量试验2小时血糖',
    unit: 'mmol/L',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(max: 7.8),
    aliases: ['OGTT 2h', 'OGTT2h', '餐后2小时血糖', '2hPG', 'OGTT-2小时'],
  ),
  // —— 肾脏 ——
  MetricDefinition(
    metricId: 'UACR',
    metricName: '尿白蛋白肌酐比',
    unit: 'mg/g',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(max: 30),
    aliases: ['UACR', 'ACR', '尿微量白蛋白/肌酐', '白蛋白肌酐比值', 'mAlb/Cr'],
  ),
  MetricDefinition(
    metricId: 'UALB24H',
    metricName: '24小时尿蛋白定量',
    unit: 'g/24h',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(max: 0.15),
    aliases: ['24h尿蛋白', '24小时尿蛋白', '尿蛋白定量'],
  ),
  MetricDefinition(
    metricId: 'MALB',
    metricName: '尿微量白蛋白',
    unit: 'mg/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(max: 20),
    aliases: ['微量白蛋白', 'mALB', 'Urine Microalbumin'],
  ),
  // —— 心血管 / 血脂进阶 ——
  MetricDefinition(
    metricId: 'HSCRP',
    metricName: '超敏C反应蛋白',
    unit: 'mg/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 3),
    aliases: ['hs-CRP', 'hsCRP', '超敏C反应蛋白', 'hs-CRP(超敏)'],
  ),
  MetricDefinition(
    metricId: 'HCY',
    metricName: '同型半胱氨酸',
    unit: 'μmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 15),
    aliases: ['Hcy', 'HCY', '高半胱氨酸', 'Homocysteine'],
  ),
  MetricDefinition(
    metricId: 'LPA',
    metricName: '脂蛋白(a)',
    unit: 'mg/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 300),
    aliases: ['Lp(a)', 'LPA', '脂蛋白a', 'Lipoprotein(a)'],
  ),
  MetricDefinition(
    metricId: 'APOA1',
    metricName: '载脂蛋白A1',
    unit: 'g/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 1.0, max: 1.6),
    aliases: ['ApoA1', 'APOA1', 'Apo-A1', '载脂蛋白A-Ⅰ'],
  ),
  MetricDefinition(
    metricId: 'APOB',
    metricName: '载脂蛋白B',
    unit: 'g/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 1.0),
    aliases: ['ApoB', 'APOB', 'Apo-B', '载脂蛋白B-100'],
  ),
  MetricDefinition(
    metricId: 'NTPROBNP',
    metricName: 'N末端B型钠尿肽前体',
    unit: 'pg/mL',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 125),
    aliases: ['NT-proBNP', 'NTproBNP', 'proBNP', 'NT-pro-BNP'],
    advisoryOnly: true,
  ),
  // —— 骨骼 ——
  MetricDefinition(
    metricId: 'BMD_T',
    metricName: '骨密度T值',
    unit: '',
    bodySystem: '骨骼',
    typicalRange: ReferenceRange(min: -1),
    aliases: ['T值', 'T-score', '骨密度T-score', 'BMD T'],
  ),
  MetricDefinition(
    metricId: 'VITD',
    metricName: '25羟基维生素D',
    unit: 'ng/mL',
    bodySystem: '骨骼',
    typicalRange: ReferenceRange(min: 20, max: 100),
    aliases: ['25(OH)D', '维生素D', 'Vitamin D', '25-OH-VD'],
  ),
  // —— 甲状腺抗体 ——
  MetricDefinition(
    metricId: 'TPOAB',
    metricName: '甲状腺过氧化物酶抗体',
    unit: 'IU/mL',
    bodySystem: '甲状腺',
    typicalRange: ReferenceRange(max: 34),
    aliases: ['TPOAb', 'TPO-Ab', 'anti-TPO', '抗甲状腺过氧化物酶抗体'],
  ),
  MetricDefinition(
    metricId: 'TGAB',
    metricName: '甲状腺球蛋白抗体',
    unit: 'IU/mL',
    bodySystem: '甲状腺',
    typicalRange: ReferenceRange(max: 115),
    aliases: ['TgAb', 'Tg-Ab', 'anti-Tg', '抗甲状腺球蛋白抗体'],
  ),
  // —— 肝炎 ——
  MetricDefinition(
    metricId: 'HBVDNA',
    metricName: '乙肝病毒DNA定量',
    unit: 'IU/mL',
    bodySystem: '肝脏',
    aliases: ['HBV-DNA', 'HBVDNA', 'HBV DNA', '乙肝DNA'],
  ),
  MetricDefinition(
    metricId: 'AFP',
    metricName: '甲胎蛋白',
    unit: 'ng/mL',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(max: 7),
    aliases: ['AFP', '甲胎球蛋白', 'Alpha-fetoprotein'],
    advisoryOnly: true,
  ),
  // —— 肿瘤标志物 ——
  MetricDefinition(
    metricId: 'CEA',
    metricName: '癌胚抗原',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 5),
    aliases: ['CEA', '癌胚抗原'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CA199',
    metricName: '糖类抗原19-9',
    unit: 'U/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 37),
    aliases: ['CA19-9', 'CA199', '糖类抗原199'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CA125',
    metricName: '糖类抗原125',
    unit: 'U/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 35),
    aliases: ['CA-125', 'CA125'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CA153',
    metricName: '糖类抗原15-3',
    unit: 'U/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 25),
    aliases: ['CA15-3', 'CA153'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'PSA',
    metricName: '前列腺特异性抗原',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 4),
    aliases: ['PSA', 'tPSA', '总PSA', '前列腺特异抗原'],
    advisoryOnly: true,
  ),

  // ===================== 核心指标扩充（Round 2）=====================
  // —— 肝脏 ——
  MetricDefinition(
    metricId: 'GLB',
    metricName: '球蛋白',
    unit: 'g/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 20, max: 35),
    aliases: ['GLB', '球蛋白', '血清球蛋白', 'Globulin'],
  ),
  MetricDefinition(
    metricId: 'IBIL',
    metricName: '间接胆红素',
    unit: 'μmol/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 0, max: 17),
    aliases: ['IBIL', 'I-BIL', '间接胆红素', '非结合胆红素', 'Indirect Bilirubin'],
  ),
  MetricDefinition(
    metricId: 'TBA',
    metricName: '总胆汁酸',
    unit: 'μmol/L',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 0, max: 10),
    aliases: ['TBA', '总胆汁酸', '胆汁酸', 'Total Bile Acid'],
  ),
  MetricDefinition(
    metricId: 'AGRATIO',
    metricName: '白球比',
    unit: '',
    bodySystem: '肝脏',
    typicalRange: ReferenceRange(min: 1.2, max: 2.5),
    aliases: ['A/G', '白球比', '白蛋白球蛋白比值', 'A/G比值'],
  ),
  // —— 肾脏 ——
  MetricDefinition(
    metricId: 'CYSC',
    metricName: '胱抑素C',
    unit: 'mg/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 0.6, max: 1.0),
    aliases: ['CysC', 'CYSC', '胱抑素C', '半胱氨酸蛋白酶抑制剂C', 'Cystatin C'],
  ),
  MetricDefinition(
    metricId: 'CO2CP',
    metricName: '二氧化碳结合力',
    unit: 'mmol/L',
    bodySystem: '肾脏',
    typicalRange: ReferenceRange(min: 22, max: 29),
    aliases: ['CO2CP', 'CO2-CP', '二氧化碳结合力', '总二氧化碳', 'TCO2'],
  ),
  // —— 血糖代谢 ——
  MetricDefinition(
    metricId: 'RPG',
    metricName: '随机血糖',
    unit: 'mmol/L',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(max: 11.1),
    aliases: ['随机血糖', '餐后血糖', 'RPG', 'RBG', '随机葡萄糖'],
  ),
  MetricDefinition(
    metricId: 'FRA',
    metricName: '果糖胺',
    unit: 'mmol/L',
    bodySystem: '血糖代谢',
    typicalRange: ReferenceRange(min: 122, max: 236),
    aliases: ['果糖胺', 'FRA', 'FMN', 'Fructosamine'],
  ),
  // —— 心血管 ——
  MetricDefinition(
    metricId: 'NONHDLC',
    metricName: '非高密度脂蛋白胆固醇',
    unit: 'mmol/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 4.1),
    aliases: ['non-HDL-C', '非高密度脂蛋白胆固醇', '非HDL胆固醇', 'nonHDL'],
  ),
  MetricDefinition(
    metricId: 'CK',
    metricName: '肌酸激酶',
    unit: 'U/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(min: 40, max: 200),
    aliases: ['CK', 'CPK', '肌酸激酶', 'Creatine Kinase'],
  ),
  MetricDefinition(
    metricId: 'CKMB',
    metricName: '肌酸激酶同工酶',
    unit: 'U/L',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 25),
    aliases: ['CK-MB', 'CKMB', '肌酸激酶同工酶', 'CK-MB质量'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CTNI',
    metricName: '肌钙蛋白I',
    unit: 'ng/mL',
    bodySystem: '心血管',
    typicalRange: ReferenceRange(max: 0.04),
    aliases: ['cTnI', 'CTNI', 'TnI', '肌钙蛋白I', 'Troponin I'],
    advisoryOnly: true,
  ),
  // —— 甲状腺 ——
  MetricDefinition(
    metricId: 'TT3',
    metricName: '总三碘甲状腺原氨酸',
    unit: 'nmol/L',
    bodySystem: '甲状腺',
    typicalRange: ReferenceRange(min: 1.3, max: 3.1),
    aliases: ['TT3', '总T3', '总三碘甲状腺原氨酸', 'T3'],
  ),
  MetricDefinition(
    metricId: 'TT4',
    metricName: '总甲状腺素',
    unit: 'nmol/L',
    bodySystem: '甲状腺',
    typicalRange: ReferenceRange(min: 66, max: 181),
    aliases: ['TT4', '总T4', '总甲状腺素', 'T4'],
  ),
  // —— 凝血 ——
  MetricDefinition(
    metricId: 'PT',
    metricName: '凝血酶原时间',
    unit: 's',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(min: 11, max: 14),
    aliases: ['PT', '凝血酶原时间', 'Prothrombin Time'],
  ),
  MetricDefinition(
    metricId: 'INR',
    metricName: '国际标准化比值',
    unit: '',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(min: 0.8, max: 1.2),
    aliases: ['INR', '国际标准化比值', 'PT-INR'],
  ),
  MetricDefinition(
    metricId: 'APTT',
    metricName: '活化部分凝血活酶时间',
    unit: 's',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(min: 25, max: 37),
    aliases: ['APTT', 'aPTT', '活化部分凝血活酶时间', '部分凝血活酶时间'],
  ),
  MetricDefinition(
    metricId: 'FIB',
    metricName: '纤维蛋白原',
    unit: 'g/L',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(min: 2, max: 4),
    aliases: ['FIB', '纤维蛋白原', 'Fibrinogen'],
  ),
  MetricDefinition(
    metricId: 'TT_COAG',
    metricName: '凝血酶时间',
    unit: 's',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(min: 14, max: 21),
    aliases: ['凝血酶时间', 'Thrombin Time'],
  ),
  MetricDefinition(
    metricId: 'DDIMER',
    metricName: 'D-二聚体',
    unit: 'mg/L',
    bodySystem: '凝血',
    typicalRange: ReferenceRange(max: 0.5),
    aliases: ['D-Dimer', 'DDIMER', 'D-二聚体', 'D二聚体', 'DD'],
    advisoryOnly: true,
  ),
  // —— 铁 / 贫血（归血液）——
  MetricDefinition(
    metricId: 'SF',
    metricName: '铁蛋白',
    unit: 'μg/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 30, max: 400),
    aliases: ['SF', '铁蛋白', '血清铁蛋白', 'Ferritin'],
  ),
  MetricDefinition(
    metricId: 'SI',
    metricName: '血清铁',
    unit: 'μmol/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 10.6, max: 36.7),
    aliases: ['SI', '血清铁', '铁', 'Iron', 'Fe'],
  ),
  MetricDefinition(
    metricId: 'VB12',
    metricName: '维生素B12',
    unit: 'pg/mL',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 180, max: 910),
    aliases: ['VB12', 'B12', '维生素B12', '钴胺素', 'Vitamin B12'],
  ),
  MetricDefinition(
    metricId: 'FOLATE',
    metricName: '叶酸',
    unit: 'ng/mL',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 4),
    aliases: ['叶酸', 'FA', 'Folate', 'Folic Acid'],
  ),
  MetricDefinition(
    metricId: 'TSAT',
    metricName: '转铁蛋白饱和度',
    unit: '%',
    bodySystem: '血液',
    typicalRange: ReferenceRange(min: 20, max: 50),
    aliases: ['TSAT', '转铁蛋白饱和度', '铁饱和度'],
  ),
  // —— 炎症（归血液）——
  MetricDefinition(
    metricId: 'CRP',
    metricName: 'C反应蛋白',
    unit: 'mg/L',
    bodySystem: '血液',
    typicalRange: ReferenceRange(max: 10),
    aliases: ['CRP', 'C反应蛋白', 'C-Reactive Protein'],
  ),
  MetricDefinition(
    metricId: 'ESR',
    metricName: '红细胞沉降率',
    unit: 'mm/h',
    bodySystem: '血液',
    typicalRange: ReferenceRange(max: 20),
    aliases: ['ESR', '血沉', '红细胞沉降率', 'Erythrocyte Sedimentation Rate'],
  ),
  // —— 胰腺 ——
  MetricDefinition(
    metricId: 'AMY',
    metricName: '淀粉酶',
    unit: 'U/L',
    bodySystem: '胰腺',
    typicalRange: ReferenceRange(min: 35, max: 135),
    aliases: ['AMY', '淀粉酶', '血淀粉酶', 'Amylase'],
  ),
  MetricDefinition(
    metricId: 'LIP',
    metricName: '脂肪酶',
    unit: 'U/L',
    bodySystem: '胰腺',
    typicalRange: ReferenceRange(min: 13, max: 60),
    aliases: ['LIP', '脂肪酶', 'Lipase'],
  ),
  // —— 骨 / 甲状旁腺 ——
  MetricDefinition(
    metricId: 'PTH',
    metricName: '甲状旁腺激素',
    unit: 'pg/mL',
    bodySystem: '骨骼',
    typicalRange: ReferenceRange(min: 15, max: 65),
    aliases: ['PTH', 'iPTH', '甲状旁腺激素', '全段甲状旁腺激素', 'Parathyroid Hormone'],
  ),
  // —— 肿瘤标志物 ——
  MetricDefinition(
    metricId: 'FPSA',
    metricName: '游离前列腺特异性抗原',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    aliases: ['fPSA', 'FPSA', '游离PSA', '游离前列腺特异性抗原', 'free PSA'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CYFRA211',
    metricName: '细胞角蛋白19片段',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 3.3),
    aliases: ['CYFRA21-1', 'CYFRA211', '细胞角蛋白19片段', 'CK19片段'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'NSE',
    metricName: '神经元特异性烯醇化酶',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 16.3),
    aliases: ['NSE', '神经元特异性烯醇化酶', '神经元烯醇化酶'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'SCC',
    metricName: '鳞状细胞癌抗原',
    unit: 'ng/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 1.5),
    aliases: ['SCC', 'SCCA', '鳞状细胞癌抗原', '鳞癌抗原'],
    advisoryOnly: true,
  ),
  MetricDefinition(
    metricId: 'CA724',
    metricName: '糖类抗原72-4',
    unit: 'U/mL',
    bodySystem: '肿瘤标志物',
    typicalRange: ReferenceRange(max: 6.9),
    aliases: ['CA72-4', 'CA724', '糖类抗原724'],
    advisoryOnly: true,
  ),
];
