import 'package:flutter/cupertino.dart';

import '../main.dart';

/// §22：上传入口页的前置隐私说明。一句话，不做长文案。
///
/// 文案与真实存储方式一致：此 App 本地优先，云端备份在 v1 精简版默认关闭
/// （见 main.dart 里对 identityService / cloudBackupService 的说明）。
class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.lock, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '资料仅用于建立你的健康档案，默认保存在本机，可随时查看、删除和导出。',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
