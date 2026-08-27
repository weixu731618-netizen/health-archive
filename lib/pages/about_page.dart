import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_metadata.dart';
import '../services/report_ocr_service.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recognitionStatus =
        RemoteOcrService.isConfigured ? '已配置真实识别后端' : '未配置真实识别后端';
    return Scaffold(
      appBar: AppBar(title: const Text('关于健康档案')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '健康档案',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '版本 ${AppMetadata.versionName}+${AppMetadata.versionCode}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppMetadata.buildLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _StatusTile(
            icon: Icons.folder_zip_outlined,
            title: '本地备份恢复',
            subtitle: '已启用：备份包包含本机健康数据和报告原图',
            ok: true,
          ),
          _StatusTile(
            icon: Icons.document_scanner_outlined,
            title: '报告识别',
            subtitle: recognitionStatus,
            ok: RemoteOcrService.isConfigured,
          ),
          const _StatusTile(
            icon: Icons.cloud_off_outlined,
            title: '云端备份',
            subtitle: '本轮暂不启用，避免影响本机测试',
            ok: false,
          ),
          const SizedBox(height: 12),
          const Text(
            '说明',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '上传或拍摄报告必须连接你自己的识别后端。未配置后端时，App 不会再生成演示数据。',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;

  const _StatusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading:
            Icon(icon, color: ok ? AppColors.primary : AppColors.textSecondary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
