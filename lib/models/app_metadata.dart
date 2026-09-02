class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.15';
  static const int versionCode = 44;
  static const String buildLabel =
      '删掉首页「最近」：那是「记录」Tab 的职责，底部一步可达，放首页只是重复。'
      '顺带移除了 activeTabNotifier 那套跨 Tab 跳转代码（正是之前 Tab 乱跳的来源）。'
      '首页现在只有：添加健康资料 + 待跟进。';
}
