import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_metadata.dart';
import '../services/report_ocr_service.dart';
import '../widgets/health_ui.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recognitionStatus =
        RemoteOcrService.isConfigured ? '已配置真实识别后端' : '未配置真实识别后端';
    return Scaffold(
      appBar: AppBar(title: const Text('关于健康档案')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const HealthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('健康档案',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary)),
                SizedBox(height: 8),
                Text(
                    '版本 ${AppMetadata.versionName}+${AppMetadata.versionCode}',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text(AppMetadata.buildLabel,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const HealthSectionHeader('功能状态'),
          HealthCard(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: Column(
              children: [
                const _StatusRow(
                  icon: CupertinoIcons.archivebox,
                  title: '本地备份恢复',
                  subtitle: '已启用：备份包包含本机健康数据和报告原图',
                  ok: true,
                ),
                _StatusRow(
                  icon: CupertinoIcons.doc_text_viewfinder,
                  title: '报告识别',
                  subtitle: recognitionStatus,
                  ok: RemoteOcrService.isConfigured,
                ),
                const _StatusRow(
                  icon: CupertinoIcons.cloud,
                  title: '云端备份',
                  subtitle: '本轮暂不启用，避免影响本机测试',
                  ok: false,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 20, 4, 4),
            child: Text(
              '上传或拍摄报告必须连接你自己的识别后端。未配置后端时，App 不会再生成演示数据。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return HealthRow(
      leading: Icon(icon,
          size: 20,
          color: ok ? AppColors.primary : AppColors.textSecondary),
      title: title,
      subtitle: subtitle,
      trailing: Dot(ok ? AppColors.normal : AppColors.insufficient, size: 8),
    );
  }
}
