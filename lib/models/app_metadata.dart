class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.14';
  static const int versionCode = 43;
  static const String buildLabel =
      '修 Tab 乱跳：从右上角小人 →「健康资料」→ 某类目 → 返回，会莫名跳到记录页'
      '（首页「查看全部」的切 Tab 信号残留，返回时被误触发）。改成只有主页面在最'
      '前台时才响应切 Tab。';
}
