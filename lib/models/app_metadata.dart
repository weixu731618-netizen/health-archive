class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.1';
  static const int versionCode = 30;
  static const String buildLabel =
      '修复：报告参考范围上限被 OCR 双连字符（"3.5--9.5"）读成负数，导致几乎每条'
      '导入指标都判「偏高」——后端正则吞掉连字符串 + 客户端兜底 + 迁移 v17 '
      '回修已存数据并重算状态；待跟进 = 能清空的收件箱（点进器官详情页 = 已看过）；'
      '记录页「手动记录」不再重复列出报告里的指标。';
}
