/// 编译期功能开关。默认全部关闭；需要时用 `--dart-define=XXX=true` 打开。
///
/// 「健康权益 / Health Benefits」是未来的商业化模块（洗牙 / 口腔检查 / 体检套餐 /
/// 眼科 / 骨密度 / 健康筛查等正规健康服务权益）。当前版本**不开放**，只预留结构，
/// 避免商业内容干扰用户对「长期健康档案」这一核心定位的第一印象。
///
/// 背景、边界与隐私红线见 `docs/health_benefits.md`。
class FeatureFlags {
  const FeatureFlags._();

  /// 健康权益模块总开关。
  ///
  /// `false`（默认）：入口不显示，相关页面不可达，任何商业化代码不生效。
  /// 仅当未来准备正式上线时，才用 `--dart-define=HEALTH_BENEFITS_ENABLED=true` 打开。
  static const bool healthBenefitsEnabled =
      bool.fromEnvironment('HEALTH_BENEFITS_ENABLED', defaultValue: false);
}
