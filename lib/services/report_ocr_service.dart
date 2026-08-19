import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// 一行 OCR 文字（含在图片上的位置）。
class OcrLine {
  final String text;
  final int left;
  final int top;
  final int width;
  final int height;

  const OcrLine({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// OCR 服务统一接口：图片 -> 行级文字。
/// Flutter 只调用自有 FastAPI（POST /api/report/ocr），不直接调第三方 OCR。
abstract class ReportOcrService {
  Future<List<OcrLine>> ocrImage({
    required Uint8List imageBytes,
    required String fileName,
  });
}

/// 远程 OCR 服务：上传图片到自有后端，返回行级文字。
///
/// 后端地址来自编译期变量 REPORT_API_BASE（`flutter run --dart-define=REPORT_API_BASE=https://…`）；
/// 未配置时不发起任何 HTTP，直接抛「后端未配置」。
class RemoteOcrService implements ReportOcrService {
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');
  static const Duration _timeout = Duration(seconds: 30);

  /// 是否已配置后端地址（供前端决定走真实 OCR 还是 Mock 流程）。
  static bool get isConfigured => _apiBase.isNotEmpty;

  @override
  Future<List<OcrLine>> ocrImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (_apiBase.isEmpty) {
      throw StateError('识别后端未配置（REPORT_API_BASE）');
    }
    final uri = Uri.parse('$_apiBase/api/report/ocr');
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
      // 尝试读后端 detail
      String detail = 'OCR 调用失败';
      try {
        final obj = jsonDecode(utf8.decode(response.bodyBytes));
        if (obj is Map && obj['detail'] is String) detail = obj['detail'] as String;
      } catch (_) {}
      throw StateError(detail);
    }

    final dynamic body = jsonDecode(utf8.decode(response.bodyBytes));
    final result = <OcrLine>[];
    if (body is Map && body['words'] is List) {
      for (final item in body['words'] as List) {
        if (item is! Map) continue;
        result.add(OcrLine(
          text: (item['text'] ?? '').toString(),
          left: (item['left'] is num) ? (item['left'] as num).toInt() : 0,
          top: (item['top'] is num) ? (item['top'] as num).toInt() : 0,
          width: (item['width'] is num) ? (item['width'] as num).toInt() : 0,
          height: (item['height'] is num) ? (item['height'] as num).toInt() : 0,
        ));
      }
    }
    return result;
  }
}
