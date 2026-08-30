import 'package:flutter/material.dart';

import '../main.dart';
import 'daily_health_entry_page.dart';
import 'imaging_report_page.dart';
import 'manual_metric_entry_page.dart';
import 'medication_page.dart';
import 'report_capture_page.dart';
import 'report_import_page.dart';

/// 「+」的添加入口：不再是整屏页面，改成从底部浮出的轻量菜单。
/// 点 `+` → 菜单浮出（盖在当前页上，无页面跳转）→ 选一项 → 进对应录入页。
/// 每一层 sheet 都用「pop 出一个结果」的方式，导航统一在这里做，避免在正被
/// 销毁的 sheet 里查 Navigator。
Future<void> showAddDataSheet(BuildContext context) async {
  final pick = await showModalBottomSheet<_AddPick>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _AddDataSheet(),
  );
  if (pick == null || !context.mounted) return;

  Widget? page;
  switch (pick) {
    case _AddPick.lab:
      final mode = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => const _LabModeSheet(),
      );
      if (!context.mounted) return;
      if (mode == 'camera') {
        page = const ReportCapturePage();
      } else if (mode == 'upload') {
        page = const ReportImportPage();
      }
    case _AddPick.imaging:
      page = const ImagingReportPage();
    case _AddPick.manual:
      page = const ManualMetricEntryPage();
    case _AddPick.daily:
      page = const DailyHealthEntryPage();
    case _AddPick.medication:
      page = const MedicationPage();
  }

  if (page != null && context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page!));
  }
}

enum _AddPick { lab, imaging, manual, daily, medication }

class _AddDataSheet extends StatelessWidget {
  const _AddDataSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text('添加健康数据',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            _AddRow(
              icon: Icons.description_outlined,
              title: '拍报告 / 上传',
              subtitle: '拍照或选文件，自动识别检查指标',
              onTap: () => Navigator.pop(context, _AddPick.lab),
            ),
            _AddRow(
              icon: Icons.medical_information_outlined,
              title: '影像 / 病理报告',
              subtitle: 'X光·CT·B超·病理，识别文字并存原件',
              onTap: () => Navigator.pop(context, _AddPick.imaging),
            ),
            _AddRow(
              icon: Icons.edit_note,
              title: '手工录入',
              subtitle: '手动加一个化验指标',
              onTap: () => Navigator.pop(context, _AddPick.manual),
            ),
            _AddRow(
              icon: Icons.favorite_border,
              title: '日常记录',
              subtitle: '体重 · 血压 · 血糖 · 心率',
              onTap: () => Navigator.pop(context, _AddPick.daily),
            ),
            _AddRow(
              icon: Icons.medication_outlined,
              title: '用药',
              subtitle: '药物 · 剂量 · 服药提醒',
              onTap: () => Navigator.pop(context, _AddPick.medication),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 报告的「拍照 / 上传」二选一。
class _LabModeSheet extends StatelessWidget {
  const _LabModeSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('报告',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            title: const Text('拍照'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined,
                color: AppColors.primary),
            title: const Text('从相册或文件选'),
            subtitle: const Text('图片或 PDF'),
            onTap: () => Navigator.pop(context, 'upload'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      onTap: onTap,
    );
  }
}
