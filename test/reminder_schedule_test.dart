// B2：提醒时间点解析 / 默认值 / 通知 id / 到期文案 —— 纯逻辑。
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/utils/reminder_schedule.dart';

void main() {
  test('parseDailyTimes：解析、排序、去重、跳过非法项', () {
    expect(parseDailyTimes('20:00,08:00,08:00').map((t) => t.text).toList(),
        ['08:00', '20:00']);
    expect(parseDailyTimes(null), isEmpty);
    expect(parseDailyTimes(''), isEmpty);
    expect(parseDailyTimes('25:00,8:5,abc').map((t) => t.text).toList(),
        ['08:05']);
  });

  test('defaultMedicationTimes：按每日次数给默认时间点', () {
    expect(defaultMedicationTimes(1), ['09:00']);
    expect(defaultMedicationTimes(2), ['09:00', '21:00']);
    expect(defaultMedicationTimes(3), ['08:00', '13:00', '20:00']);
    expect(defaultMedicationTimes(0), ['09:00']);
    expect(defaultMedicationTimes(10).length, 8); // 上限 8
  });

  test('timesPerDayCount：从文本取次数', () {
    expect(timesPerDayCount('每日 2 次'), 2);
    expect(timesPerDayCount('3'), 3);
    expect(timesPerDayCount(null), 1);
    expect(timesPerDayCount('随餐'), 1);
  });

  test('dueDescription：过期 / 今天 / 明天 / 还有 N 天', () {
    final now = DateTime(2026, 8, 29, 15);
    expect(dueDescription(DateTime(2026, 8, 26), now), '已过期 3 天');
    expect(dueDescription(DateTime(2026, 8, 29), now), '今天');
    expect(dueDescription(DateTime(2026, 8, 30), now), '明天');
    expect(dueDescription(DateTime(2026, 9, 3), now), '还有 5 天');
  });
}
