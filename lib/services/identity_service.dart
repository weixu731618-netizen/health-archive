import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 匿名身份服务（V0.5）：
/// 首次启动自动调 /api/anonymous/register 创建匿名用户，安全保存 authToken / recoveryCode。
/// 后端地址来自编译期变量 REPORT_API_BASE。
/// 注意：token / 恢复码不打印到日志，不在代码库写死。
class IdentityService {
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kRecovery = 'recovery_code';
  static const _kLastBackup = 'last_backup_at';
  static const Duration _timeout = Duration(seconds: 20);

  static bool get isBackendConfigured => _apiBase.isNotEmpty;

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<String?> _read(String key) async {
    try {
      if (kIsWeb) return (await SharedPreferences.getInstance()).getString(key);
      return await _secure.read(key: key);
    } catch (_) {
      // 安全存储不可用时不抛异常（避免 App 启动闪退），按“无身份”处理
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      if (kIsWeb) {
        (await SharedPreferences.getInstance()).setString(key, value);
      } else {
        await _secure.write(key: key, value: value);
      }
    } catch (_) {
      // 写入失败静默忽略（不因安全存储问题崩溃）
    }
  }

  Future<void> _delete(String key) async {
    try {
      if (kIsWeb) {
        (await SharedPreferences.getInstance()).remove(key);
      } else {
        await _secure.delete(key: key);
      }
    } catch (_) {
      // 忽略
    }
  }

  /// 确保存在本地匿名身份；没有时自动向后端注册。
  /// 任何异常（含安全存储、网络）都被捕获，绝不向上抛导致 App 启动闪退。
  Future<bool> ensureIdentity() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) return true;
      if (!isBackendConfigured) return false; // 未配置后端：离线模式
      final resp = await http
          .post(Uri.parse('$_apiBase/api/anonymous/register'))
          .timeout(_timeout);
      if (resp.statusCode != 200) return false;
      final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      await _write(_kToken, body['authToken'] as String);
      await _write(_kUserId, body['userId'] as String);
      final recovery = body['recoveryCode'] as String?;
      if (recovery != null && recovery.isNotEmpty) {
        await _write(_kRecovery, recovery);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getAuthToken() => _read(_kToken);
  Future<String?> getUserId() => _read(_kUserId);
  Future<String?> getRecoveryCode() => _read(_kRecovery);

  Future<String?> getLastBackupAt() => _read(_kLastBackup);
  Future<void> setLastBackupAt(String iso) => _write(_kLastBackup, iso);

  /// 身份请求头。
  Future<Map<String, String>> authHeaders() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  /// 用恢复码找回原账号并保存新 token。
  Future<bool> recover({required String recoveryCode}) async {
    if (!isBackendConfigured) return false;
    try {
      final resp = await http
          .post(
            Uri.parse('$_apiBase/api/anonymous/recover'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'recoveryCode': recoveryCode}),
          )
          .timeout(_timeout);
      if (resp.statusCode != 200) return false;
      final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      await _write(_kToken, body['authToken'] as String);
      await _write(_kUserId, body['userId'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 删除本地身份（退出/清除本地档案），不动云端。
  Future<void> deleteLocalIdentity() async {
    await _delete(_kToken);
    await _delete(_kUserId);
    await _delete(_kRecovery);
    await _delete(_kLastBackup);
  }
}
