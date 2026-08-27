import 'dart:typed_data';

/// Web 等无法写文件系统的平台：不落盘，返回 null（调用方仅本次会话预览）。
Future<String?> saveReportImageLocally(Uint8List bytes, String ext) async {
  return null;
}

/// Web 没有可列出的本地原图文件：始终为空。
Future<List<String>> listReportImagePaths() async => const [];

/// Web 无法清理本地原图目录：no-op。
Future<void> deleteReportImagesLocally() async {}

/// Web 未持久化报告原图：no-op。
Future<void> deleteManagedReportImage(String? path) async {}
