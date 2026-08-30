// iOS 结构优化 §19：首页红色 badge 只累计「真正需要用户处理」的通知，
// 普通服药提醒 / 资料归档 / 系统消息不进红点（仍显示在通知中心列表）。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
    await repo.ensureDefaultPersonProfile();
  });

  tearDown(() async => db.close());

  test('actionableUnreadCount 只算 recheck / followup 等可处理类别', () async {
    final past = DateTime.now().subtract(const Duration(hours: 1));

    await repo.insertNotification(
      category: 'recheck',
      title: '眼底检查',
      scheduledFor: past,
      deliveredAt: past,
    );
    await repo.insertNotification(
      category: 'medication',
      title: '该服药：二甲双胍',
      scheduledFor: past,
      deliveredAt: past,
    );
    await repo.insertNotification(
      category: 'archive',
      title: '报告已归档',
      scheduledFor: past,
      deliveredAt: past,
    );

    // 普通未读计数把三条都算进去
    expect(await repo.unreadNotificationCount(), 3);
    // 红点只算 recheck 这一条
    expect(await repo.actionableUnreadCount(), 1);
  });

  test('已读的可处理通知不再计入红点', () async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    final id = await repo.insertNotification(
      category: 'recheck',
      title: '复查血脂',
      scheduledFor: past,
      deliveredAt: past,
    );
    expect(await repo.actionableUnreadCount(), 1);
    await repo.markNotificationRead(id);
    expect(await repo.actionableUnreadCount(), 0);
  });
}
