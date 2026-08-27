/// 单条被识别的检查指标（OCR / AI 输出的结构化结果）
///
/// 为了提高编辑确认流程的简便性，编辑时可直接修改其中的可变字段
/// （matchedMetricId / canonicalName / value / unit / referenceMin / referenceMax / status / bodySystem）。
class RecognizedMetric {
  final String rawName; // 原始识别名称，例如「血清肌酐」
  final double originalValue; // 初次识别数值，用户编辑后仍保留
  final double? originalNumericValue;
  final String? originalTextValue;
  final String originalUnit;
  final double? originalReferenceMin;
  final double? originalReferenceMax;
  String? matchedMetricId; // 匹配到的标准指标 id，例如 CREA；null=未匹配（可编辑）
  String canonicalName; // 规范化名称（匹配到标准指标后用标准名，否则用 rawName）
  double value;
  double? numericValue; // 纯数值（无单位）。数值型结果用它；文本型为 null。
  String? textValue; // 文本型结果（阴性/阳性/未检出 等），避免因转不成数字而丢数据
  String? qualifier; // < / > / ≤ / ≥ 等定性符号
  String matchType; // 匹配类型：exact / alias / ai_suggested / unmatched
  String unit;
  double? referenceMin;
  double? referenceMax;
  final String referenceText; // 原始参考范围文本，例如「9–50」
  String status; // 偏高 / 偏低 / 正常 / 未判断（本地按参考范围计算，见 computeStatus）
  String? originalStatus; // 报告上标注的原始异常标记（如 H / L / 偏高），仅供核对，不用于判定
  String bodySystem; // 所属身体系统
  final double confidence; // 0~1
  bool isSelected; // 是否勾选入库（默认 true）
  bool wasEdited; // 用户是否修改过识别字段
  final String? notes;

  RecognizedMetric({
    required this.rawName,
    double? originalValue,
    double? originalNumericValue,
    this.originalTextValue,
    String? originalUnit,
    this.originalReferenceMin,
    this.originalReferenceMax,
    this.matchedMetricId,
    required this.canonicalName,
    required this.value,
    this.numericValue,
    this.textValue,
    this.qualifier,
    this.matchType = 'unmatched',
    required this.unit,
    this.referenceMin,
    this.referenceMax,
    this.referenceText = '',
    required this.status,
    this.originalStatus,
    required this.bodySystem,
    required this.confidence,
    this.isSelected = true,
    this.wasEdited = false,
    this.notes,
  })  : originalValue = originalValue ?? value,
        originalNumericValue = originalNumericValue ?? numericValue,
        originalUnit = originalUnit ?? unit;

  /// 复制并应用一部分编辑后的字段
  RecognizedMetric copyWith({
    String? canonicalName,
    String? matchedMetricId,
    double? value,
    String? unit,
    double? referenceMin,
    double? referenceMax,
    String? bodySystem,
    bool? isSelected,
    String? notes,
  }) {
    return RecognizedMetric(
      rawName: rawName,
      originalValue: originalValue,
      originalNumericValue: originalNumericValue,
      originalTextValue: originalTextValue,
      originalUnit: originalUnit,
      originalReferenceMin: originalReferenceMin,
      originalReferenceMax: originalReferenceMax,
      matchedMetricId: matchedMetricId ?? this.matchedMetricId,
      canonicalName: canonicalName ?? this.canonicalName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      referenceMin: referenceMin ?? this.referenceMin,
      referenceMax: referenceMax ?? this.referenceMax,
      referenceText: referenceText,
      status: status,
      bodySystem: bodySystem ?? this.bodySystem,
      confidence: confidence,
      isSelected: isSelected ?? this.isSelected,
      wasEdited: wasEdited,
      notes: notes ?? this.notes,
    );
  }
}

/// 一份被识别的结构化检验报告
class StructuredMedicalReport {
  String hospitalName; // 医院
  DateTime reportDate; // 检查日期
  String reportType; // 报告类型，如 生化检查
  final String patientName; // 患者姓名
  final List<RecognizedMetric> metrics; // 识别到的指标
  final String rawText; // 原始识别文本（全文，不进日志）
  final String? sourceImagePath; // 原始图片路径（可空，Web 无落盘）

  StructuredMedicalReport({
    this.hospitalName = '',
    DateTime? reportDate,
    this.reportType = '',
    this.patientName = '',
    List<RecognizedMetric>? metrics,
    this.rawText = '',
    this.sourceImagePath,
  }) : reportDate = reportDate ?? DateTime.now(),
       metrics = metrics ?? [];
}

/// 标准指标匹配与别名统一在 metric_dictionary.dart（见 matchMetric/matchMetricId/bodySystemForMetric）。
