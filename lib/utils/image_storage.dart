import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'report_image_save.dart';

/// 用户选择化验单图片的结果。
class PickedReportImage {
  final Uint8List bytes;
  final String fileName;
  final String? path; // 落盘后的绝对路径；Web 或无落盘能力时为 null
  final String mimeType; // 如 image/jpeg

  const PickedReportImage({
    required this.bytes,
    required this.fileName,
    this.path,
    this.mimeType = 'image/jpeg',
  });
}

/// 选择一张图片（JPG/JPEG/PNG）。失败时抛出异常。
/// - 移动端（Android/iOS）：把图片字节复制到应用文档目录，返回落盘路径。
/// - Web 等无法写文件系统的平台：不落盘，返回 path=null（仅本次会话可预览）。
Future<PickedReportImage> pickLabReportImage() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
  );
  if (file == null) {
    throw StateError('未选择文件');
  }
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('无法读取该图片');
  }
  final ext = p.extension(file.name).isEmpty ? '.jpg' : p.extension(file.name);

  // 尝试落盘；失败（含 Web 不可写平台）则仅保留字节做会话内预览，不崩溃。
  String? savedPath;
  try {
    savedPath = await saveReportImageLocally(bytes, ext);
  } catch (_) {
    savedPath = null;
  }
  return PickedReportImage(
    bytes: bytes,
    fileName: file.name,
    path: savedPath,
  );
}

/// 拍照获取化验单图片（V0.4B）。
/// 仅移动端（Android/iOS）调用相机；Web/桌面调用会抛出一个明确提示的异常。
/// 拍照得到的图片会与「上传」一样落盘（返回 [PickedReportImage]），随后进入同一识别流程。
Future<PickedReportImage> captureLabReportImage() async {
  // image_picker 在支持的平台上调用系统相机；Web 上会使用文件上传（capture），
  // 若不希望 Web 走相机，可在 Web 端返回错误提示。
  final picked = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 4096,
    maxHeight: 4096,
    imageQuality: 92,
  );
  if (picked == null) {
    throw StateError('未拍摄图片');
  }
  final bytes = await picked.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('无法读取该图片');
  }
  final ext = p.extension(picked.name).isEmpty ? '.jpg' : p.extension(picked.name);

  // 尝试落盘；失败则仅保留字节做会话内预览。
  String? savedPath;
  try {
    savedPath = await saveReportImageLocally(bytes, ext);
  } catch (_) {
    savedPath = null;
  }
  return PickedReportImage(
    bytes: bytes,
    fileName: picked.name,
    path: savedPath,
    mimeType: 'image/jpeg',
  );
}
