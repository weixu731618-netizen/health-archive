import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_nav.dart';

/// 使用帮助：几篇短说明，纯常识，不涉及任何健康数据。
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _articles = <(String, String)>[
    (
      '怎么拍报告最清楚',
      '一张纸一份报告，放平、光线足、别反光；整张纸都进画面，确保字迹清晰。'
          '拍歪了、拍糊了识别容易出错。',
    ),
    (
      '一张照片里有两份报告怎么办',
      'App 没办法自动把一张照片拆成两份。请分开拍——一份一张；'
          '或者用手机自带的「扫描」做成两页 PDF 再上传。',
    ),
    (
      '多页报告怎么传',
      '医院给的 PDF：上传时选「文件」，直接选那个 PDF，每一页都会识别，'
          '原件也会完整保留。\n\n'
          '纸质的多页报告：先用手机自带「扫描」功能把几页拼成一个 PDF，再上传。'
          '「拍报告」目前一次只能拍一页。',
    ),
    (
      '识别得不对怎么办',
      '在核对页可以逐项修改——点任意一行进去改名称、数值、参考范围。\n\n'
          '如果项目名读串了（读到了旁边一列），点核对页底部的'
          '「换种方式重新识别」，会用另一种方式再读一遍，慢一些但通常更准。\n\n'
          '实在读不出来，可以在报告详情页「补录指标」手动填。',
    ),
    (
      '这些数据存在哪',
      '全部存在你这台手机本地。导出 / 备份的文件由你自己保管（存网盘、发给自己等）。'
          '识别报告时，图片会发到后端做文字识别，识别完就不再保留。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IosLargeTitleScaffold(
      title: '使用帮助',
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: [
        for (final (title, body) in _articles) ...[
          HealthCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(body,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
