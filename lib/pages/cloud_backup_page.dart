import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../widgets/health_ui.dart';

/// 云端备份 / 账号页（V0.5 匿名方案）。
class CloudBackupPage extends StatefulWidget {
  const CloudBackupPage({super.key});

  @override
  State<CloudBackupPage> createState() => _CloudBackupPageState();
}

class _CloudBackupPageState extends State<CloudBackupPage> {
  bool _loading = true;
  bool _busy = false;
  String? _token;
  String? _userId;
  String? _recovery;
  bool _showRecovery = false;
  String? _lastBackup;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await identityService.getAuthToken();
    final userId = await identityService.getUserId();
    final recovery = await identityService.getRecoveryCode();
    final lastBackup = await identityService.getLastBackupAt();
    if (mounted) {
      setState(() {
        _token = token;
        _userId = userId;
        _recovery = recovery;
        _lastBackup = lastBackup;
        _loading = false;
      });
    }
    // 未注册则尝试自动注册（本地无 token 且后端已配置）
    if (token == null && cloudBackupService.isConfigured) {
      final ok = await identityService.ensureIdentity();
      if (ok && mounted) _load();
    }
  }

  bool get _loggedIn => (_token ?? '').isNotEmpty;

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  String get _shortId =>
      _userId == null || _userId!.length < 8 ? '' : _userId!.substring(0, 8);

  Future<void> _copyRecovery() async {
    if (_recovery == null) return;
    await Clipboard.setData(ClipboardData(text: _recovery!));
    _toast('已复制恢复码');
  }

  Future<void> _doBackup() async {
    setState(() => _busy = true);
    try {
      final ok = await cloudBackupService.backup();
      if (!mounted) return;
      _toast(ok ? '备份成功' : '备份失败，请检查网络或后端');
      _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doRestore() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('从云端恢复'),
        content: const Text('恢复云端数据可能覆盖当前设备中的健康档案，是否继续？'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('恢复')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      final msg = await cloudBackupService.restore();
      if (mounted) _toast(msg);
    } catch (e) {
      if (mounted) _toast('恢复失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String content, String action) async {
    final r = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(action)),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _deleteCloudData() async {
    final ok = await _confirm(
      '删除云端备份',
      '将删除当前账号在云端的健康数据与报告文件，但保留账号与恢复码。继续？',
      '删除',
    );
    if (!ok) return;
    if (!_loggedIn) return;
    final headers = await identityService.authHeaders();
    final r = await CloudBackupServiceClient().deleteData(headers);
    _toast(r ? '已删除云端数据' : '删除失败');
  }

  Future<void> _deleteAccount() async {
    final ok = await _confirm(
      '彻底删除匿名档案',
      '将永久删除云端健康数据、报告文件、账号与恢复码，且无法恢复。继续？',
      '彻底删除',
    );
    if (!ok) return;
    if (!_loggedIn) return;
    final headers = await identityService.authHeaders();
    final r = await CloudBackupServiceClient().deleteAccount(headers);
    if (r) {
      await identityService.deleteLocalIdentity();
      _toast('已注销');
      _load();
    } else {
      _toast('删除失败');
    }
  }

  Future<void> _logout() async {
    await identityService.deleteLocalIdentity();
    _toast('已退出登录（下次启动会创建新的匿名档案）');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账号与云端备份')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              children: [
                const HealthSectionHeader('匿名档案',
                    padding: EdgeInsets.fromLTRB(4, 8, 4, 10)),
                _stateTile(
                  icon: CupertinoIcons.person,
                  title: '当前状态',
                  subtitle: !cloudBackupService.isConfigured
                      ? '未配置后端（离线模式，仅本地）'
                      : _loggedIn
                          ? '已登录 · 档案 $_shortId'
                          : '未登录',
                ),
                if (_lastBackup != null)
                  _stateTile(
                    icon: CupertinoIcons.clock,
                    title: '上次备份',
                    subtitle: _lastBackup!,
                  ),
                const HealthSectionHeader('恢复码'),
                if (_recovery != null) ...[
                  _stateTile(
                    icon: CupertinoIcons.lock,
                    title: '我的恢复码',
                    subtitle: _showRecovery ? _recovery! : '点击查看（用于换机/重装恢复）',
                    onTap: () => setState(() => _showRecovery = true),
                  ),
                  if (_showRecovery)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '恢复码用于更换手机或重新安装后恢复你的健康档案。请妥善保存，不要分享给他人。',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.warning),
                            ),
                          ),
                          CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              minimumSize: const Size(0, 32),
                              onPressed: _copyRecovery,
                              child: const Text('复制',
                                  style: TextStyle(fontSize: 13))),
                        ],
                      ),
                    ),
                ],
                const HealthSectionHeader('云端备份'),
                _actionTile(
                  icon: CupertinoIcons.cloud_upload,
                  title: '立即备份',
                  subtitle: '上传本地健康档案到云端',
                  onTap: _busy ? null : _doBackup,
                  enabled: _loggedIn,
                ),
                _actionTile(
                  icon: CupertinoIcons.cloud_download,
                  title: '从云端恢复',
                  subtitle: '下载云端备份覆盖本地（需确认）',
                  onTap: _busy ? null : _doRestore,
                  enabled: _loggedIn,
                ),
                const HealthSectionHeader('数据管理'),
                _actionTile(
                  icon: CupertinoIcons.delete,
                  title: '删除云端备份',
                  subtitle: '删除云端数据与文件，保留账号',
                  danger: true,
                  onTap: _busy ? null : _deleteCloudData,
                  enabled: _loggedIn,
                ),
                _actionTile(
                  icon: CupertinoIcons.delete_solid,
                  title: '彻底删除匿名档案',
                  subtitle: '删除云端数据、文件、账号与恢复码',
                  danger: true,
                  onTap: _busy ? null : _deleteAccount,
                  enabled: _loggedIn,
                ),
                _actionTile(
                  icon: CupertinoIcons.square_arrow_left,
                  title: '退出登录',
                  subtitle: '清除本机身份（不删除云端）',
                  onTap: _busy ? null : _logout,
                  enabled: _loggedIn,
                ),
              ],
            ),
    );
  }

  Widget _stateTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HealthCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: HealthRow(
          leading:
              Icon(icon, size: 20, color: AppColors.primary),
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool danger = false,
    bool enabled = true,
  }) {
    final tint = danger ? AppColors.abnormal : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HealthCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: HealthRow(
          leading: Icon(icon,
              size: 20,
              color: enabled ? tint : AppColors.insufficient),
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }
}

/// 云端数据/账号 删除的轻量客户端（不依赖全局 cloudBackupService）。
class CloudBackupServiceClient {
  static const String _apiBase = String.fromEnvironment('REPORT_API_BASE');
  Future<bool> deleteData(Map<String, String> headers) async {
    if (_apiBase.isEmpty) return false;
    final r = await httpDelete('$_apiBase/api/backup/data', headers);
    return r;
  }

  Future<bool> deleteAccount(Map<String, String> headers) async {
    if (_apiBase.isEmpty) return false;
    return httpDelete('$_apiBase/api/backup/account', headers);
  }

  Future<bool> httpDelete(String url, Map<String, String> headers) async {
    try {
      final resp = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 20));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
