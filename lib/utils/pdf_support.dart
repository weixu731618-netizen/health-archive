import 'dart:typed_data';

import 'package:pdfx/pdfx.dart';

/// 判断文件名是不是 PDF（大小写不敏感）。
bool isPdfFileName(String fileName) =>
    fileName.trim().toLowerCase().endsWith('.pdf');

/// 一份 PDF 最多渲染多少页送去识别（多页体检报告足够，避免超大 PDF 拖垮）。
const int kPdfMaxPages = 10;

Future<Uint8List> _renderOnePage(PdfPage page, double targetWidth) async {
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
    throw StateError('PDF 页渲染结果为空');
  }
  return bytes;
}

/// 把 PDF 首页渲染成 PNG 字节，用于识别与预览。
/// 渲染失败（PDF 损坏、加密、平台不支持）时抛异常，调用方负责兜底。
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
      return await _renderOnePage(page, targetWidth);
    } finally {
      await page.close();
    }
  } finally {
    await document.close();
  }
}

/// 把 PDF 每一页都渲染成 PNG（最多 [kPdfMaxPages] 页），用于多页报告批量识别。
/// 至少渲染出首页；某页渲染失败则跳过该页，不整体失败。全部失败才抛异常。
Future<List<Uint8List>> renderPdfAllPagesToPng(
  Uint8List pdfBytes, {
  double targetWidth = 1600,
  int maxPages = kPdfMaxPages,
}) async {
  final document = await PdfDocument.openData(pdfBytes);
  try {
    final total = document.pagesCount;
    if (total < 1) {
      throw StateError('PDF 没有可渲染的页面');
    }
    final out = <Uint8List>[];
    for (var i = 1; i <= total && i <= maxPages; i++) {
      final page = await document.getPage(i);
      try {
        out.add(await _renderOnePage(page, targetWidth));
      } catch (_) {
        // 单页坏了就跳过，别让一页拖垮整份
      } finally {
        await page.close();
      }
    }
    if (out.isEmpty) {
      throw StateError('PDF 所有页都渲染失败');
    }
    return out;
  } finally {
    await document.close();
  }
}
