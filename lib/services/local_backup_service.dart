import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../utils/report_image_save.dart';
import 'snapshot_importer.dart';

/// 免服务器的本地完整备份（V0.5.1）。
///
/// 把本地健康数据 + 报告原图打包成一个 zip 文件，通过系统分享面板发到
/// 微信文件传输助手 / 网盘 App / AirDrop 等任意用户自选渠道保存；
/// 恢复时选回这个 zip 文件即可，不需要你自己部署和维护后端服务器。
/// 与 [CloudBackupService]（需要自建后端）是两条独立、互不影响的备份路径。
class LocalBackupService {
  static const String _dataEntryName = 'data.json';
  static const String _imagesPrefix = 'images/';

  // 防止损坏/构造过的 zip 造成解压炸弹式内存占用：
  // 压缩包本身、条目数、单条目解压后大小、整体解压后总大小都设上限。
  static const int _maxZipFileBytes = 300 * 1024 * 1024; // 300MB
  static const int _maxArchiveEntries = 5000;
  static const int _maxEntryUncompressedBytes = 50 * 1024 * 1024; // 50MB
  static const int _maxTotalUncompressedBytes = 500 * 1024 * 1024; // 500MB

  /// 组装 zip 备份包并写入本地文件，返回文件路径。
  /// [password] 非空时用 AES 加密整个 zip；恢复时需要提供相同密码。
  Future<String> exportBundle({String? password}) async {
    final repo = appRepository;
    if (repo == null) throw StateError('数据库未就绪');
    final snapshot = await repo.exportHealthData();

    final archive = Archive();
    final reports =
        (snapshot['reports'] as List? ?? []).cast<Map<String, dynamic>>();
    for (final r in reports) {
      final path = r['sourceImagePath'];
      if (path is String && path.isNotEmpty && File(path).existsSync()) {
        final bytes = await File(path).readAsBytes();
        final ext = p.extension(path).isEmpty ? '.jpg' : p.extension(path);
        archive.addFile(ArchiveFile(
          '${_imagesPrefix}report_${r['id']}$ext',
          bytes.length,
          bytes,
        ));
      }
    }
    // 备份文件里不保留本机绝对路径（换机后路径必然失效，也没必要泄露本机目录结构）。
    final cleanedReports = reports
        .map((r) => Map<String, dynamic>.from(r)..remove('sourceImagePath'))
        .toList();
    snapshot['reports'] = cleanedReports;

    final jsonBytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot));
    archive.addFile(ArchiveFile(_dataEntryName, jsonBytes.length, jsonBytes));

    final zipBytes = ZipEncoder(password: password).encode(archive);
    if (zipBytes == null) throw StateError('打包备份文件失败');
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'exports'));
    if (!folder.existsSync()) folder.createSync(recursive: true);
    final file = File(p.join(folder.path,
        'health_archive_backup_${DateTime.now().millisecondsSinceEpoch}.zip'));
    await file.writeAsBytes(zipBytes, flush: true);
    return file.path;
  }

  /// 唤起系统分享面板，把备份文件发到用户自选的 App（微信/网盘/邮件等）。
  Future<void> shareBundle(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: '健康档案备份'),
    );
  }

  /// 导出并立即分享，一步到位。返回文件路径。
  Future<String> exportAndShare({String? password}) async {
    final path = await exportBundle(password: password);
    await shareBundle(path);
    return path;
  }

  /// 弹出系统文件选择器，选一个之前导出的 zip 备份文件。
  /// 返回 null 表示用户取消了选择。
  Future<String?> pickBackupFilePath() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    return file?.path;
  }

  /// 从指定 zip 备份文件恢复（覆盖本地数据，调用方需先弹二次确认）。
  /// [password] 为空时按未加密文件处理；若文件本身未加密，传入密码也不影响解压。
  Future<String> restoreFromFile(String filePath, {String? password}) async {
    final repo = appRepository;
    if (repo == null) throw StateError('数据库未就绪');

    final zipFile = File(filePath);
    final zipLength = await zipFile.length();
    if (zipLength > _maxZipFileBytes) {
      throw const FormatException('备份文件过大，可能已损坏或不是有效的备份包');
    }

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes, password: password);
    if (archive.files.length > _maxArchiveEntries) {
      throw const FormatException('备份文件内容异常（条目数过多），可能已损坏');
    }

    // 解压前先按 ZIP 头部记录的大小做体积校验，再真正触发解压（访问 .content），
    // 避免损坏或被构造过的 zip 在解压阶段撑爆内存。
    ArchiveFile? dataFile;
    var totalUncompressedBytes = 0;
    for (final f in archive.files) {
      if (!f.isFile) continue;
      totalUncompressedBytes += f.size;
      if (f.size > _maxEntryUncompressedBytes ||
          totalUncompressedBytes > _maxTotalUncompressedBytes) {
        throw const FormatException('备份文件内容异常（解压后体积超出限制），可能已损坏或被篡改');
      }
      if (f.name == _dataEntryName) {
        dataFile = f;
      }
    }
    if (dataFile == null) {
      throw const FormatException('不是有效的健康档案备份文件（缺少 data.json）');
    }
    final snapshot = jsonDecode(utf8.decode(dataFile.content as List<int>))
        as Map<String, dynamic>;

    // 记录恢复前已存在的本地报告原图，恢复成功后清理，避免每次
    // 「删除全部数据 -> 从备份恢复」的往返都在 report_images/ 里残留一份旧图片。
    final imagesBeforeRestore = await listReportImagePaths();

    // 把包内图片落盘，建立「旧报告本地 id -> 新图片路径」映射
    final reportImagePaths = <String, String>{};
    final newlySavedPaths = <String>[];
    final idPattern = RegExp(r'report_(\d+)');
    for (final f in archive.files) {
      if (!f.isFile || !f.name.startsWith(_imagesPrefix)) continue;
      final base = p.basenameWithoutExtension(f.name);
      final match = idPattern.firstMatch(base);
      if (match == null) continue;
      final content = f.content as List<int>;
      // Web 等平台无法落盘（saveReportImageLocally 返回 null），此时跳过，
      // 恢复后该报告不带原图，但不影响其它数据正常恢复。
      final savedPath = await saveReportImageLocally(
        Uint8List.fromList(content),
        p.extension(f.name),
      );
      // ignore: unnecessary_null_comparison
      if (savedPath != null) {
        reportImagePaths[match.group(1)!] = savedPath;
        newlySavedPaths.add(savedPath);
      }
    }

    try {
      final result = await SnapshotImporter.restore(repo, snapshot,
          reportImagePaths: reportImagePaths);
      // 恢复成功：旧数据已被新快照取代，清理恢复前遗留的原图文件。
      for (final path in imagesBeforeRestore) {
        await deleteManagedReportImage(path);
      }
      return result;
    } catch (e) {
      // 恢复失败：数据库已在同一事务内回滚到恢复前状态，清理这次新落盘
      // 但未被任何数据引用的图片，避免残留垃圾文件。
      for (final path in newlySavedPaths) {
        await deleteManagedReportImage(path);
      }
      rethrow;
    }
  }
}
