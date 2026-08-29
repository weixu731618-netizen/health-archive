import 'package:flutter/material.dart';

import '../main.dart';
import 'daily_health_entry_page.dart';
import 'imaging_report_page.dart';
import 'manual_metric_entry_page.dart';
import 'medication_page.dart';
import 'report_capture_page.dart';
import 'report_import_page.dart';

/// 添加页面：拍摄/上传/影像报告/手工录入/日常记录/用药 入口
class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加健康数据')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              '记录新的检查或日常健康数据',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          _ActionCard(
            icon: Icons.camera_alt,
            title: '拍摄化验单',
            subtitle: '拍血常规/生化/肝肾功能等化验单，自动识别检查指标',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportCapturePage()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.upload_file,
            title: '上传化验单',
            subtitle: '选化验单图片或 PDF，自动识别检查指标',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportImportPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.medical_information_outlined,
            title: '添加影像/病理报告',
            subtitle: 'X光/CT/MRI/B超/心电图/病理等图文报告（图片或 PDF），自动识别文字后存档',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImagingReportPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.edit_note,
            title: '手工录入',
            subtitle: '手动添加检查指标',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.favorite,
            title: '日常记录',
            subtitle: '记录体重、血压、血糖和心率',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DailyHealthEntryPage()),
            ),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.medication_outlined,
            title: '用药',
            subtitle: '添加药物、设置服药计划（到点提醒）',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MedicationPage()),
            ),
          ),
        ],
      ),
    );
  }
}

/// 一个带图标的操作大卡片
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
