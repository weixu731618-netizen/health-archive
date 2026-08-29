/// 结构化健康数据的「来源」体系（第三阶段 §7 / §14 / §15）。
///
/// 每一条 MetricValue（当前实现是 `health_metrics` 表的一行）都带一个来源类型，
/// 存在 `health_metrics.sourceType` 文本列里。这里把散落在各页面的字符串常量
/// 收敛到一处，并**预留**未来的来源类型——现在没有实现 Apple Health / 设备导入，
/// 但类型设计先占好位置，将来接入时不需要改这一层。
///
/// 关于 `sourceId`（§6 建议字段：HealthKit 样本 UUID、设备 id、导入文件名等）：
/// 现有 `health_metrics` 表还没有这一列。等真正接 Apple Health / 设备导入时，
/// 会在那次迁移里给 `health_metrics` 加 `source_id` 文本列（可空），
/// 报告来源当前用 `reportId` 承担 sourceId 的职责。本阶段不加列、不做迁移。
library;

/// 规范的来源类型。新增外部来源时在这里加一个枚举值即可。
enum MetricSourceKind {
  /// 用户手工录入
  manual,

  /// 日常记录页录入的体重 / 血压 / 血糖 / 心率
  dailyRecord,

  /// 拍摄 / 上传化验单，OCR 识别后核对入库
  reportOcr,

  /// 导入的文件（PDF / 图片快照等），非 OCR 结构化路径 —— 预留
  importedFile,

  /// Apple Health 导入 —— 预留，未实现
  appleHealth,

  /// 蓝牙 / 配套设备（血压计、血糖仪、体重秤、手表等）—— 预留，未实现
  device,

  /// 未知 / 历史遗留无法归类
  unknown,
}

/// 写库用的字符串值（保持与历史数据兼容：OCR 仍写历史值 `report_import`）。
String metricSourceWire(MetricSourceKind kind) {
  switch (kind) {
    case MetricSourceKind.manual:
      return 'manual';
    case MetricSourceKind.dailyRecord:
      return 'daily';
    case MetricSourceKind.reportOcr:
      // 历史库里已有大量 'report_import'，继续沿用这个 wire 值，避免数据迁移。
      return 'report_import';
    case MetricSourceKind.importedFile:
      return 'imported_file';
    case MetricSourceKind.appleHealth:
      return 'apple_health';
    case MetricSourceKind.device:
      return 'device';
    case MetricSourceKind.unknown:
      return 'unknown';
  }
}

/// 把库里存的字符串（含历史值、别名）归一化到枚举。
MetricSourceKind metricSourceKindFromWire(String? wire) {
  switch ((wire ?? '').trim()) {
    case 'manual':
      return MetricSourceKind.manual;
    case 'daily':
    case 'daily_record':
      return MetricSourceKind.dailyRecord;
    case 'report_import':
    case 'report_ocr':
    case 'future_ocr': // 历史占位值
      return MetricSourceKind.reportOcr;
    case 'imported_file':
    case 'file_import':
    case 'future_hospital': // 历史占位值
      return MetricSourceKind.importedFile;
    case 'apple_health':
    case 'healthkit':
      return MetricSourceKind.appleHealth;
    case 'device':
    case 'bluetooth':
      return MetricSourceKind.device;
    default:
      return MetricSourceKind.unknown;
  }
}

/// 展示用中文标签。
String metricSourceLabel(MetricSourceKind kind) {
  switch (kind) {
    case MetricSourceKind.manual:
      return '手工录入';
    case MetricSourceKind.dailyRecord:
      return '日常记录';
    case MetricSourceKind.reportOcr:
      return '报告导入';
    case MetricSourceKind.importedFile:
      return '文件导入';
    case MetricSourceKind.appleHealth:
      return 'Apple Health';
    case MetricSourceKind.device:
      return '设备导入';
    case MetricSourceKind.unknown:
      return '手工录入';
  }
}

/// 由库里存的字符串直接拿到中文标签（页面常用）。
String metricSourceLabelFromWire(String? wire) =>
    metricSourceLabel(metricSourceKindFromWire(wire));

/// 记录页「来源」筛选目前对用户可见的选项。
/// 未实现的来源（Apple Health / 设备 / 文件导入）先不放出来，等接入后
/// 往这个列表里加即可，筛选逻辑按 [MetricSourceKind] 判定，不必再改。
const List<MetricSourceKind> visibleRecordSourceFilters = [
  MetricSourceKind.reportOcr,
  MetricSourceKind.manual,
  MetricSourceKind.dailyRecord,
];
