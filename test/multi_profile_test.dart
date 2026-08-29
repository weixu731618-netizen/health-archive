// B1：多人家庭档案 —— 人员 CRUD、数据按档案隔离、级联删除、切换。
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

  Future<void> addMetricForActive(String name) => repo.insertMetric(
        metricId: name,
        metricName: name,
        value: 1,
        unit: 'x',
        referenceMin: null,
        referenceMax: null,
        status: '未判断',
        bodySystem: '其他',
        measuredAt: DateTime(2026, 1, 1),
      );

  test('新增成员 + 切换 + 数据按档案隔离', () async {
    await repo.ensureDefaultPersonProfile();
    await addMetricForActive('SELF_A');

    final momId = await repo.insertPersonProfile(
      displayName: '妈妈',
      relationship: '母亲',
      sex: '女',
    );
    expect(momId, greaterThan(1));

    // 默认仍是「本人」，只看得到本人的数据
    expect(repo.activeProfileId, HealthRepository.defaultProfileId);
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['SELF_A']);

    // 切到妈妈，写一条只属于她的数据
    await repo.setActiveProfileId(momId);
    expect(repo.activeProfileId, momId);
    expect(await repo.getAllMetrics(), isEmpty);
    await addMetricForActive('MOM_A');
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['MOM_A']);

    // 切回本人，看不到妈妈的数据
    await repo.setActiveProfileId(HealthRepository.defaultProfileId);
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['SELF_A']);
  });

  test('切到不存在的档案会回落到「本人」', () async {
    await repo.ensureDefaultPersonProfile();
    final applied = await repo.setActiveProfileId(999);
    expect(applied, HealthRepository.defaultProfileId);
  });

  test('删除成员：级联删除其数据，本人数据不受影响，并回落到「本人」', () async {
    await repo.ensureDefaultPersonProfile();
    await addMetricForActive('SELF_A');
    final dadId = await repo.insertPersonProfile(displayName: '爸爸', relationship: '父亲');
    await repo.setActiveProfileId(dadId);
    await addMetricForActive('DAD_A');
    await repo.insertDisease(name: '糖尿病');
    await repo.insertMedication(name: '二甲双胍');

    await repo.deletePersonProfileCascade(dadId);

    expect(repo.activeProfileId, HealthRepository.defaultProfileId);
    expect(await repo.getAllPersonProfiles(), hasLength(1));
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['SELF_A']);
    // 直接读整表确认爸爸的行确实没了
    final allMetrics = await db.select(db.healthMetrics).get();
    expect(allMetrics.every((m) => m.profileId == HealthRepository.defaultProfileId),
        isTrue);
    expect(await db.select(db.diseases).get(), isEmpty);
    expect(await db.select(db.medications).get(), isEmpty);
  });

  test('不能删除「本人」，也不能删到一个都不剩', () async {
    await repo.ensureDefaultPersonProfile();
    expect(
      () => repo.deletePersonProfileCascade(HealthRepository.defaultProfileId),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => repo.deletePersonProfileCascade(12345),
      throwsA(isA<StateError>()),
    );
  });

  test('getProfile / upsertProfile 作用在当前档案上', () async {
    await repo.ensureDefaultPersonProfile();
    await repo.upsertProfile(nickname: '本人甲', gender: '男', heightCm: 175);

    final sisId = await repo.insertPersonProfile(displayName: '妹妹', relationship: '其他');
    await repo.setActiveProfileId(sisId);
    var view = await repo.getProfile();
    expect(view!.nickname, '妹妹');
    expect(view.heightCm, isNull);

    await repo.upsertProfile(nickname: '妹妹', gender: '女', heightCm: 162);
    view = await repo.getProfile();
    expect(view!.gender, '女');
    expect(view.heightCm, 162);

    // 本人档案没被改动
    await repo.setActiveProfileId(HealthRepository.defaultProfileId);
    view = await repo.getProfile();
    expect(view!.nickname, '本人甲');
    expect(view.heightCm, 175);
  });

  test('exportHealthData 覆盖全部人员（不受当前档案影响）', () async {
    await repo.ensureDefaultPersonProfile();
    await addMetricForActive('SELF_A');
    final mId = await repo.insertPersonProfile(displayName: '妈妈', relationship: '母亲');
    await repo.setActiveProfileId(mId);
    await addMetricForActive('MOM_A');

    // 当前在妈妈档案下导出，仍应包含本人的数据和两个人员档案
    final data = await repo.exportHealthData();
    final persons = (data['personProfiles'] as List).cast<Map>();
    expect(persons.map((p) => p['displayName']), containsAll(['本人', '妈妈']));
    final metricIds =
        (data['metrics'] as List).cast<Map>().map((m) => m['metricId']);
    expect(metricIds, containsAll(['SELF_A', 'MOM_A']));
  });
}
