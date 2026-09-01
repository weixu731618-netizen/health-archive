/// 首页「建议备份档案」提醒的显示判定（纯函数，方便单测）。
///
/// 登录 / 云同步在 V1 不做，换机不丢数据只靠本地 zip 备份（[LocalBackupService]）。
/// 用户不会主动想起来备份，所以攒到一定量、且「上次备份之后又加了新报告」时，
/// 在首页轻提醒一次。用户可关闭；关闭点记为一个确认时间点，之后有更新的报告再重新提醒。
library;

/// 攒够这么多份报告才开始提醒（更少时备份价值不大，不打扰）。
const int kBackupNudgeThreshold = 5;

/// [reportCount]            当前档案里的报告总数
/// [newestReportCreatedAt] 最新一份报告的 createdAt（无报告时为 null）
/// [lastBackupAt]          上次成功导出本地备份包的时间（从没备份过为 null）
/// [nudgeAckAt]            上次关闭这条提醒的时间（从没关闭过为 null）
bool shouldShowBackupNudge({
  required int reportCount,
  required DateTime? newestReportCreatedAt,
  required DateTime? lastBackupAt,
  required DateTime? nudgeAckAt,
  int threshold = kBackupNudgeThreshold,
}) {
  if (reportCount < threshold) return false;

  // 「已确认到」的时间点 = 上次备份、上次关闭提醒里较晚的那个。
  DateTime? cutoff;
  for (final t in [lastBackupAt, nudgeAckAt]) {
    if (t == null) continue;
    if (cutoff == null || t.isAfter(cutoff)) cutoff = t;
  }

  if (cutoff == null) return true; // 够量且从没备份 / 没关过 → 提醒
  if (newestReportCreatedAt == null) return false;
  return newestReportCreatedAt.isAfter(cutoff); // 确认之后又有新报告 → 再提醒
}
