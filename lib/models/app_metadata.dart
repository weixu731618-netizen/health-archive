class AppMetadata {
  const AppMetadata._();

  static const String versionName = '1.9.2';
  static const int versionCode = 31;
  static const String buildLabel =
      '识别更稳（第一层加固）：参考范围合理性校验（上限≤下限自动纠 / 数量级明显'
      '不对时退回标准指标典型范围）；化验单自带 ↑/↓ 与按范围算的状态冲突时以化验单'
      '为准并在核对页标注；某部位只有影像/图文记录时器官页文案改为「暂无关键化验'
      '指标」而非「数据不足」。';
}
