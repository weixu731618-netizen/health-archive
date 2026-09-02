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
  bool statusFromLabFlag; // status 是否因与化验单标注冲突而改用了化验单标注（参考范围可能没读对）
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
    this.statusFromLabFlag = false,
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

/// 「未关联记录」的 reportType 标记：识别归不到任何已知类型、用户确认存下的
/// 原图 + OCR 文字。不挂指标、不关联器官，记录页里单独一栏。
const String kUnlinkedReportType = '未关联记录';

/// 一份被识别的结构化检验报告
/// 体检报告结构化的「非化验」部分：总检结论 / 建议 / 各科所见 / 一般项目。
/// 化验数字仍走 [RecognizedMetric]；这里只装文字块和一般项目的数值。
class ExamGeneralItems {
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final double? waistCm;
  final double? systolic;
  final double? diastolic;
  final double? pulse;

  const ExamGeneralItems({
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.waistCm,
    this.systolic,
    this.diastolic,
    this.pulse,
  });

  bool get isEmpty =>
      heightCm == null &&
      weightKg == null &&
      bmi == null &&
      waistCm == null &&
      systolic == null &&
      diastolic == null &&
      pulse == null;

  static double? _n(dynamic v) => v is num ? v.toDouble() : null;

  factory ExamGeneralItems.fromJson(Map j) => ExamGeneralItems(
        heightCm: _n(j['heightCm']),
        weightKg: _n(j['weightKg']),
        bmi: _n(j['bmi']),
        waistCm: _n(j['waistCm']),
        systolic: _n(j['systolic']),
        diastolic: _n(j['diastolic']),
        pulse: _n(j['pulse']),
      );

  Map<String, dynamic> toJson() => {
        if (heightCm != null) 'heightCm': heightCm,
        if (weightKg != null) 'weightKg': weightKg,
        if (bmi != null) 'bmi': bmi,
        if (waistCm != null) 'waistCm': waistCm,
        if (systolic != null) 'systolic': systolic,
        if (diastolic != null) 'diastolic': diastolic,
        if (pulse != null) 'pulse': pulse,
      };
}

class ExamDepartmentFinding {
  final String name;
  final String finding;
  const ExamDepartmentFinding({required this.name, required this.finding});

  factory ExamDepartmentFinding.fromJson(Map j) => ExamDepartmentFinding(
        name: (j['name'] ?? '').toString(),
        finding: (j['finding'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'finding': finding};
}

class ExamSummary {
  final String? conclusion;
  final List<String> advice;
  final List<ExamDepartmentFinding> departments;
  final ExamGeneralItems general;

  const ExamSummary({
    this.conclusion,
    this.advice = const [],
    this.departments = const [],
    this.general = const ExamGeneralItems(),
  });

  bool get isEmpty =>
      (conclusion == null || conclusion!.trim().isEmpty) &&
      advice.isEmpty &&
      departments.isEmpty &&
      general.isEmpty;

  /// 是否有**实际内容**（不是空白体检表被硬编出来的空栏目）：
  /// 总检结论 / 建议、或一般项目数值、或真的填了字的科室所见。
  bool get hasSubstance {
    final c = conclusion?.trim() ?? '';
    if (c.isNotEmpty && !_isFiller(c)) return true;
    if (advice.any((a) => a.trim().isNotEmpty && !_isFiller(a))) return true;
    if (!general.isEmpty) return true;
    return departments
        .any((d) => d.finding.trim().isNotEmpty && !_isFiller(d.finding));
  }

  static bool _isFiller(String s) {
    final t = s.trim().replaceAll(RegExp(r'[\s（）()【】\[\]—\-_/、,。.]'), '');
    return t.isEmpty ||
        const {
          '未填写', '待填', '空白', '空', '无', '略', '暂无', '见报告', '详见报告',
          '未做', '未查', '弃查', 'na', 'n/a', '/',
        }.contains(t.toLowerCase());
  }

  factory ExamSummary.fromJson(Map j) => ExamSummary(
        conclusion: (j['conclusion'] as String?)?.trim().isEmpty ?? true
            ? null
            : (j['conclusion'] as String).trim(),
        advice: [
          for (final a in (j['advice'] as List? ?? const []))
            if (a is String && a.trim().isNotEmpty) a.trim()
        ],
        departments: [
          for (final d in (j['departments'] as List? ?? const []))
            if (d is Map) ExamDepartmentFinding.fromJson(d)
        ].where((d) => d.name.isNotEmpty && d.finding.isNotEmpty).toList(),
        general: j['general'] is Map
            ? ExamGeneralItems.fromJson(j['general'] as Map)
            : const ExamGeneralItems(),
      );

  Map<String, dynamic> toJson() => {
        if (conclusion != null) 'conclusion': conclusion,
        if (advice.isNotEmpty) 'advice': advice,
        if (departments.isNotEmpty)
          'departments': [for (final d in departments) d.toJson()],
        if (!general.isEmpty) 'general': general.toJson(),
      };
}

class StructuredMedicalReport {
  String hospitalName; // 医院
  DateTime reportDate; // 检查日期
  String reportType; // 报告类型，如 生化检查
  final String patientName; // 患者姓名（仅供核对 / 预填，不作身份）
  final String patientGender; // 报告上的性别：男/女/空。仅供预填档案资料
  final DateTime? patientBirthDate; // 报告上的出生日期，可空。仅供预填档案资料
  final bool isMedical; // DeepSeek 判断：这张图的文字整体是不是医疗相关
  final String imagingType; // 受限 12 类之一（X光/CT/…/疫苗接种）；判不准为空
  final List<RecognizedMetric> metrics; // 识别到的指标
  final String rawText; // 原始识别文本（全文，不进日志）
  final String? sourceImagePath; // 原始图片路径（可空，Web 无落盘）

  /// 体检报告才有：总检结论 / 建议 / 各科所见 / 一般项目。普通化验单为 null。
  final ExamSummary? examSummary;

  /// 检查日期是否来自识别结果。false 表示后端没给出、当前用的是上传当天的日期，
  /// 结果页会提示用户确认（§21）。
  final bool dateFromOcr;

  StructuredMedicalReport({
    this.hospitalName = '',
    DateTime? reportDate,
    this.reportType = '',
    this.patientName = '',
    this.patientGender = '',
    this.patientBirthDate,
    this.isMedical = false,
    this.imagingType = '',
    List<RecognizedMetric>? metrics,
    this.rawText = '',
    this.sourceImagePath,
    this.examSummary,
    bool? dateFromOcr,
  }) : reportDate = reportDate ?? DateTime.now(),
       dateFromOcr = dateFromOcr ?? (reportDate != null),
       metrics = metrics ?? [];
}

/// 标准指标匹配与别名统一在 metric_dictionary.dart（见 matchMetric/matchMetricId/bodySystemForMetric）。
