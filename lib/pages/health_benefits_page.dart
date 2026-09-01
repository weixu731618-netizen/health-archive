import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// 「健康权益」占位页。
///
/// 仅当 `FeatureFlags.healthBenefitsEnabled` 打开时才可达（见「我的」页入口）。
/// 当前版本不实现任何商业化内容——分类、商家列表、优惠券、支付、核销都不做。
/// 完整边界与隐私红线见 `docs/health_benefits.md`。
class HealthBenefitsPage extends StatelessWidget {
  const HealthBenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健康权益')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.gift,
                  size: 48, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                '健康权益即将上线',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '未来这里会提供洗牙、口腔检查、体检套餐、眼科、健康筛查等\n'
                '正规健康服务权益。不会用你的健康报告数据做商业推荐。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
