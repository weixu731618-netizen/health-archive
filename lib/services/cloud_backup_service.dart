import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../main.dart';
import '../utils/report_image_save.dart';
import 'identity_service.dart';
import 'snapshot_importer.dart';

/// 云端备份/恢复客户端（V0.5，进阶可选项）。
///
/// 需要你自己部署一套 backend/（FastAPI + 数据库 + 对象存储）并把
/// REPORT_API_BASE 指向它，才会真正生效；未配置时页面会提示「离线模式」，
/// 不影响 App 其它功能。个人/小范围使用更推荐 [LocalBackupService]
/// （见 local_backup_service.dart）：导出打包成 zip 后用系统分享面板
/// 发到微信/网盘等自选渠道，不用自己运维服务器。
///
/// 整体备份：把本地 Drift 数据组装成 JSON 快照 + 报告原图文件，上传到当前匿名用户。
/// 整体恢复：下载最新备份快照，覆盖/重建本地 Drift（图片暂不随云端恢复，见 HANDOVER 已知限制）。
class CloudBackupService {
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');
  static const Duration _timeout = Duration(seconds: 30);

  final IdentityService identity;

  CloudBackupService({required this.identity});

  bool get isConfigured => _apiBase.isNotEmpty;

  /// 组装本地数据为备份快照（复用 repository.exportHealthData）。
  /// reports 里补充 sourceImagePath；需上传的报告原图在 snapshot["reportFiles"]声明。
  Future<Map<String, dynamic>> composeSnapshot() async {
    final repo = appRepository;
    if (repo == null) throw StateError('数据库未就绪');
    final snapshot = await repo.exportHealthData();
    return snapshot;
  }

  /// 备份：上传 JSON 快照 + 报告原图。
  Future<bool> backup({Map<String, dynamic>? snapshot}) async {
    if (!isConfigured) throw StateError('未配置后端地址');
    final finalSnapshot = snapshot ?? await composeSnapshot();
    final headers = await identity.authHeaders();
    if (headers.isEmpty) throw StateError('未登录');

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$_apiBase/api/backup'),
    )..headers.addAll(headers);

    // 报告原图：只上传存在本地文件路径的
    final reportFiles = <Map<String, dynamic>>[];
    final reports = (finalSnapshot['reports'] as List? ?? []).cast<Map<String, dynamic>>();
    for (final r in reports) {
      final path = r['sourceImagePath'];
      if (path is String && path.isNotEmpty && File(path).existsSync()) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final fileId = 'report-${r['id']}';
        reportFiles.add({
          'fileId': fileId,
          'localReportId': r['id'],
          'mime': 'image/jpeg',
          'size': bytes.length,
        });
        req.files.add(http.MultipartFile.fromBytes(
          'files',
          bytes,
          filename: '$fileId.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ));
      }
    }
    final cleanedReports =
        reports.map((r) => Map<String, dynamic>.from(r)..remove('sourceImagePath')).toList();
    finalSnapshot['reports'] = cleanedReports;
    finalSnapshot['reportFiles'] = reportFiles;

    req.fields['data'] = jsonEncode(finalSnapshot);
    try {
      final streamed = await req.send().timeout(_timeout);
      final resp = await http.Response.fromStream(streamed).timeout(_timeout);
      if (resp.statusCode == 200) {
        await identity.setLastBackupAt(DateTime.now().toIso8601String());
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 拉取最新备份快照；无备份返回 null。
  Future<Map<String, dynamic>?> fetchLatest() async {
    if (!isConfigured) return null;
    final headers = await identity.authHeaders();
    if (headers.isEmpty) return null;
    try {
      final resp = await http
          .get(Uri.parse('$_apiBase/api/backup/latest'), headers: headers)
          .timeout(_timeout);
      if (resp.statusCode != 200) return null;
      final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      if (body['hasBackup'] != true) return null;
      return (body['snapshot'] as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  /// 恢复：用最新备份覆盖/重建本地 Drift。返回恢复的状态说明。
  Future<String> restore() async {
    final snapshot = await fetchLatest();
    if (snapshot == null) return '云端没有可恢复的备份';
    final repo = appRepository;
    if (repo == null) throw StateError('数据库未就绪');
    // 云端快照不含图片文件，恢复后报告记录会缺原图（已知限制）。
    final result = await SnapshotImporter.restore(repo, snapshot);
    // 恢复成功后旧报告已被云端快照取代、且不带回原图，
    // 之前遗留在本地的原图文件不再对应任何数据，清理避免残留占用存储。
    if (result == '恢复成功') {
      await deleteReportImagesLocally();
    }
    return result;
  }
}
