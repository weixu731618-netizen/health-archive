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
