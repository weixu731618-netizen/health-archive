import 'package:flutter/material.dart';

import '../main.dart';

/// 报告链路统一的行内错误提示：淡红底 + 图标 + 文案 + 可选操作按钮。
///
/// G2：拍照页 / 上传页 / 详情页原来各写一套错误 UI，样式不一致，这里收敛成一个。
class ErrorNote extends StatelessWidget {
  final String message;

  /// 可选的补救操作（如「重新拍摄」「手工录入」「重试」）。空则不显示按钮行。
  final List<ErrorNoteAction> actions;

  const ErrorNote({
    super.key,
    required this.message,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, actions.isEmpty ? 12 : 4),
      decoration: BoxDecoration(
        color: AppColors.abnormal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline,
                  size: 20, color: AppColors.abnormal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textPrimary)),
              ),
            ],
          ),
          if (actions.isNotEmpty)
            Row(
              children: [
                for (final a in actions)
                  TextButton(onPressed: a.onPressed, child: Text(a.label)),
              ],
            ),
        ],
      ),
    );
  }
}

class ErrorNoteAction {
  final String label;
  final VoidCallback? onPressed;
  const ErrorNoteAction(this.label, this.onPressed);
}
