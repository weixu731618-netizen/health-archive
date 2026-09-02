class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.13';
  static const int versionCode = 42;
  static const String buildLabel =
      '空白体检表不再能保存：只有真的填了内容（总检结论 / 建议、一般项目数值、'
      '或填了字的各科所见）才算，DeepSeek 硬编出的空栏目会被判为「没识别到可保存'
      '的内容，请重拍或换一页」。后端提示词：空白栏目不补写「正常/未见异常」。';
}
