import 'package:shared_preferences/shared_preferences.dart';

/// 首页「待跟进」的「已看过」时间戳，按 (档案 id, 器官名) 存 SharedPreferences。
///
/// 设计：待跟进 = 一个能清空的收件箱。点进某器官详情页 = 「我知道了」→ 记一个
/// 时间戳；之后该器官的所有异常/过期信号只要都早于这个时间戳，就不在待跟进显示
/// （身体页照样橙色标记，提醒页照样列——那两处是常驻看板 / 安全网）。
/// 只有出现**新信号**（新报告让某项变异常/变差、又有复查过期）时间新过该时间戳，
/// 才重新冒回待跟进。
///
/// 这是软性的 UI 状态，不进健康数据备份；丢了最多某条重新出现一次，再看一眼即可。
class AttentionAcks {
  AttentionAcks._();

  static String _key(int profileId, String area) =>
      'attn_ack_${profileId}_$area';

  /// 记下「刚看过某器官」。
  static Future<void> ack(int profileId, String area) async {
    if (area.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key(profileId, area), DateTime.now().toIso8601String());
  }

  /// 取当前档案下、给定器官集合的「已看过」时间戳。没记过的不在结果里。
  static Future<Map<String, DateTime>> load(
      int profileId, Iterable<String> areas) async {
    final prefs = await SharedPreferences.getInstance();
    final out = <String, DateTime>{};
    for (final a in areas) {
      final s = prefs.getString(_key(profileId, a));
      final t = s == null ? null : DateTime.tryParse(s);
      if (t != null) out[a] = t;
    }
    return out;
  }
}
