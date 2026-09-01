import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/metric_dictionary.dart';
import '../models/report_models.dart';
import 'report_ocr_service.dart' show mediaTypeForImageFileName;

/// 报告识别服务统一接口。
///
/// 无论底层使用哪种 OCR / AI，都返回统一的 [StructuredMedicalReport]，
/// 使 UI 与数据库层不依赖任何具体 AI 提供商。
/// 隐私约定：实现内不得把图片字节或报告全文打印到日志。
abstract class ReportRecognitionService {
  /// 识别一张验单图片，返回结构化的检查指标。
  Future<StructuredMedicalReport> recognizeReport({
    required Uint8List imageBytes,
    String? imagePath,
    required String fileName,
  });
}

/// Mock 识别服务：不调用任何真实 OCR / AI，直接返回一组预设指标，
/// 用于跑通「上传 → 识别 → 确认 → 入库」的完整产品流程。
class MockReportRecognitionService implements ReportRecognitionService {
  @override
  Future<StructuredMedicalReport> recognizeReport({
    required Uint8List imageBytes,
    String? imagePath,
    required String fileName,
  }) async {
    // 模拟识别耗时，给 UI 展示 loading 的时间
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final metrics = _buildMetrics();
    return StructuredMedicalReport(
      hospitalName: '深圳某医院',
      reportDate: DateTime(2026, 8, 19),
      reportType: '生化检查',
      patientName: '徐先生',
      metrics: metrics,
      rawText: _mockRawText(metrics),
      sourceImagePath: imagePath,
    );
  }

  List<RecognizedMetric> _buildMetrics() {
    // 每一项先用原始名称，再通过匹配器标准化 matchedMetricId/canonicalName/bodySystem
    final raw = <({
      String rawName,
      double value,
      String unit,
      double? min,
      double? max,
      String refText
    })>[
      (
        rawName: 'ALT',
        value: 32,
        unit: 'U/L',
        min: 9,
        max: 50,
        refText: '9–50'
      ),
      (
        rawName: 'AST',
        value: 27,
        unit: 'U/L',
        min: 15,
        max: 40,
        refText: '15–40'
      ),
      (
        rawName: '尿酸',
        value: 480,
        unit: 'μmol/L',
        min: 210,
        max: 420,
        refText: '210–420'
      ),
      (
        rawName: '肌酐',
        value: 93,
        unit: 'μmol/L',
        min: 57,
        max: 111,
        refText: '57–111'
      ),
      (
        rawName: '空腹血糖',
        value: 6.8,
        unit: 'mmol/L',
        min: 3.9,
        max: 6.1,
        refText: '3.9–6.1'
      ),
      (
        rawName: '糖化血红蛋白',
        value: 6.8,
        unit: '%',
        min: 4.0,
        max: 6.0,
        refText: '4.0–6.0'
      ),
      (
        rawName: 'LDL-C',
        value: 3.6,
        unit: 'mmol/L',
        min: 0,
        max: 3.4,
        refText: '0–3.4'
      ),
      (
        rawName: 'HDL-C',
        value: 1.2,
        unit: 'mmol/L',
        min: 1.0,
        max: 1.6,
        refText: '1.0–1.6'
      ),
    ];

    // 人为让其中一条置信度偏低，用于演示「请重点核对」低置信度提示
    return [
      for (int i = 0; i < raw.length; i++)
        _toRecognizedMetric(
          rawName: raw[i].rawName,
          value: raw[i].value,
          unit: raw[i].unit,
          min: raw[i].min,
          max: raw[i].max,
          refText: raw[i].refText,
          confidence: i == raw.length - 1 ? 0.76 : 0.96,
        ),
    ];
  }

  RecognizedMetric _toRecognizedMetric({
    required String rawName,
    required double value,
    required String unit,
    required double? min,
    required double? max,
    required String refText,
    required double confidence,
  }) {
    final matchedId = matchMetricId(rawName);
    final def = matchedId == null ? null : findMetricDefinition(matchedId);
    final status =
        (min != null && max != null) ? _statusFor(value, min, max) : '未判断';
    return RecognizedMetric(
      rawName: rawName,
      matchedMetricId: matchedId,
      canonicalName: def?.metricName ?? rawName,
      value: value,
      numericValue: value,
      unit: unit,
      referenceMin: min,
      referenceMax: max,
      referenceText: refText,
      status: status,
      bodySystem: bodySystemForMetric(matchedId, fallback: '其他'),
      confidence: confidence,
      isSelected: true,
    );
  }

  String _statusFor(double v, double min, double max) {
    if (v > max) return '偏高';
    if (v < min) return '偏低';
    return '正常';
  }

  String _mockRawText(List<RecognizedMetric> metrics) {
    final buf = StringBuffer('化验单（Mock 识别文本）\n');
    for (final m in metrics) {
      buf.writeln(
          '${m.canonicalName} ${m.value} ${m.unit} 参考 ${m.referenceText}');
    }
    return buf.toString();
  }
}

/// 远程 OCR / AI 识别服务：把图片上传到自有后端（见 docs/backend_api.md）。
///
/// 【安全】API Key 绝不写进 App；App 只访问自有后端地址。
/// 后端地址通过编译期变量 `REPORT_API_BASE` 提供（`flutter run --dart-define=REPORT_API_BASE=https://…`），
/// 未配置时不连接任何 HTTP，直接抛「后端未配置」异常。
///
/// AI 只把文字结构化成数值；本服务会用本地字典 [matchMetricId] 匹配指标、
/// 用本地 [computeStatus] 计算状态，不信任 AI 报告的状态字段。
class RemoteReportRecognitionService implements ReportRecognitionService {
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');
  static const Duration _timeout = Duration(seconds: 30);

  @override
  Future<StructuredMedicalReport> recognizeReport({
    required Uint8List imageBytes,
    String? imagePath,
    required String fileName,
  }) async {
    if (_apiBase.isEmpty) {
      throw StateError('识别后端未配置（REPORT_API_BASE）');
    }

    final uri = Uri.parse('$_apiBase/api/report/recognize');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
          filename: fileName,
          contentType: mediaTypeForImageFileName(fileName)));

    http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw StateError('网络连接失败，请稍后重试');
    } on Exception {
      throw StateError('网络连接失败，请稍后重试');
    }

    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      body = null;
    }
    if (response.statusCode != 200) {
      final detail = body is Map ? body['detail']?.toString() : null;
      throw StateError(
        detail == null || detail.trim().isEmpty ? '报告识别失败' : detail,
      );
    }

    if (body is! Map<String, dynamic>) {
      throw StateError('报告识别失败');
    }
    // 0 指标不再当失败：可能是影像/病理/病历等图文报告。调用方按
    // report.metrics.isEmpty 决定进「结构化核对页」还是「图文报告」流程。
    // 真正的失败（网络 / 502 / 无文字）已在上面按状态码抛出。
    return structuredReportFromBackendJson(body, imagePath);
  }
}

/// 把后端统一 JSON 映射为本地模型，并做指标匹配 + 本地状态计算。
///
/// 独立为顶层函数，便于测试真实后端返回的 numericValue/textValue/qualifier 等
/// 字段不会在进入核对页前丢失。
StructuredMedicalReport structuredReportFromBackendJson(
    Map<String, dynamic> body, String? imagePath) {
  final metrics = <RecognizedMetric>[];
  final rawList = body['metrics'];
  if (rawList is List) {
    for (final item in rawList) {
      if (item is! Map) continue;
      final rawName = (item['rawName'] ?? '').toString();
      if (rawName.trim().isEmpty) continue;
      final id = _matchBackendMetricId(item, rawName);
      final def = id == null ? null : findMetricDefinition(id);
      final value = _num(item['numericValue']) ?? _num(item['value']);
      final min = _num(item['referenceMin']);
      final max = _num(item['referenceMax']);
      final unit = normalizeUnit((item['unit'] ?? '').toString());
      final textValue = item['textValue']?.toString();
      final referenceText = (item['referenceText'] ?? '').toString();
      // 先按数值+范围判;判不了(定性结果)再按文字判(阴性→正常 / 阳性→需关注)。
      final status = (value != null && (min != null || max != null))
          ? computeStatus(value, ReferenceRange(min: min, max: max))
          : (computeQualitativeStatus(textValue,
                  referenceText: referenceText) ??
              '未判断');
      final hasResult =
          value != null || (textValue != null && textValue.trim().isNotEmpty);
      if (!hasResult) continue;

      metrics.add(RecognizedMetric(
        rawName: rawName,
        matchedMetricId: id,
        matchType: id != null ? 'exact' : 'unmatched',
        canonicalName:
            def?.metricName ?? (item['canonicalName'] ?? rawName).toString(),
        value: value ?? 0,
        numericValue: value,
        textValue: textValue,
        qualifier: item['qualifier']?.toString(),
        unit: unit,
        referenceMin: min,
        referenceMax: max,
        referenceText: referenceText,
        status: status,
        originalStatus: item['originalStatus']?.toString(),
        bodySystem: bodySystemForMetric(id, fallback: '其他'),
        confidence: _num(item['confidence']) ?? 0.0,
      ));
    }
  }

  final parsedDate = _parseDate(body['reportDate']);
  final birth = _parseDate(body['patientBirthDate']);
  final gender = _normalizeGender((body['patientGender'] ?? '').toString());
  return StructuredMedicalReport(
    hospitalName: (body['hospitalName'] ?? '').toString(),
    reportDate: parsedDate ?? DateTime.now(),
    dateFromOcr: parsedDate != null,
    reportType: (body['reportType'] ?? '').toString(),
    patientName: (body['patientName'] ?? '').toString(),
    patientGender: gender,
    patientBirthDate: birth,
    isMedical: body['isMedical'] == true,
    imagingType: kImagingReportTypes.contains((body['imagingType'] ?? '').toString())
        ? (body['imagingType']).toString()
        : '',
    rawText: (body['rawText'] ?? '').toString(),
    metrics: metrics,
    sourceImagePath: imagePath,
  );
}

/// 受限的 12 类图文/影像报告类型（与后端 DeepSeek 的 imagingType 枚举一致，
/// 也是 imaging_report_page 里 imagingReportTypes 的来源）。此处独立一份，避免
/// service 层 import 页面层。
const List<String> kImagingReportTypes = [
  'X光', 'CT', 'MRI', 'B超', '彩超', '心电图', '病理',
  '出院小结', '手术记录', '门诊病历', '处方笺', '疫苗接种',
];

/// 把同一份报告的多页识别结果合并成一份。
///
/// - 元信息（医院/日期/类型/姓名/性别/生日）：取各页里第一个"有意义"的值。
/// - 指标：各页顺序拼接，按 (规范化名 + 数值/文本值) 去重。
/// - 原文：按页拼接，加"—— 第 N 页 ——"分隔。
/// - dateFromOcr：任一页从 OCR 得到日期即为 true。
StructuredMedicalReport mergeStructuredReports(
  List<StructuredMedicalReport> pages, {
  String? sourceImagePath,
}) {
  if (pages.length == 1) return pages.first;

  String firstNonEmpty(String Function(StructuredMedicalReport) get,
      {Set<String> skip = const {}}) {
    for (final p in pages) {
      final v = get(p).trim();
      if (v.isNotEmpty && !skip.contains(v)) return v;
    }
    return '';
  }

  final mergedMetrics = <RecognizedMetric>[];
  final seen = <String>{};
  for (final p in pages) {
    for (final m in p.metrics) {
      final key = '${m.canonicalName.trim().toLowerCase().replaceAll(' ', '')}'
          '|${m.numericValue ?? ''}|${(m.textValue ?? '').trim()}';
      if (seen.add(key)) mergedMetrics.add(m);
    }
  }

  DateTime? ocrDate;
  for (final p in pages) {
    if (p.dateFromOcr) {
      ocrDate = p.reportDate;
      break;
    }
  }

  final rawText = [
    for (var i = 0; i < pages.length; i++)
      if (pages[i].rawText.trim().isNotEmpty)
        '—— 第 ${i + 1} 页 ——\n${pages[i].rawText.trim()}',
  ].join('\n\n');

  return StructuredMedicalReport(
    hospitalName: firstNonEmpty((p) => p.hospitalName),
    reportDate: ocrDate ?? DateTime.now(),
    dateFromOcr: ocrDate != null,
    reportType: firstNonEmpty((p) => p.reportType, skip: {'其他检验', '其他'}),
    patientName: firstNonEmpty((p) => p.patientName),
    patientGender: firstNonEmpty((p) => p.patientGender),
    patientBirthDate:
        pages.map((p) => p.patientBirthDate).firstWhere((d) => d != null,
            orElse: () => null),
    isMedical: pages.any((p) => p.isMedical),
    imagingType: firstNonEmpty((p) => p.imagingType),
    rawText: rawText,
    metrics: mergedMetrics,
    sourceImagePath: sourceImagePath,
  );
}

/// 把后端/OCR 给的性别文本收敛成「男 / 女 / 空」。其他一律空，不猜。
String _normalizeGender(String raw) {
  final v = raw.trim();
  if (v == '男' || v.toLowerCase() == 'male' || v.toLowerCase() == 'm') return '男';
  if (v == '女' || v.toLowerCase() == 'female' || v.toLowerCase() == 'f') return '女';
  return '';
}

/// 核对页前的质量门槛：宁可让用户重拍/手工录入，也不把明显不可靠的识别结果送去入库。
String? validateStructuredReportForReview(StructuredMedicalReport report) {
  if (report.metrics.isEmpty) {
    return '未识别到可保存的检查指标，请确认图片是清晰的检验报告';
  }

  final usable = report.metrics.where((m) {
    final hasResult = m.numericValue != null ||
        (m.textValue != null && m.textValue!.trim().isNotEmpty);
    return hasResult && m.matchedMetricId != null;
  }).length;

  if (usable == 0) {
    return '识别结果无法匹配到健康指标，请重新拍摄或使用手工录入';
  }

  return null;
}

String? _matchBackendMetricId(Map item, String rawName) {
  final modelId = item['matchedMetricId']?.toString().trim();
  if (modelId != null && modelId.isNotEmpty) {
    final def = findMetricDefinition(modelId);
    if (def != null) return def.metricId;
  }

  for (final candidate in _metricNameCandidates(item, rawName)) {
    final id = matchMetricId(candidate);
    if (id != null) return id;
  }
  return null;
}

Iterable<String> _metricNameCandidates(Map item, String rawName) sync* {
  final seen = <String>{};
  void add(String? value) {
    final v = value?.trim();
    if (v != null && v.isNotEmpty) seen.add(v);
  }

  add(rawName);
  add(item['canonicalName']?.toString());
  add(item['matchedMetricId']?.toString());

  final bracket = RegExp(r'[（(]([^）)]+)[）)]');
  for (final m in bracket.allMatches(rawName)) {
    add(m.group(1));
  }

  for (final value in seen) {
    yield value;
  }
}

double? _num(dynamic v) => v is num && !v.isNaN ? v.toDouble() : null;

DateTime? _parseDate(dynamic v) {
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v.trim());
  }
  return null;
}
