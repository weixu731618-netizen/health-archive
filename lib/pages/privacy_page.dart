import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../utils/report_image_save.dart';

/// 数据与隐私页（MVP）：导出健康数据（JSON） + 删除全部健康数据（二次确认）。
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    final repo = appRepository;
    if (repo == null) {
      _toast('数据库未就绪');
      return;
    }
    setState(() => _busy = true);
    try {
      final data = await repo.exportHealthData();
      final json = const JsonEncoder.withIndent('  ').convert(data);

      String? savedPath;
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          final dir = await getApplicationDocumentsDirectory();
          final folder = Directory(p.join(dir.path, 'exports'));
          if (!folder.existsSync()) folder.createSync(recursive: true);
          final file = File(p.join(
              folder.path, 'health_export_${DateTime.now().millisecondsSinceEpoch}.json'));
          await file.writeAsString(json, flush: true);
          savedPath = file.path;
        }
      } catch (_) {
        savedPath = null;
      }

      if (!mounted) return;
      if (savedPath != null) {
        _toast('已导出到：$savedPath');
      } else {
        await Clipboard.setData(ClipboardData(text: json));
        _toast('环境不支持写文件，健康数据已复制到剪贴板');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportAndShare() async {
    if (_busy) return;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _SetPasswordDialog(),
    );
    if (password == null) return; // 用户取消（区别于“跳过”，跳过会返回空字符串）
    setState(() => _busy = true);
    try {
      await localBackupService.exportAndShare(
        password: password.isEmpty ? null : password,
      );
      if (mounted) _toast('备份包已生成，请在分享面板里选择保存位置（微信/网盘等）');
    } catch (e) {
      if (mounted) _toast('备份失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreFromFile() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('从备份文件恢复'),
        content: const Text('选择一个之前导出的健康档案备份（.zip），将覆盖当前设备上的全部健康数据，是否继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('选择文件')),
        ],
      ),
    );
    if (confirmed != true) return;

    final path = await localBackupService.pickBackupFilePath();
    if (path == null) return;

    setState(() => _busy = true);
    try {
      String msg;
      try {
        msg = await localBackupService.restoreFromFile(path);
      } catch (e) {
        if (!_looksLikePasswordError(e)) rethrow;
        if (!mounted) return;
        final password = await showDialog<String>(
          context: context,
          builder: (_) => const _EnterPasswordDialog(),
        );
        if (password == null) {
          if (mounted) _toast('已取消恢复');
          return;
        }
        msg = await localBackupService.restoreFromFile(path, password: password);
      }
      if (mounted) _toast(msg);
    } catch (e) {
      if (mounted) _toast('恢复失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 粗略判断异常是否为“缺少密码/密码错误”：
  /// archive 包在密码为空或错误时会抛 password/null-check 相关的异常文案。
  bool _looksLikePasswordError(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('password') || s.contains('null check');
  }

  Future<void> _deleteAll() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAllDialog(),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      final repo = appRepository;
      if (repo != null) {
        await repo.clearAllHealthData();
      }
      await deleteReportImagesLocally();
      if (mounted) _toast('已删除全部健康数据');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据与隐私')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '健康档案属于长期数据。你可以将本地结构化数据导出备份，或彻底删除本机全部数据。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '提示：你在「上传报告 / 拍摄检查报告」中选择的图片，仅用于识别其中的检查指标。\n'
              '负责识别的 OCR/DeepSeek 服务运行在你的 FastAPI 后端，识别后 App 会先让你在确认页逐项核对，'
              '只有你点击「确认并保存」后，这些指标才写入本地健康档案。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '备份（推荐）',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          _Tile(
            icon: Icons.folder_zip_outlined,
            title: '完整备份并分享',
            subtitle: '打包全部数据与报告原图为一个文件，可设置密码保护，通过分享面板发到微信/网盘等自选渠道保存；不需要你自己部署服务器',
            onTap: _busy ? null : _exportAndShare,
          ),
          _Tile(
            icon: Icons.settings_backup_restore,
            title: '从备份文件恢复',
            subtitle: '选择之前导出的备份文件，恢复到本机（会覆盖当前数据）',
            danger: true,
            onTap: _busy ? null : _restoreFromFile,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              '其它',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          _Tile(
            icon: Icons.ios_share,
            title: '导出健康数据（纯文本）',
            subtitle: '导出指标、日常记录、报告、疾病史与用药记录（JSON，不含报告原图）',
            onTap: _busy ? null : _export,
          ),
          _Tile(
            icon: Icons.delete_forever,
            title: '删除全部健康数据',
            subtitle: '删除本机报告、指标、日常记录、疾病史、用药记录与原图，且无法恢复',
            danger: true,
            onTap: _busy ? null : _deleteAll,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        enabled: onTap != null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: danger ? AppColors.abnormal : AppColors.primary),
        title: Text(title,
            style: TextStyle(
                fontSize: 15,
                color: danger ? AppColors.abnormal : AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ),
    );
  }
}

/// 导出备份前询问是否设置密码。
/// 返回值：null=用户取消整个导出；空字符串=用户选择不加密；非空=用作 zip 密码。
class _SetPasswordDialog extends StatefulWidget {
  const _SetPasswordDialog();

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _ctrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _ctrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _hasInput => _ctrl.text.isNotEmpty || _confirmCtrl.text.isNotEmpty;
  bool get _matches => _ctrl.text == _confirmCtrl.text;
  bool get _canConfirm =>
      _ctrl.text.trim().isNotEmpty && _matches;

  @override
  Widget build(BuildContext context) {
    final showMismatch = _hasInput && _confirmCtrl.text.isNotEmpty && !_matches;
    return AlertDialog(
      title: const Text('给备份文件设置密码？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('设置密码后，这份备份文件即使被别人拿到也打不开；恢复时需要输入相同密码。不设置则文件不加密。'),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '设置密码（可留空）',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '再次输入密码确认',
              errorText: showMismatch ? '两次密码不一致' : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('跳过（不加密）'),
        ),
        FilledButton(
          onPressed: _canConfirm ? () => Navigator.pop(context, _ctrl.text.trim()) : null,
          child: const Text('设置密码并继续'),
        ),
      ],
    );
  }
}

/// 从加密备份恢复时，提示输入密码。返回 null 表示用户取消。
class _EnterPasswordDialog extends StatefulWidget {
  const _EnterPasswordDialog();

  @override
  State<_EnterPasswordDialog> createState() => _EnterPasswordDialogState();
}

class _EnterPasswordDialogState extends State<_EnterPasswordDialog> {
  final _ctrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('这份备份文件已加密'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('请输入导出时设置的密码。'),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '密码',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('取消')),
        FilledButton(
          onPressed: _ctrl.text.isEmpty ? null : () => Navigator.pop(context, _ctrl.text),
          child: const Text('确认'),
        ),
      ],
    );
  }
}

class DeleteAllDialog extends StatefulWidget {
  const DeleteAllDialog({super.key});

  @override
  State<DeleteAllDialog> createState() => _DeleteAllDialogState();
}

class _DeleteAllDialogState extends State<DeleteAllDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final can = _ctrl.text.trim() == '删除';
    return AlertDialog(
      title: const Text('删除全部健康数据'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              '此操作将删除本机保存的检查报告、健康指标、日常记录、疾病史和用药记录，且无法恢复。'),
          const SizedBox(height: 8),
          const Text('输入「删除」以确认。'),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(hintText: '删除'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
        TextButton(
          onPressed: can ? () => Navigator.pop(context, true) : null,
          child: const Text('删除'),
        ),
      ],
    );
  }
}
