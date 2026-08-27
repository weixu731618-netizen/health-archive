import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 把报告原图字节落盘到应用文档目录，返回绝对路径。
/// 失败时抛出异常由调用方捕获（调用方会退化为“仅会话预览”，不崩溃）。
Future<String> saveReportImageLocally(Uint8List bytes, String ext) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'report_images'));
  if (!folder.existsSync()) {
    folder.createSync(recursive: true);
  }
  final name =
      'report_${DateTime.now().millisecondsSinceEpoch}_${_randSuffix()}$ext';
  final file = File(p.join(folder.path, name));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

String _randSuffix() =>
    Random().nextInt(0xFFFFFF).toRadixString(16) +
    Random().nextInt(0xFFFFFF).toRadixString(16);

/// 列出 report_images 目录下当前所有原图文件的绝对路径。
/// 用于备份恢复前记录“旧文件”，恢复成功后据此清理，避免残留。
Future<List<String>> listReportImagePaths() async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'report_images'));
  if (!folder.existsSync()) return const [];
  return folder.listSync().whereType<File>().map((f) => f.path).toList();
}

/// 删除 report_images 目录下所有原图（用于“删除全部健康数据”）。
Future<void> deleteReportImagesLocally() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'report_images'));
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  } catch (_) {
    // 删除失败不向外抛，交由上层提示
  }
}

/// 删除单张由本 App 管理的报告原图。
///
/// 只允许删除应用文档目录下 report_images 文件夹内的文件，避免误删用户设备上的
/// 外部文件。用于用户取消核对时清理已经提前落盘的临时报告图片。
Future<void> deleteManagedReportImage(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'report_images'));
    final file = File(path);
    final folderPath = p.normalize(folder.path);
    final filePath = p.normalize(file.path);
    final insideManagedFolder =
        filePath == folderPath || filePath.startsWith('$folderPath${p.separator}');
    if (insideManagedFolder && file.existsSync()) {
      await file.delete();
    }
  } catch (_) {
    // 清理失败不影响用户继续使用；后续全量清理仍会处理 report_images。
  }
}
