// B2：提醒 / 通知 仓库层 —— CRUD、按档案隔离、服药提醒 upsert/删除、通知落库。
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';

void main() {
  late AppDatabase db;
  late HealthRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('复查提醒：新增 / 查询 / 标记完成 / 删除', () async {
    await repo.ensureDefaultPersonProfile();
    final id = await repo.insertReminder(
      kind: 'recheck',
      title: '复查 尿酸',
      detail: '上次 508 μmol/L（偏高）',
      relatedMetricId: 'UA',
      dueDate: DateTime(2026, 10, 1),
    );
    expect((await repo.getActiveReminders()).single.title, '复查 尿酸');
    expect((await repo.getRecheckReminderForMetric('UA'))!.id, id);

    await repo.markReminderCompleted(id);
    expect(await repo.getActiveReminders(), isEmpty);
    expect(await repo.getRecheckReminderForMetric('UA'), isNull);
    expect((await repo.getActiveReminders(includeCompleted: true)), hasLength(1));

    await repo.deleteReminder(id);
    expect(await repo.getActiveReminders(includeCompleted: true), isEmpty);
  });

  test('服药提醒：setMedicationReminder 幂等 upsert；关闭时删除', () async {
    await repo.ensureDefaultPersonProfile();
    final medId = await repo.insertMedication(name: '二甲双胍');

    await repo.setMedicationReminder(
      medicationId: medId,
      profileId: HealthRepository.defaultProfileId,
      medName: '二甲双胍',
      times: ['08:00', '20:00'],
      enabled: true,
      detail: '每次 0.5g',
    );
    var r = await repo.getMedicationReminder(medId);
    expect(r, isNotNull);
    expect(r!.dailyTimes, '08:00,20:00');

    // 再调 → 更新，不新增
    await repo.setMedicationReminder(
      medicationId: medId,
      profileId: HealthRepository.defaultProfileId,
      medName: '二甲双胍缓释片',
      times: ['09:00'],
      enabled: true,
    );
    r = await repo.getMedicationReminder(medId);
    expect(r!.title, '二甲双胍缓释片');
    expect(r.dailyTimes, '09:00');
    expect(await repo.getActiveReminders(), hasLength(1));

    // 关闭 → 删除
    await repo.setMedicationReminder(
      medicationId: medId,
      profileId: HealthRepository.defaultProfileId,
      medName: '二甲双胍',
      times: const [],
      enabled: false,
    );
    expect(await repo.getMedicationReminder(medId), isNull);
  });

  test('提醒按当前档案隔离', () async {
    await repo.ensureDefaultPersonProfile();
    await repo.insertReminder(kind: 'recheck', title: '本人复查');
    final momId = await repo.insertPersonProfile(displayName: '妈妈');
    await repo.setActiveProfileId(momId);
    expect(await repo.getActiveReminders(), isEmpty);
    await repo.insertReminder(kind: 'recheck', title: '妈妈复查');
    expect((await repo.getActiveReminders()).single.title, '妈妈复查');

    await repo.setActiveProfileId(HealthRepository.defaultProfileId);
    expect((await repo.getActiveReminders()).single.title, '本人复查');

    // 全部可排程提醒（系统通知用）覆盖两个档案
    expect(await repo.getAllSchedulableReminders(), hasLength(2));
  });

  test('删除成员级联删除其提醒', () async {
    await repo.ensureDefaultPersonProfile();
    final dadId = await repo.insertPersonProfile(displayName: '爸爸');
    await repo.setActiveProfileId(dadId);
    await repo.insertReminder(kind: 'recheck', title: '爸爸复查');
    await repo.deletePersonProfileCascade(dadId);
    expect(await db.select(db.reminders).get(), isEmpty);
  });

  test('syncNotificationsFromReminders：复查落 1 行，服药按今天时间点落行，幂等', () async {
    await repo.ensureDefaultPersonProfile();
    final now = DateTime(2026, 8, 29, 12);
    await repo.insertReminder(
      kind: 'recheck',
      title: '复查甲功',
      dueDate: DateTime(2026, 8, 20), // 已过期
    );
    final medId = await repo.insertMedication(name: '氨氯地平');
    await repo.setMedicationReminder(
      medicationId: medId,
      profileId: HealthRepository.defaultProfileId,
      medName: '氨氯地平',
      times: ['08:00', '20:00'],
      enabled: true,
    );

    final n1 = await repo.syncNotificationsFromReminders(now: now);
    expect(n1, 3); // 1 复查 + 2 服药
    final notes = await repo.getNotifications();
    expect(notes, hasLength(3));
    // 复查（8-20 09:00）和早上 08:00 那条已过时间 → 已标记送达
    expect(notes.where((x) => x.deliveredAt != null).length, 2);
    // 晚上 20:00 那条还没到 → 待提醒
    expect(notes.where((x) => x.deliveredAt == null).length, 1);

    // 再次调用不重复插入
    final n2 = await repo.syncNotificationsFromReminders(now: now);
    expect(n2, 0);
    expect(await repo.getNotifications(), hasLength(3));

    expect(await repo.unreadNotificationCount(), 2);
    await repo.markAllNotificationsRead();
    expect(await repo.unreadNotificationCount(), 0);
  });

  test('导出包含 reminders', () async {
    await repo.ensureDefaultPersonProfile();
    await repo.insertReminder(
        kind: 'recheck', title: '复查', dueDate: DateTime(2026, 12, 1));
    final data = await repo.exportHealthData();
    expect(data['reminders'], isA<List>());
    expect((data['reminders'] as List).single['title'], '复查');
  });
}
