import 'dart:typed_data';

import 'package:pdfx/pdfx.dart';

/// 判断文件名是不是 PDF（大小写不敏感）。
bool isPdfFileName(String fileName) =>
    fileName.trim().toLowerCase().endsWith('.pdf');

/// 把 PDF 首页渲染成 PNG 字节，用于识别与预览。
///
/// A3 只处理首页——单页化验单 / 单页影像报告是最常见的情况；多页体检报告的
/// 「一份 PDF → 几十项指标批量入库」放到 A4。渲染失败（PDF 损坏、加密、平台不支持）
/// 时抛异常，调用方负责兜底（提示用户改用截图，或在影像报告里手动补文字）。
Future<Uint8List> renderPdfFirstPageToPng(
  Uint8List pdfBytes, {
  double targetWidth = 1600,
}) async {
  final document = await PdfDocument.openData(pdfBytes);
  try {
    if (document.pagesCount < 1) {
      throw StateError('PDF 没有可渲染的页面');
    }
    final page = await document.getPage(1);
    try {
      final baseWidth = page.width <= 0 ? targetWidth / 2 : page.width;
      final scale = (targetWidth / baseWidth).clamp(1.0, 4.0);
      final image = await page.render(
        width: page.width * scale,
        height: page.height * scale,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );
      final bytes = image?.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('PDF 首页渲染结果为空');
      }
      return bytes;
    } finally {
      await page.close();
    }
  } finally {
    await document.close();
  }
}
