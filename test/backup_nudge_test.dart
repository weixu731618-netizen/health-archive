// 首页「建议备份档案」提醒判定的纯函数测试。
import 'package:flutter_test/flutter_test.dart';
import 'package:health_archive/models/backup_nudge.dart';

void main() {
  final now = DateTime(2026, 8, 31, 12);
  final earlier = now.subtract(const Duration(days: 3));
  final later = now.add(const Duration(days: 1));

  test('报告数不足阈值：不提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: kBackupNudgeThreshold - 1,
        newestReportCreatedAt: now,
        lastBackupAt: null,
        nudgeAckAt: null,
      ),
      isFalse,
    );
  });

  test('够量且从没备份 / 没关过提醒：提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: kBackupNudgeThreshold,
        newestReportCreatedAt: now,
        lastBackupAt: null,
        nudgeAckAt: null,
      ),
      isTrue,
    );
  });

  test('最新报告早于上次备份：不提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: 10,
        newestReportCreatedAt: earlier,
        lastBackupAt: now,
        nudgeAckAt: null,
      ),
      isFalse,
    );
  });

  test('上次备份后又加了新报告：重新提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: 10,
        newestReportCreatedAt: later,
        lastBackupAt: now,
        nudgeAckAt: null,
      ),
      isTrue,
    );
  });

  test('关闭提醒后没有更新报告：不再提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: 10,
        newestReportCreatedAt: earlier,
        lastBackupAt: null,
        nudgeAckAt: now,
      ),
      isFalse,
    );
  });

  test('关闭提醒后又有更新报告：再次提醒', () {
    expect(
      shouldShowBackupNudge(
        reportCount: 10,
        newestReportCreatedAt: later,
        lastBackupAt: null,
        nudgeAckAt: now,
      ),
      isTrue,
    );
  });

  test('cutoff 取备份 / 关闭里较晚的一个', () {
    // 关闭提醒（now）晚于上次备份（earlier）；最新报告在两者之间 → 不提醒
    expect(
      shouldShowBackupNudge(
        reportCount: 10,
        newestReportCreatedAt: now.subtract(const Duration(hours: 1)),
        lastBackupAt: earlier,
        nudgeAckAt: now,
      ),
      isFalse,
    );
  });
}
