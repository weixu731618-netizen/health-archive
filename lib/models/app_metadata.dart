class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.4';
  static const int versionCode = 33;
  static const String buildLabel =
      '器官判断只用核心指标（Round 3b·上）：没匹配上核心词典的指标不再从生理图谱'
      '消失——进器官详情页「其他指标」区照实展示，但不参与器官红黄判定 / 趋势 / '
      '首页需关注；肿瘤标志物与急性指标同样「仅提示不判定」。未匹配项按名字关键词'
      '粗归到对的系统（血常规分类项进血液系统而非「其他」）。迁移 v18：已入库指标'
      '按扩充后的词典重新匹配，避免趋势断层。';
}
