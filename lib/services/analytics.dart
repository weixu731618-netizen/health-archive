import 'package:flutter/foundation.dart';

/// 埋点事件层（桩）。
///
/// 目前只 `debugPrint`，不接任何第三方 SDK、不往外发数据 —— 此 App 正卡 ICP 备案，
/// 多一个数据流向就多一份合规负担。这里的作用是**把埋点位置先固定下来**：
/// 将来真接 analytics，只需把 [_emit] 的实现换成 SDK 调用，不必满代码找该在哪埋。
///
/// 关注的转化漏斗：
///   首次打开 → 首次上传 → 上传成功 → 查看解析结果 → 第二次上传
abstract final class AnalyticsEvents {
  static void _emit(String name, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params.isEmpty ? '' : params}');
    }
  }

  static void firstUploadStarted({required String source}) =>
      _emit('first_upload_started', {'source': source});

  static void uploadStarted({required String source}) =>
      _emit('upload_started', {'source': source});

  static void ocrCompleted({required int metricCount, required bool ok}) =>
      _emit('ocr_completed', {'metric_count': metricCount, 'ok': ok});

  static void ocrFailed() => _emit('ocr_failed');

  static void reportResultViewed({
    required int metricCount,
    required int abnormalCount,
    required int systemCount,
  }) =>
      _emit('report_result_viewed', {
        'metric_count': metricCount,
        'abnormal_count': abnormalCount,
        'system_count': systemCount,
      });

  static void followupCreatedFromResult() =>
      _emit('followup_created', {'from': 'report_result'});

  static void secondReportUploaded() => _emit('second_report_uploaded');

  static void historicalCompareViewed({required int comparedMetrics}) =>
      _emit('historical_compare_viewed', {'compared_metrics': comparedMetrics});
}
