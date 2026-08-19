import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/metric_dictionary.dart';
import '../models/report_models.dart';

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
    final raw = <({String rawName, double value, String unit,
        double? min, double? max, String refText})>[
      (rawName: 'ALT', value: 32, unit: 'U/L', min: 9, max: 50, refText: '9–50'),
      (rawName: 'AST', value: 27, unit: 'U/L', min: 15, max: 40, refText: '15–40'),
      (rawName: '尿酸', value: 480, unit: 'μmol/L', min: 210, max: 420, refText: '210–420'),
      (rawName: '肌酐', value: 93, unit: 'μmol/L', min: 57, max: 111, refText: '57–111'),
      (rawName: '空腹血糖', value: 6.8, unit: 'mmol/L', min: 3.9, max: 6.1, refText: '3.9–6.1'),
      (rawName: '糖化血红蛋白', value: 6.8, unit: '%', min: 4.0, max: 6.0, refText: '4.0–6.0'),
      (rawName: 'LDL-C', value: 3.6, unit: 'mmol/L', min: 0, max: 3.4, refText: '0–3.4'),
      (rawName: 'HDL-C', value: 1.2, unit: 'mmol/L', min: 1.0, max: 1.6, refText: '1.0–1.6'),
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
    final status = (min != null && max != null)
        ? _statusFor(value, min!, max!)
        : '未判断';
    return RecognizedMetric(
      rawName: rawName,
      matchedMetricId: matchedId,
      canonicalName: def?.metricName ?? rawName,
      value: value,
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
      buf.writeln('${m.canonicalName} ${m.value} ${m.unit} 参考 ${m.referenceText}');
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
          filename: fileName));

    http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed).timeout(_timeout);
    } on TimeoutException {
      throw StateError('网络连接失败，请稍后重试');
    } on Exception {
      throw StateError('网络连接失败，请稍后重试');
    }

    if (response.statusCode != 200) {
      throw StateError('报告识别失败');
    }

    final dynamic body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw StateError('报告识别失败');
    }
    return _mapToStructured(body, imagePath);
  }

  /// 把后端统一 JSON 映射为本地模型，并做指标匹配 + 本地状态计算。
  StructuredMedicalReport _mapToStructured(
      Map<String, dynamic> body, String? imagePath) {
    final metrics = <RecognizedMetric>[];
    final rawList = body['metrics'];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is! Map) continue;
        final id = matchMetricId((item['rawName'] ?? '').toString());
        final def = id == null ? null : findMetricDefinition(id);
        final valueRaw = item['value'];
        final double? value = (valueRaw is num) ? valueRaw.toDouble() : null;
        final double? min =
            (item['referenceMin'] is num) ? (item['referenceMin'] as num).toDouble() : null;
        final double? max =
            (item['referenceMax'] is num) ? (item['referenceMax'] as num).toDouble() : null;
        final status = (value != null && (min != null || max != null))
            ? computeStatus(value, ReferenceRange(min: min, max: max))
            : '未判断';

        metrics.add(RecognizedMetric(
          rawName: (item['rawName'] ?? '').toString(),
          matchedMetricId: id,
          canonicalName: def?.metricName ?? (item['rawName'] ?? '').toString(),
          value: value ?? 0,
          unit: (item['unit'] ?? '').toString(),
          referenceMin: min,
          referenceMax: max,
          referenceText: (item['referenceText'] ?? '').toString(),
          status: status,
          originalStatus: item['originalStatus']?.toString(),
          bodySystem: bodySystemForMetric(id, fallback: '其他'),
          confidence: (item['confidence'] is num)
              ? (item['confidence'] as num).toDouble()
              : 1.0,
        ));
      }
    }

    return StructuredMedicalReport(
      hospitalName: (body['hospitalName'] ?? '').toString(),
      reportDate: _parseDate(body['reportDate']) ?? DateTime.now(),
      reportType: (body['reportType'] ?? '').toString(),
      patientName: (body['patientName'] ?? '').toString(),
      metrics: metrics,
      sourceImagePath: imagePath,
    );
  }

  DateTime? _parseDate(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      return DateTime.tryParse(v.trim());
    }
    return null;
  }
}
