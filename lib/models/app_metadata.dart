class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.12';
  static const int versionCode = 41;
  static const String buildLabel =
      '体检报告核对页：识别到 0 项化验、但有总检结论 / 各科所见 / 一般项目时'
      '也能保存（以前卡在「请至少勾选一项指标」），保存后进详情页而非结果页。'
      '后端：百度专用接口把「深圳HR / 全国R」这类地区参考值列标读进项目名时，'
      '改用项目代号或整行丢弃，不再显示「深圳HR」。';
}
