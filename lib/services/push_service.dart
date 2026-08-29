import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// B2：远程推送（iOS APNs）客户端骨架。
///
/// 「代码优先、配置后补」：
/// - 是否启用由编译期变量 `PUSH_ENABLED` 控制，默认 **false**。未启用时所有方法安全空转。
/// - 后端地址复用 `REPORT_API_BASE`。未配置时不上传，只在本地保存 token。
/// - 设备身份用一次性生成的匿名 `installation_id`（存 SharedPreferences），不依赖账号。
/// - 真实 APNs 证书 / Key 等 Apple 侧配置在 **后端** 的 .env 里；客户端只负责
///   拿到 APNs device token 并上传，见 `IOS_PUSH_SETUP.md`。
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const bool pushEnabled =
      bool.fromEnvironment('PUSH_ENABLED', defaultValue: false);
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');

  static const MethodChannel _channel = MethodChannel('health_archive/push');

  static const String _kInstallationIdKey = 'push_installation_id';
  static const String _kLastTokenKey = 'push_last_apns_token';
  static const String _kLastUploadedKey = 'push_last_uploaded_token';

  String? _apnsToken;
  String? get apnsToken => _apnsToken;

  bool get isConfigured => pushEnabled && _apiBase.isNotEmpty;

  /// App 启动时调用：装好原生回调，若已启用则触发 APNs 注册。
  Future<void> init() async {
    _channel.setMethodCallHandler(_onNativeCall);
    if (!pushEnabled) {
      debugPrint('PushService: PUSH_ENABLED=false，跳过远程推送注册');
      return;
    }
    if (!(Platform.isIOS || Platform.isMacOS)) return;
    try {
      // 恢复上次的 token（离线也能先展示状态）。
      final prefs = await SharedPreferences.getInstance();
      _apnsToken = prefs.getString(_kLastTokenKey);
      await _channel.invokeMethod<void>('registerForRemoteNotifications');
    } catch (e) {
      debugPrint('PushService.init failed: $e');
    }
  }

  Future<String> installationId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kInstallationIdKey);
    if (id == null || id.isEmpty) {
      id = _randomId();
      await prefs.setString(_kInstallationIdKey, id);
    }
    return id;
  }

  Future<void> _onNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onApnsToken':
        final token = call.arguments as String?;
        if (token == null || token.isEmpty) return;
        _apnsToken = token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kLastTokenKey, token);
        await _uploadToken(token);
        break;
      case 'onApnsError':
        debugPrint('PushService: APNs 注册失败：${call.arguments}');
        break;
    }
  }

  /// 把 device token 上传到后端。后端未配置或未启用时安全跳过。
  Future<void> _uploadToken(String token) async {
    if (!isConfigured) {
      debugPrint('PushService: 未配置后端地址，token 仅本地保存');
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_kLastUploadedKey) == token) return; // 没变，不重复传
      final resp = await http
          .post(
            Uri.parse('$_apiBase/api/push/device-tokens'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'installation_id': await installationId(),
              'token': token,
              'platform': Platform.isIOS ? 'ios' : 'macos',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await prefs.setString(_kLastUploadedKey, token);
        debugPrint('PushService: device token 已上传');
      } else {
        debugPrint('PushService: 上传 token 失败 ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('PushService: 上传 token 异常：$e');
    }
  }

  /// 注销本设备的推送（如用户在设置里关掉）。
  Future<void> unregister() async {
    if (!isConfigured) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await http
          .delete(
            Uri.parse('$_apiBase/api/push/device-tokens'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'installation_id': await installationId()}),
          )
          .timeout(const Duration(seconds: 10));
      await prefs.remove(_kLastUploadedKey);
    } catch (e) {
      debugPrint('PushService.unregister failed: $e');
    }
  }

  String _randomId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = (now * 2862933555777941757 + 3037000493) & 0x7fffffffffffffff;
    return 'inst_${now.toRadixString(16)}${rand.toRadixString(16)}';
  }
}
