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
          _Tile(
            icon: Icons.ios_share,
            title: '导出健康数据',
            subtitle: '导出指标、日常记录、报告、疾病史与用药记录（JSON）',
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
