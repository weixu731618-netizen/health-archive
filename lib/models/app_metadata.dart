class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.5';
  static const int versionCode = 34;
  static const String buildLabel =
      '指标名归一化匹配（Round 3b·下）：撞不上核心词典的项交给后端 DeepSeek 归一化'
      '到 110 个标准指标之一（高置信 + 单位兼容才采纳），命中的写进本地缓存'
      '（metric_match_cache，进备份），同名下次直接用、不再调模型。客户端匹配顺序：'
      '本地词典 → 缓存 → DeepSeek → 非核心。';
}
