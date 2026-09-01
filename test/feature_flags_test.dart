// 健康权益是未来的商业化模块，当前版本必须保持关闭（见 docs/health_benefits.md）。
// 这条测试是「默认关闭」的守卫：谁把默认值改成 true，CI 会红，必须是有意为之。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/config/feature_flags.dart';

void main() {
  test('healthBenefitsEnabled 默认关闭', () {
    expect(FeatureFlags.healthBenefitsEnabled, isFalse);
  });
}
