import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;

import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../models/body_area_health.dart';
import '../utils/image_storage.dart';
import '../widgets/current_profile_badge.dart';
import '../widgets/error_note.dart';
import '../widgets/privacy_note.dart';
import 'manual_metric_entry_page.dart';
import 'report_recognition_flow.dart';

/// 拍报告页：系统相机拍一张（相机自带「✓ 使用照片」确认）→ 直接进识别流程。
/// 不再有多余的二次预览确认。
class ReportCapturePage extends StatefulWidget {
  /// 从某个器官 / 系统详情页的 `+` 进来时传入该部位名，识别核对页会作为
  /// 「建议关联部位」默认带上。
  final String? initialArea;

  const ReportCapturePage({super.key, this.initialArea});

  @override
  State<ReportCapturePage> createState() => _ReportCapturePageState();
}

class _ReportCapturePageState extends State<ReportCapturePage> {
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final img = await captureLabReportImage();
      if (!mounted) return;
      // 相机里已经确认过照片 → 识别流程接管，并把本页从栈里替换掉，
      // 保存后手势返回不会撞回这个空壳拍照页。
      await startReportRecognitionFlowPagesReplacing(
        context,
        [img],
        initialArea: widget.initialArea,
      );
    } on StateError {
      // image_picker 取消（未拍摄）→ 退回上一页，不当错误。
      if (mounted) Navigator.of(context).pop();
    } on PlatformException catch (e) {
      if (mounted) {
        final denied = e.code.contains('access_denied') ||
            e.code == 'camera_access_denied';
        setState(() => _error = denied
            ? '没有相机权限。请到「设置 › 隐私与安全性 › 相机」里允许本 App 使用相机，再回来重试。'
            : '打不开相机，请重试，或改用「上传报告」从相册 / 文件选择。');
      }
    } catch (_) {
      if (mounted) setState(() => _error = '无法读取这张照片，请重新拍摄');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goManual() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.initialArea;
    return Scaffold(
      appBar: AppBar(title: const Text('拍报告')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const CurrentProfileBadge(),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '把整份报告放进画面，横竖均可，确保文字清晰。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          if (area != null && coreBodyAreaOrder.contains(area))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('将关联到：$area',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
          const PrivacyNote(),
          HealthCard(
            child: Column(
              children: [
                if (_busy) ...[
                  const CupertinoActivityIndicator(),
                  const SizedBox(height: 12),
                  const Text('正在打开相机…',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ] else ...[
                  const Icon(CupertinoIcons.camera,
                      size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  IosButton.filled('打开相机',
                      icon: CupertinoIcons.camera, onPressed: _capture),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorNote(
              message: _error!,
              actions: [
                ErrorNoteAction('重试', _busy ? null : _capture),
                ErrorNoteAction('手工录入', _goManual),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
