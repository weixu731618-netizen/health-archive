/// 影像/病理报告：从 OCR 全文里**轻量**猜出报告类型、检查日期、涉及身体部位。
///
/// 只做关键词/正则匹配，给影像页做「预填」，用户可随时改。
/// 不调用任何 AI、不联网；猜不出就返回 null / 空集合。
library;

import '../models/body_area_health.dart';

/// 报告类型关键词表。每个类型分两档：
/// - strong：只会出现在"这张确实是该类报告"里，单独命中即可（记 2 分）。
/// - weak：也可能出现在体检套餐项目清单等处，需有同伴才算数（记 1 分）。
/// 总分 = 2*strong命中数 + 1*weak命中数；取最高分，且必须 >= 2 才采纳（见 guessImagingReportType）。
/// key 必须是 `imagingReportTypes`（见 imaging_report_page.dart）里的现有值。
class _TypeRule {
  final String type;
  final List<String> strong;
  final List<String> weak;
  const _TypeRule(this.type, {this.strong = const [], this.weak = const []});
}

const List<_TypeRule> _typeRules = [
  _TypeRule('心电图',
      strong: ['心电图报告', '常规心电图', '窦性心律', '窦性心动过', 'ST-T改变', '心电轴'],
      weak: ['心电图', 'ECG', 'EKG']),
  _TypeRule('病理',
      strong: ['病理诊断', '病理号', '穿刺组织', '免疫组化', 'HE染色', '镜下：', '镜检：'],
      weak: ['病理', '活检']),
  _TypeRule('彩超',
      strong: [
        '彩色多普勒', '超声所见', '超声描述', '超声提示', '声像图', 'CDFI',
        '多普勒超声', 'B型超声', '超声心动图', '心脏彩超'
      ],
      weak: ['彩超', 'B超', '超声', '超声检查', '心动图']),
  _TypeRule('CT',
      strong: ['CT平扫', 'CT增强', '计算机体层', '螺旋CT', 'CT所见', 'CT表现', 'CT值'],
      weak: ['CT', 'CT检查']),
  _TypeRule('MRI',
      strong: ['磁共振', 'MR平扫', 'MR增强', 'T1WI', 'T2WI', 'DWI', '弥散加权'],
      weak: ['MRI', 'MR成像']),
  _TypeRule('X光',
      strong: ['DR摄片', 'X线所见', '数字化摄影', 'DR平片'],
      weak: ['X线', 'X光', '胸片', '正位片', '侧位片', '摄片']),
  _TypeRule('出院小结',
      strong: ['出院记录', '出院小结', '出院诊断', '入院日期'], weak: ['出院']),
  _TypeRule('手术记录',
      strong: ['手术记录', '手术经过', '术中所见', '麻醉方式'], weak: ['手术']),
  _TypeRule('门诊病历', strong: ['门诊病历', '门诊记录', '现病史'], weak: ['主诉']),
  _TypeRule('处方笺', strong: ['处方笺', 'Rp.', 'Rp:', '用法用量'], weak: ['处方']),
  _TypeRule('疫苗接种', strong: ['预防接种证', '接种记录', '疫苗接种'], weak: ['疫苗', '接种']),
];

/// 身体部位关键词 → [coreBodyAreaOrder] 里的系统名。
const List<MapEntry<String, List<String>>> _areaKeywords = [
  MapEntry('肝胆', ['肝脏', '肝内', '肝区', '胆囊', '胆总管', '肝胆', '胆管']),
  MapEntry('胰腺', ['胰腺', '胰头', '胰体', '胰尾']),
  MapEntry('肾脏/泌尿', ['肾脏', '双肾', '左肾', '右肾', '输尿管', '膀胱', '前列腺', '尿道', '肾盂']),
  MapEntry('心血管', [
    '心脏', '心动图', '心室', '心房', '瓣膜', '二尖瓣', '三尖瓣', '主动脉瓣', '主动脉',
    '肺动脉', '肺静脉', '冠状动脉', '颈动脉', '下肢动脉', '下肢静脉', '射血分数', '心包',
  ]),
  // 注意：不要用裸「肺」——心脏彩超里的「肺动脉/肺静脉」会误判成呼吸系统。
  MapEntry('呼吸系统', ['双肺', '肺纹理', '肺野', '肺门', '肺实质', '支气管', '气管', '胸腔积液', '纵隔', '胸膜']),
  MapEntry('消化系统', ['胃', '肠', '结肠', '直肠', '食管', '阑尾', '脾脏', '脾大']),
  MapEntry('内分泌/代谢', ['甲状腺', '甲状旁腺', '肾上腺']),
  MapEntry('生殖系统', ['子宫', '卵巢', '附件', '阴道', '宫颈', '睾丸', '阴囊', '精囊', '前列腺增生']),
  MapEntry('血液系统', ['淋巴结', '淋巴结肿大', '骨髓']),
  MapEntry('骨骼关节', ['椎体', '颈椎', '腰椎', '胸椎', '关节', '膝关节', '髋关节', '骨质', '半月板', '椎间盘']),
  MapEntry('眼睛', ['眼球', '晶状体', '玻璃体', '视网膜', '眼眶']),
  MapEntry('耳鼻喉', ['鼻窦', '鼻咽', '喉部', '中耳', '乳突']),
  MapEntry('皮肤与足部', ['皮下', '软组织', '体表']),
];

/// OCR 文本看起来「有没有可归档的报告实质内容」。
///
/// 用于挡掉：体检表封面/信息页、拍糊、拍到证件或别的东西 —— 这些没有指标、
/// 也不该被当成图文报告存进档案。宁可误判（用户还能手动强存），也别脏档案。
bool hasReportSubstance(String ocrText) {
  final t = ocrText.replaceAll(RegExp(r'\s'), '');
  if (t.isEmpty) return false;
  // 报告正文/结论区特有的词（尽量不用会出现在封面清单里的通用词）
  const cues = [
    '所见', '结论', '诊断', '印象', '未见', '影像学', '检查所见', '超声所见',
    '报告医师', '审核医师', '检查医师', '检查方法', '病理', '镜下', '参考区间',
    '参考值', '异常', '阴性', '阳性', '建议复查', '随访',
  ];
  if (cues.any(t.contains)) return true;
  // 明确是影像类（有强/弱词打分）也算有内容
  if (guessImagingReportType(ocrText) != null) return true;
  // 兜底：正文字数足够多（信息页通常只有寥寥几十字）
  return t.length >= 80;
}

/// 这份报告是不是「图文/影像类」（B超/彩超/CT/MRI/X光/心电图/病理/病历等）。
///
/// 统一识别流程用它兜底分流：这类报告里常有器官尺寸、血流速度等测量数字，
/// DeepSeek 可能把它们当成「指标」抽出来，导致只按 metrics 是否为空分流会误判。
/// 只要报告类型是影像类、或 OCR 全文命中影像关键词，就当图文报告处理。
bool looksLikeImagingReport({required String reportType, required String ocrText}) {
  const imagingTypes = {
    'X光', 'CT', 'MRI', 'B超', '彩超', '超声', '心电图', '病理',
    '出院小结', '手术记录', '门诊病历', '处方笺', '疫苗接种',
  };
  final rt = reportType.trim();
  if (imagingTypes.any((t) => rt.contains(t))) return true;
  return guessImagingReportType(ocrText) != null;
}

/// 从 OCR 文本猜报告类型。强词记 2 分、弱词记 1 分，取最高分的类型；
/// **总分 < 2 一律返回 null**（避免体检套餐项目清单里单独一个「正位片」「心电图」
/// 就把整张判成影像）。同分取 `_typeRules` 里更靠前（更具体）的一项。
String? guessImagingReportType(String text) {
  if (text.trim().isEmpty) return null;
  final t = text.toUpperCase();
  String? best;
  var bestScore = 0;
  for (final rule in _typeRules) {
    var score = 0;
    for (final kw in rule.strong) {
      if (t.contains(kw.toUpperCase())) score += 2;
    }
    for (final kw in rule.weak) {
      if (t.contains(kw.toUpperCase())) score += 1;
    }
    if (score > bestScore) {
      bestScore = score;
      best = rule.type;
    }
  }
  return bestScore >= 2 ? best : null;
}

/// 从 OCR 文本猜检查日期；识别不到、解析不出或落在未来则返回 null。
DateTime? guessReportDate(String text, {DateTime? now}) {
  if (text.trim().isEmpty) return null;
  final today = now ?? DateTime.now();

  final patterns = <RegExp>[
    RegExp(r'(19|20)(\d{2})\s*[-/.年]\s*(\d{1,2})\s*[-/.月]\s*(\d{1,2})'),
  ];
  for (final re in patterns) {
    for (final m in re.allMatches(text)) {
      final year = int.parse('${m.group(1)}${m.group(2)}');
      final month = int.parse(m.group(3)!);
      final day = int.parse(m.group(4)!);
      if (month < 1 || month > 12 || day < 1 || day > 31) continue;
      final d = DateTime(year, month, day);
      if (d.year < 1990) continue;
      if (d.isAfter(today)) continue;
      return d;
    }
  }
  return null;
}

/// 从 OCR 文本猜涉及的身体部位（可能多个）；只返回 [coreBodyAreaOrder] 里的系统名。
Set<String> guessBodyAreas(String text) {
  final out = <String>{};
  if (text.trim().isEmpty) return out;
  for (final entry in _areaKeywords) {
    if (!coreBodyAreaOrder.contains(entry.key)) continue;
    for (final kw in entry.value) {
      if (text.contains(kw)) {
        out.add(entry.key);
        break;
      }
    }
  }
  return out;
}
