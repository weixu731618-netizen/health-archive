/// 本文件集中存放当前阶段使用的所有本地假数据。
/// 全部为静态数据，不依赖任何网络或数据库，后续接入真实数据时只需改这里。
library;

/// 首页「近期关注」里的一条指标
///
/// 统一状态体系：
/// - valueStatus（数值状态）：正常 / 偏高 / 偏低 / 数据不足
/// - trend（趋势状态）：稳定 / 上升 / 下降 / 持续上升 / 持续下降
class Metric {
  final String title; // 糖化血红蛋白
  final String value; // 6.8%
  final String valueStatus; // 数值状态：偏高
  final String trend; // 趋势状态：持续上升
  final String hint; // 一句简短说明

  const Metric({
    required this.title,
    required this.value,
    required this.valueStatus,
    required this.trend,
    required this.hint,
  });
}

/// 一个身体系统（首页网格和身体页面共用）
class BodySystem {
  final String name; // 肾脏
  final String status; // 1 项需关注
  final String? keyIndicator; // 尿酸 480 μmol/L

  const BodySystem({
    required this.name,
    required this.status,
    this.keyIndicator,
  });
}

/// 首页「身体系统」摘要卡片
/// 显示：系统名称 + 1 个最关键指标 + 数值状态
class HomeBodySystem {
  final String name; // 心血管
  final String keyMetric; // LDL-C 3.6 mmol/L
  final String status; // 数值状态：需要关注

  const HomeBodySystem({
    required this.name,
    required this.keyMetric,
    required this.status,
  });
}

/// 肾脏详情页的关键指标
class KidneyMetric {
  final String name; // 肌酐
  final String value; // 93 μmol/L
  final String status; // 稳定

  const KidneyMetric({
    required this.name,
    required this.value,
    required this.status,
  });
}

/// 肾脏历史趋势里的一个数据点
class TrendPoint {
  final String year; // 2024
  final int value; // 430

  const TrendPoint({required this.year, required this.value});
}

/// 时间线里的一条健康记录
class RecordItem {
  final String date; // 2026年8月18日
  final String place; // 深圳某医院 / 家庭测量
  final String title; // 生化检查 / 血压 128 / 82 mmHg
  final List<String> includes; // 肝功能、肾功能…
  final String? itemCount; // 32 项指标
  final bool isHospital; // 是否医院检查（可进入详情页）

  const RecordItem({
    required this.date,
    required this.place,
    required this.title,
    this.includes = const [],
    this.itemCount,
    required this.isHospital,
  });
}

/// 检查详情页里的一个指标行
class ReportIndicator {
  final String name; // ALT
  final String value; // 32 U/L
  final String range; // 参考范围 9–50
  final String status; // 正常

  const ReportIndicator({
    required this.name,
    required this.value,
    required this.range,
    required this.status,
  });
}

/// 所有假数据的统一入口
abstract final class FakeData {
  // ---- 首页：近期关注 ----
  static const List<Metric> homeMetrics = [
    Metric(
      title: '糖化血红蛋白',
      value: '6.8%',
      valueStatus: '偏高',
      trend: '持续上升',
      hint: '最近三次结果呈上升趋势',
    ),
    Metric(
      title: '尿酸',
      value: '480 μmol/L',
      valueStatus: '偏高',
      trend: '上升',
      hint: '高于本次报告参考范围上限',
    ),
    Metric(
      title: 'LDL-C',
      value: '3.6 mmol/L',
      valueStatus: '偏高',
      trend: '上升',
      hint: '最近一次检查高于参考范围',
    ),
  ];

  // ---- 首页：身体系统摘要卡片 ----
  // 每个系统显示：系统名称 + 1 个最关键指标 + 数值状态
  static const List<HomeBodySystem> homeBodySystems = [
    HomeBodySystem(name: '心血管', keyMetric: 'LDL-C 3.6 mmol/L', status: '需要关注'),
    HomeBodySystem(name: '血糖代谢', keyMetric: 'HbA1c 6.8%', status: '偏高'),
    HomeBodySystem(name: '肝脏', keyMetric: 'ALT 32 U/L', status: '正常'),
    HomeBodySystem(name: '肾脏', keyMetric: '尿酸 480 μmol/L', status: '偏高'),
    HomeBodySystem(name: '甲状腺', keyMetric: '暂无数据', status: '数据不足'),
    HomeBodySystem(name: '血液', keyMetric: 'WBC 6.5 ×10⁹/L', status: '正常'),
  ];

  // ---- 身体系统（首页网格 & 身体页面共用） ----
  static const List<BodySystem> bodySystems = [
    BodySystem(name: '心血管', status: '需要关注', keyIndicator: 'LDL-C 3.6 mmol/L'),
    BodySystem(name: '血糖代谢', status: '需要关注', keyIndicator: 'HbA1c 6.8%'),
    BodySystem(name: '肝脏', status: '正常', keyIndicator: 'ALT 32 U/L'),
    BodySystem(name: '肾脏', status: '1 项需关注', keyIndicator: '尿酸 480 μmol/L'),
    BodySystem(name: '甲状腺', status: '数据不足'),
    BodySystem(name: '血液', status: '正常'),
  ];

  // ---- 肾脏详情页 ----
  static const List<KidneyMetric> kidneyMetrics = [
    KidneyMetric(name: '肌酐', value: '93 μmol/L', status: '稳定'),
    KidneyMetric(name: 'eGFR', value: '88', status: '轻微下降'),
    KidneyMetric(name: '尿酸', value: '480 μmol/L', status: '偏高'),
  ];

  static const List<TrendPoint> kidneyTrend = [
    TrendPoint(year: '2024', value: 430),
    TrendPoint(year: '2025', value: 455),
    TrendPoint(year: '2026', value: 480),
  ];

  // ---- 记录时间线 ----
  static const List<RecordItem> records = [
    RecordItem(
      date: '2026年8月18日',
      place: '深圳某医院',
      title: '生化检查',
      includes: ['肝功能', '肾功能', '血脂', '血糖'],
      itemCount: '32 项指标',
      isHospital: true,
    ),
    RecordItem(
      date: '2026年7月20日',
      place: '家庭测量',
      title: '血压 128 / 82 mmHg',
      isHospital: false,
    ),
    RecordItem(
      date: '2026年6月15日',
      place: '深圳某体检中心',
      title: '年度体检',
      includes: ['血常规', '尿常规', '腹部彩超', '心电图'],
      isHospital: true,
    ),
  ];

  // ---- 检查详情页指标 ----
  static const List<ReportIndicator> reportIndicators = [
    ReportIndicator(name: 'ALT', value: '32 U/L', range: '参考范围 9–50', status: '正常'),
    ReportIndicator(name: 'AST', value: '27 U/L', range: '参考范围 15–40', status: '正常'),
    ReportIndicator(name: '尿酸', value: '480 μmol/L', range: '参考范围 210–420', status: '偏高'),
    ReportIndicator(name: 'LDL-C', value: '3.6 mmol/L', range: '参考范围 0–3.4', status: '偏高'),
  ];

  // ---- 肾脏详情页：相关检查记录 ----
  static const List<RecordItem> kidneyRecords = [
    RecordItem(date: '2026年8月18日', place: '深圳某医院', title: '肾功能检查', isHospital: true),
    RecordItem(date: '2025年6月10日', place: '深圳某医院', title: '年度体检', isHospital: true),
  ];
}
