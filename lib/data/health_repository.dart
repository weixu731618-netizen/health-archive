import 'package:drift/drift.dart';

import 'app_database.dart';

/// 展示层用的「当前档案资料」轻量视图（字段名沿用旧的 user_profile，减少页面改动）。
class ProfileView {
  final int personId;
  final String relationship;
  final String nickname;
  final String gender;
  final DateTime? birthDate;
  final double? heightCm;

  const ProfileView({
    required this.personId,
    required this.relationship,
    required this.nickname,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
  });

  factory ProfileView.fromPerson(PersonProfile p) => ProfileView(
        personId: p.id,
        relationship: p.relationship,
        nickname: p.displayName,
        gender: p.sex ?? '',
        birthDate: p.dateOfBirth,
        heightCm: p.heightCm,
      );
}

/// 数据访问层：封装对本地数据库的读写。
/// 页面通过这个类操作数据，不直接接触 SQL。
class HealthRepository {
  final AppDatabase _db;

  HealthRepository(this._db);

  static const int defaultProfileId = 1;

  /// B1：当前正在查看 / 录入的人员档案 id。默认「本人」(1)。
  /// 由 UI（档案切换器）通过 [setActiveProfileId] 修改，并在 App 层持久化。
  int _activeProfileId = defaultProfileId;
  int get activeProfileId => _activeProfileId;

  /// 切换当前档案。会校验目标档案存在，不存在则回落到「本人」。
  Future<int> setActiveProfileId(int id) async {
    final exists = await getPersonProfile(id) != null;
    _activeProfileId = exists ? id : defaultProfileId;
    return _activeProfileId;
  }

  // ---------- 人员档案（B1：本人 + 家庭成员） ----------

  /// 确保默认“本人”档案(id=1)存在。旧数据都归属该档案。
  Future<PersonProfile> ensureDefaultPersonProfile() async {
    final existing = await getPersonProfile(defaultProfileId);
    if (existing != null) return existing;
    final now = DateTime.now();
    await _db.into(_db.personProfiles).insert(
          PersonProfilesCompanion.insert(
            id: const Value(defaultProfileId),
            displayName: const Value('本人'),
            relationship: const Value('self'),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    return (await getPersonProfile(defaultProfileId))!;
  }

  Future<PersonProfile?> getPersonProfile(int id) {
    final q = _db.select(_db.personProfiles)..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  Future<List<PersonProfile>> getAllPersonProfiles() async {
    await ensureDefaultPersonProfile();
    final q = _db.select(_db.personProfiles)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return q.get();
  }

  Future<int> countPersonProfiles() async {
    final rows = await getAllPersonProfiles();
    return rows.length;
  }

  /// 新增一个家庭成员，返回新档案 id。
  Future<int> insertPersonProfile({
    required String displayName,
    String relationship = 'other',
    String? sex,
    DateTime? dateOfBirth,
    double? heightCm,
  }) async {
    await ensureDefaultPersonProfile();
    final now = DateTime.now();
    return _db.into(_db.personProfiles).insert(
          PersonProfilesCompanion.insert(
            displayName: Value(displayName),
            relationship: Value(relationship),
            sex: Value(sex),
            dateOfBirth: Value(dateOfBirth),
            heightCm: Value(heightCm),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// 更新一个人员档案的资料字段。
  Future<void> updatePersonProfileFields(
    int id, {
    String? displayName,
    String? relationship,
    String? sex,
    DateTime? dateOfBirth,
    double? heightCm,
  }) async {
    await (_db.update(_db.personProfiles)..where((t) => t.id.equals(id))).write(
      PersonProfilesCompanion(
        displayName:
            displayName == null ? const Value.absent() : Value(displayName),
        relationship:
            relationship == null ? const Value.absent() : Value(relationship),
        sex: Value(sex),
        dateOfBirth: Value(dateOfBirth),
        heightCm: Value(heightCm),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 某个档案下所有报告的本地原图路径（删除成员前用来清理磁盘文件）。
  Future<List<String>> listReportImagePathsForProfile(int id) async {
    final rows = await (_db.select(_db.medicalReports)
          ..where((t) => t.profileId.equals(id)))
        .get();
    return [
      for (final r in rows)
        if ((r.sourceImagePath ?? '').isNotEmpty) r.sourceImagePath!,
    ];
  }

  /// 删除一个家庭成员及其全部健康数据（级联）。
  /// - 不允许删除「本人」(id=1)，也不允许删到一个都不剩。
  /// - 返回删除后应切到的档案 id（总是回落到「本人」）。
  /// 调用方必须先弹二次确认。报告原图文件的清理由上层负责。
  Future<int> deletePersonProfileCascade(int id) async {
    if (id == defaultProfileId) {
      throw ArgumentError('不能删除「本人」档案');
    }
    final all = await getAllPersonProfiles();
    if (all.length <= 1 || !all.any((p) => p.id == id)) {
      throw StateError('该档案不存在或不可删除');
    }
    await _db.transaction(() async {
      await (_db.delete(_db.healthMetrics)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.dailyHealthRecords)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.medicalReports)
            ..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.diseases)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.medications)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.reminders)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.personProfiles)..where((t) => t.id.equals(id))).go();
    });
    if (_activeProfileId == id) _activeProfileId = defaultProfileId;
    return _activeProfileId;
  }

  /// 当前档案的展示资料（昵称 / 性别 / 生日 / 身高）。
  Future<ProfileView?> getActiveProfileView() async {
    final p = await getPersonProfile(_activeProfileId) ??
        await ensureDefaultPersonProfile();
    return ProfileView.fromPerson(p);
  }

  /// 更新当前档案的资料。
  Future<void> updateActiveProfile({
    String? nickname,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
  }) async {
    // 兼容旧行为：以前 upsertProfile 会先建默认「本人」再写。
    if (_activeProfileId == defaultProfileId) {
      await ensureDefaultPersonProfile();
    }
    await updatePersonProfileFields(
      _activeProfileId,
      displayName: nickname,
      sex: gender,
      dateOfBirth: birthDate,
      heightCm: heightCm,
    );
  }

  // ---------- 手工录入的检查指标 ----------

  /// 新增一条检查指标记录。
  /// 注：为兼容较旧版本的 SQLite（宿主机测试环境），不使用 insertReturning，
  /// 而是先插入再用返回的自增 id 读取回完整记录。
  Future<HealthMetric> insertMetric({
    int? profileId,
    required String metricId,
    required String metricName,
    required double value,
    String? rawValue,
    double? numericValue,
    required String unit,
    double? canonicalValue,
    String? canonicalUnit,
    required double? referenceMin,
    required double? referenceMax,
    String? referenceRangeRaw,
    String? sourceAbnormalFlag,
    required String status,
    required String bodySystem,
    required DateTime measuredAt,
    String sourceType = 'manual',
    String? notes,
    int? reportId, // V0.4A：所属报告 id，手工录入为 null
    String? rawName, // V0.4D：原报告指标名
    String matchType = 'manual', // V0.4D：exact/alias/ai_suggested/unmatched/manual
    double? recognitionConfidence, // V0.4D：识别置信度
    String verificationStatus = 'user_confirmed',
    int? sourcePage,
    String? sourceBoundingBox,
  }) async {
    await ensureDefaultPersonProfile();
    final now = DateTime.now();
    final newId = await _db.into(_db.healthMetrics).insert(
          HealthMetricsCompanion.insert(
            profileId: Value(profileId ?? _activeProfileId),
            metricId: metricId,
            metricName: metricName,
            value: value,
            rawValue: Value(rawValue),
            numericValue: Value(numericValue),
            unit: unit,
            canonicalValue: Value(canonicalValue),
            canonicalUnit: Value(canonicalUnit),
            referenceMin: Value(referenceMin),
            referenceMax: Value(referenceMax),
            referenceRangeRaw: Value(referenceRangeRaw),
            sourceAbnormalFlag: Value(sourceAbnormalFlag),
            status: status,
            bodySystem: bodySystem,
            measuredAt: measuredAt,
            sourceType: Value(sourceType),
            notes: Value(notes),
            reportId: Value(reportId),
            rawName: Value(rawName),
            matchType: Value(matchType),
            recognitionConfidence: Value(recognitionConfidence),
            verificationStatus: Value(verificationStatus),
            sourcePage: Value(sourcePage),
            sourceBoundingBox: Value(sourceBoundingBox),
            createdAt: now,
          ),
        );
    return (await getMetricById(newId))!;
  }

  /// 按 id 查询一条检查指标记录
  Future<HealthMetric?> getMetricById(int id) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  /// 更新一条检查指标记录
  Future<bool> updateMetric(HealthMetric metric) {
    return _db.update(_db.healthMetrics).replace(metric);
  }

  /// 删除一条检查指标记录
  Future<int> deleteMetric(int id) {
    return (_db.delete(_db.healthMetrics)..where((t) => t.id.equals(id))).go();
  }

  /// 查询全部检查指标记录（按测量日期倒序，最新在前）
  Future<List<HealthMetric>> getAllMetrics() {
    final q = _db.select(_db.healthMetrics)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 查询某个身体系统的检查指标记录（最新在前）
  Future<List<HealthMetric>> getMetricsByBodySystem(String bodySystem) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) & t.bodySystem.equals(bodySystem))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 查询某指标 id 的所有历史记录（最新在前）
  Future<List<HealthMetric>> getMetricHistory(String metricId) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) & t.metricId.equals(metricId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  // ---------- 日常健康记录 ----------

  /// 新增一条日常记录。
  /// 注：为兼容较旧版本的 SQLite（宿主机测试环境），不使用 insertReturning。
  Future<DailyHealthRecord> insertDaily({
    int? profileId,
    required String type,
    required double value1,
    double? value2,
    required String unit,
    String? context,
    required DateTime measuredAt,
    String? notes,
  }) async {
    await ensureDefaultPersonProfile();
    final now = DateTime.now();
    final newId = await _db.into(_db.dailyHealthRecords).insert(
          DailyHealthRecordsCompanion.insert(
            profileId: Value(profileId ?? _activeProfileId),
            type: type,
            value1: value1,
            value2: Value(value2),
            unit: unit,
            context: Value(context),
            measuredAt: measuredAt,
            notes: Value(notes),
            createdAt: now,
          ),
        );
    return (await getDailyById(newId))!;
  }

  /// 按 id 查询一条日常记录
  Future<DailyHealthRecord?> getDailyById(int id) {
    final q = _db.select(_db.dailyHealthRecords)
      ..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  /// 更新一条日常记录
  Future<bool> updateDaily(DailyHealthRecord record) {
    return _db.update(_db.dailyHealthRecords).replace(record);
  }

  /// 删除一条日常记录
  Future<int> deleteDaily(int id) {
    return (_db.delete(_db.dailyHealthRecords)..where((t) => t.id.equals(id))).go();
  }

  /// 查询全部日常记录（按测量日期倒序，最新在前）
  Future<List<DailyHealthRecord>> getAllDailyRecords() {
    final q = _db.select(_db.dailyHealthRecords)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  // ---------- 化验单报告（V0.4A） ----------

  /// 新增一份报告，返回其 id。
  Future<int> insertReport({
    int? profileId,
    required String hospitalName,
    required DateTime reportDate,
    required String reportType,
    String? sourceImagePath,
    String? rawText,
    List<String> tags = const [],
    String recognitionStatus = 'review', // V0.4B：识别后进入确认阶段；确认保存后置 confirmed
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.medicalReports).insert(
          MedicalReportsCompanion.insert(
            profileId: Value(profileId ?? _activeProfileId),
            hospitalName: hospitalName,
            reportDate: reportDate,
            reportType: reportType,
            sourceImagePath: Value(sourceImagePath),
            rawText: Value(rawText),
            tags: Value(normalizeTags(tags)),
            recognitionStatus: Value(recognitionStatus),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 查询全部报告（按日期倒序，最新在前）
  Future<List<MedicalReport>> getAllReports() {
    final q = _db.select(_db.medicalReports)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.reportDate)]);
    return q.get();
  }

  /// 按 id 查询一份报告
  Future<MedicalReport?> getReportById(int id) {
    final q = _db.select(_db.medicalReports)
      ..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  /// 查询某份报告关联的所有检查指标（按测量日期倒序）
  Future<List<HealthMetric>> getMetricsByReport(int reportId) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) & t.reportId.equals(reportId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 删除一份报告及其关联的所有检查指标（级联删除）。
  /// 此操作带破坏性，调用方必须先弹二次确认。
  Future<void> deleteReportCascade(int reportId) async {
    await (_db.delete(_db.healthMetrics)..where((t) => t.reportId.equals(reportId)))
        .go();
    await (_db.delete(_db.medicalReports)..where((t) => t.id.equals(reportId))).go();
  }

  /// 更新一份报告的识别状态（pending / processing / review / confirmed / failed）
  Future<bool> setReportStatus(int reportId, String status) async {
    return await (_db.update(_db.medicalReports)
          ..where((t) => t.id.equals(reportId)))
        .write(MedicalReportsCompanion(
      recognitionStatus: Value(status),
    )) > 0;
  }

  // ---------- B3：报告标签 ----------

  /// 把标签列表标准化：去空白、去空项、去重、按原顺序，逗号连接存库。
  static String normalizeTags(Iterable<String> tags) {
    final seen = <String>[];
    for (final raw in tags) {
      final t = raw.trim();
      if (t.isEmpty || t.contains(',') || seen.contains(t)) continue;
      seen.add(t);
    }
    return seen.join(',');
  }

  static List<String> parseTags(String? stored) {
    if (stored == null || stored.trim().isEmpty) return const [];
    return [
      for (final s in stored.split(','))
        if (s.trim().isNotEmpty) s.trim(),
    ];
  }

  Future<void> setReportTags(int reportId, List<String> tags) =>
      (_db.update(_db.medicalReports)..where((t) => t.id.equals(reportId)))
          .write(MedicalReportsCompanion(tags: Value(normalizeTags(tags))));

  /// 当前档案下所有报告用过的标签（去重，按使用频次降序）。
  Future<List<String>> getDistinctReportTags() async {
    final reports = await getAllReports();
    final freq = <String, int>{};
    for (final r in reports) {
      for (final t in parseTags(r.tags)) {
        freq[t] = (freq[t] ?? 0) + 1;
      }
    }
    final list = freq.keys.toList()
      ..sort((a, b) => freq[b]!.compareTo(freq[a]!));
    return list;
  }

  /// 当前档案下所有报告出现过的医院名（去重、非空、按名称排序）。
  Future<List<String>> getDistinctHospitals() async {
    final reports = await getAllReports();
    final set = <String>{
      for (final r in reports)
        if (r.hospitalName.trim().isNotEmpty) r.hospitalName.trim(),
    };
    final list = set.toList()..sort();
    return list;
  }

  // ---------- 疾病史（MVP） ----------

  Future<int> insertDisease({
    int? profileId,
    required String name,
    DateTime? foundDate,
    String status = '不确定',
    String? notes,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.diseases).insert(DiseasesCompanion.insert(
      profileId: Value(profileId ?? _activeProfileId),
      name: name,
      foundDate: Value(foundDate),
      status: Value(status),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<List<Disease>> getAllDiseases() {
    final q = _db.select(_db.diseases)
      ..where((t) => t.profileId.equals(_activeProfileId));
    return q.get();
  }

  Future<int> deleteDisease(int id) {
    return (_db.delete(_db.diseases)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> updateDisease(Disease d) async {
    final ok = await _db.update(_db.diseases).replace(d);
    return ok;
  }

  // ---------- 用药记录（MVP） ----------

  Future<int> insertMedication({
    int? profileId,
    required String name,
    String? dosage,
    String? dosageUnit,
    String? timesPerDay,
    DateTime? startDate,
    DateTime? endDate,
    String status = '当前使用',
    String? notes,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.medications).insert(MedicationsCompanion.insert(
      profileId: Value(profileId ?? _activeProfileId),
      name: name,
      dosage: Value(dosage),
      dosageUnit: Value(dosageUnit),
      timesPerDay: Value(timesPerDay),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<List<Medication>> getAllMedications() {
    final q = _db.select(_db.medications)
      ..where((t) => t.profileId.equals(_activeProfileId));
    return q.get();
  }

  Future<int> deleteMedication(int id) {
    return (_db.delete(_db.medications)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> updateMedication(Medication m) async {
    return _db.update(_db.medications).replace(m);
  }

  // ---------- 个人资料（B1：当前档案；旧方法名保留给页面）----------

  /// 兼容旧调用名：返回**当前档案**的展示资料。
  Future<ProfileView?> getProfile() => getActiveProfileView();

  /// 兼容旧调用名：更新**当前档案**的资料。
  Future<void> upsertProfile({
    String nickname = '',
    String gender = '',
    DateTime? birthDate,
    double? heightCm,
  }) =>
      updateActiveProfile(
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        heightCm: heightCm,
      );

  /// 备份恢复用：按原始 id 重建一个人员档案（覆盖已存在的同 id 行）。
  Future<void> restorePersonProfile({
    required int id,
    required String displayName,
    String relationship = 'other',
    String? sex,
    DateTime? dateOfBirth,
    double? heightCm,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.personProfiles).insert(
          PersonProfilesCompanion.insert(
            id: Value(id),
            displayName: Value(displayName),
            relationship: Value(relationship),
            sex: Value(sex),
            dateOfBirth: Value(dateOfBirth),
            heightCm: Value(heightCm),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // ---------- B2：备忘 / 提醒 ----------

  /// 当前档案的提醒（默认不含已标记完成的）。
  Future<List<Reminder>> getActiveReminders({bool includeCompleted = false}) {
    final q = _db.select(_db.reminders)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.dueDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    if (!includeCompleted) {
      q.where((t) => t.completedAt.isNull());
    }
    return q.get();
  }

  /// 全部档案里「启用且未完成」的提醒——用于把系统通知与数据库对齐。
  Future<List<Reminder>> getAllSchedulableReminders() {
    final q = _db.select(_db.reminders)
      ..where((t) => t.enabled.equals(true) & t.completedAt.isNull());
    return q.get();
  }

  Future<Reminder?> getReminderById(int id) =>
      (_db.select(_db.reminders)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertReminder({
    int? profileId,
    required String kind,
    required String title,
    String? detail,
    String? relatedMetricId,
    int? relatedMedicationId,
    DateTime? dueDate,
    List<String>? dailyTimes,
    bool enabled = true,
  }) async {
    await ensureDefaultPersonProfile();
    final now = DateTime.now();
    return _db.into(_db.reminders).insert(
          RemindersCompanion.insert(
            profileId: Value(profileId ?? _activeProfileId),
            kind: kind,
            title: title,
            detail: Value(detail),
            relatedMetricId: Value(relatedMetricId),
            relatedMedicationId: Value(relatedMedicationId),
            dueDate: Value(dueDate),
            dailyTimes: Value(dailyTimes?.join(',')),
            enabled: Value(enabled),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> setReminderEnabled(int id, bool enabled) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          enabled: Value(enabled),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markReminderCompleted(int id) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          completedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteReminder(int id) =>
      (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();

  /// 当前档案下、指定指标未完成的复查提醒（用于指标历史页显示「已设」状态）。
  Future<Reminder?> getRecheckReminderForMetric(String metricId) =>
      (_db.select(_db.reminders)
            ..where((t) =>
                t.profileId.equals(_activeProfileId) &
                t.relatedMetricId.equals(metricId) &
                t.kind.equals('recheck') &
                t.completedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

  Future<Reminder?> getMedicationReminder(int medicationId) =>
      (_db.select(_db.reminders)
            ..where((t) => t.relatedMedicationId.equals(medicationId))
            ..limit(1))
          .getSingleOrNull();

  /// 用药编辑页保存服药提醒：开启则新增/更新，关闭或无时间点则删除。
  Future<void> setMedicationReminder({
    required int medicationId,
    required int profileId,
    required String medName,
    required List<String> times,
    required bool enabled,
    String? detail,
  }) async {
    final existing = await getMedicationReminder(medicationId);
    if (!enabled || times.isEmpty) {
      if (existing != null) await deleteReminder(existing.id);
      return;
    }
    final now = DateTime.now();
    if (existing == null) {
      await _db.into(_db.reminders).insert(
            RemindersCompanion.insert(
              profileId: Value(profileId),
              kind: 'medication',
              title: medName,
              detail: Value(detail),
              relatedMedicationId: Value(medicationId),
              dailyTimes: Value(times.join(',')),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.reminders)..where((t) => t.id.equals(existing.id)))
          .write(RemindersCompanion(
        title: Value(medName),
        detail: Value(detail),
        dailyTimes: Value(times.join(',')),
        enabled: const Value(true),
        updatedAt: Value(now),
      ));
    }
  }

  Future<void> deleteMedicationReminder(int medicationId) => (_db.delete(
          _db.reminders)
        ..where((t) => t.relatedMedicationId.equals(medicationId)))
      .go();

  // ---------- B2：通知记录（应用内通知中心 + 系统推送共用）----------

  Future<List<NotificationRecord>> getNotifications({int limit = 200}) {
    final q = _db.select(_db.notifications)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.scheduledFor)])
      ..limit(limit);
    return q.get();
  }

  Future<int> unreadNotificationCount() async {
    final rows = await (_db.select(_db.notifications)
          ..where((t) =>
              t.profileId.equals(_activeProfileId) &
              t.readAt.isNull() &
              t.deliveredAt.isNotNull()))
        .get();
    return rows.length;
  }

  Future<int> insertNotification({
    int? profileId,
    int? reminderId,
    required String category,
    required String title,
    String? body,
    required DateTime scheduledFor,
    DateTime? deliveredAt,
    String channel = 'local',
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.notifications).insert(
          NotificationsCompanion.insert(
            profileId: Value(profileId ?? _activeProfileId),
            reminderId: Value(reminderId),
            category: category,
            title: title,
            body: Value(body),
            scheduledFor: scheduledFor,
            deliveredAt: Value(deliveredAt),
            channel: Value(channel),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> markNotificationRead(int id) =>
      (_db.update(_db.notifications)..where((t) => t.id.equals(id)))
          .write(NotificationsCompanion(readAt: Value(DateTime.now())));

  Future<void> markAllNotificationsRead() =>
      (_db.update(_db.notifications)
            ..where((t) =>
                t.profileId.equals(_activeProfileId) & t.readAt.isNull()))
          .write(NotificationsCompanion(readAt: Value(DateTime.now())));

  Future<void> deleteNotification(int id) =>
      (_db.delete(_db.notifications)..where((t) => t.id.equals(id))).go();

  /// 幂等：把「当前档案未完成的提醒」落成 notifications 行——
  /// 复查提醒各 1 行（到期日 09:00），服药提醒补齐「今天」各时间点 1 行；
  /// 再把已过计划时间但未标记送达的行标记为已送达。返回本次新建条数。
  Future<int> syncNotificationsFromReminders({DateTime? now}) async {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final reminders = await getActiveReminders();
    final existing = await getNotifications(limit: 1000);
    var inserted = 0;

    bool has(int reminderId, DateTime when) => existing.any((n) =>
        n.reminderId == reminderId &&
        n.scheduledFor.isAtSameMomentAs(when));

    for (final r in reminders) {
      if (!r.enabled) continue;
      if (r.kind == 'recheck' && r.dueDate != null) {
        final when = DateTime(
            r.dueDate!.year, r.dueDate!.month, r.dueDate!.day, 9);
        if (!has(r.id, when)) {
          await insertNotification(
            reminderId: r.id,
            category: 'recheck',
            title: r.title,
            body: r.detail,
            scheduledFor: when,
            deliveredAt: when.isBefore(ref) ? when : null,
          );
          inserted++;
        }
      } else if (r.kind == 'medication') {
        for (final raw in (r.dailyTimes ?? '').split(',')) {
          final parts = raw.trim().split(':');
          if (parts.length != 2) continue;
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h == null || m == null) continue;
          final when = DateTime(today.year, today.month, today.day, h, m);
          if (!has(r.id, when)) {
            await insertNotification(
              reminderId: r.id,
              category: 'medication',
              title: '该服药：${r.title}',
              body: r.detail,
              scheduledFor: when,
              deliveredAt: when.isBefore(ref) ? when : null,
            );
            inserted++;
          }
        }
      }
    }

    // 已过计划时间但没标送达的，补上送达时间（本地通知已弹过）。
    for (final n in existing) {
      if (n.deliveredAt == null && n.scheduledFor.isBefore(ref)) {
        await (_db.update(_db.notifications)..where((t) => t.id.equals(n.id)))
            .write(NotificationsCompanion(deliveredAt: Value(n.scheduledFor)));
      }
    }
    return inserted;
  }

  /// 备份恢复用：按快照字段重建一条提醒（profileId 沿用备份里的原值）。
  Future<void> restoreReminder({
    required int profileId,
    required String kind,
    required String title,
    String? detail,
    String? relatedMetricId,
    int? relatedMedicationId,
    DateTime? dueDate,
    String? dailyTimes,
    bool enabled = true,
    DateTime? completedAt,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.reminders).insert(
          RemindersCompanion.insert(
            profileId: Value(profileId),
            kind: kind,
            title: title,
            detail: Value(detail),
            relatedMetricId: Value(relatedMetricId),
            relatedMedicationId: Value(relatedMedicationId),
            dueDate: Value(dueDate),
            dailyTimes: Value(dailyTimes),
            enabled: Value(enabled),
            completedAt: Value(completedAt),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // ---------- MVP：导出 / 删除 ----------

  /// 汇总**全部人员**的健康数据为可 JSON 序列化的 map（不含原始图片内容）。
  /// 注：这里刻意不走按当前档案过滤的 getAllXxx，而是直接读整表，保证「完整备份」。
  Future<Map<String, dynamic>> exportHealthData() async {
    String? iso(DateTime? d) => d?.toIso8601String();
    final persons = await getAllPersonProfiles();
    final self = persons.firstWhere((p) => p.id == defaultProfileId,
        orElse: () => persons.first);
    final allMetrics = await _db.select(_db.healthMetrics).get();
    final allDaily = await _db.select(_db.dailyHealthRecords).get();
    final allReports = await _db.select(_db.medicalReports).get();
    final allDiseases = await _db.select(_db.diseases).get();
    final allMeds = await _db.select(_db.medications).get();
    final metricCountByReport = <int, int>{};
    for (final m in allMetrics) {
      final rid = m.reportId;
      if (rid != null) {
        metricCountByReport[rid] = (metricCountByReport[rid] ?? 0) + 1;
      }
    }
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'nickname': self.displayName,
        'gender': self.sex ?? '',
        'birthDate': iso(self.dateOfBirth),
        'heightCm': self.heightCm,
      },
      'personProfiles': [
        for (final p in persons)
          {
            'id': p.id,
            'displayName': p.displayName,
            'relationship': p.relationship,
            'sex': p.sex,
            'dateOfBirth': iso(p.dateOfBirth),
            'heightCm': p.heightCm,
          },
      ],
      'metrics': [
        for (final m in allMetrics)
          {
            'id': m.id,
            'profileId': m.profileId,
            'metricId': m.metricId,
            'metricName': m.metricName,
            'rawName': m.rawName,
            'rawValue': m.rawValue,
            'numericValue': m.numericValue,
            'matchType': m.matchType,
            'value': m.value,
            'unit': m.unit,
            'canonicalValue': m.canonicalValue,
            'canonicalUnit': m.canonicalUnit,
            'referenceMin': m.referenceMin,
            'referenceMax': m.referenceMax,
            'referenceRangeRaw': m.referenceRangeRaw,
            'sourceAbnormalFlag': m.sourceAbnormalFlag,
            'status': m.status,
            'bodySystem': m.bodySystem,
            'measuredAt': iso(m.measuredAt),
            'sourceType': m.sourceType,
            'notes': m.notes,
            'reportId': m.reportId,
            'verificationStatus': m.verificationStatus,
            'sourcePage': m.sourcePage,
            'sourceBoundingBox': m.sourceBoundingBox,
          },
      ],
      'dailyRecords': [
        for (final d in allDaily)
          {
            'id': d.id,
            'profileId': d.profileId,
            'type': d.type,
            'value1': d.value1,
            'value2': d.value2,
            'unit': d.unit,
            'context': d.context,
            'measuredAt': iso(d.measuredAt),
            'notes': d.notes,
          },
      ],
      'reports': [
        for (final r in allReports)
          {
            'id': r.id,
            'profileId': r.profileId,
            'hospitalName': r.hospitalName,
            'reportDate': iso(r.reportDate),
            'reportType': r.reportType,
            'sourceImagePath': r.sourceImagePath,
            // 影像/病理等图文报告的核心内容就是这段结论文字，必须随备份带走。
            'rawText': r.rawText,
            'tags': r.tags,
            'recognitionStatus': r.recognitionStatus,
            'metricCount': metricCountByReport[r.id] ?? 0,
          },
      ],
      'diseases': [
        for (final d in allDiseases)
          {
            'id': d.id,
            'profileId': d.profileId,
            'name': d.name,
            'foundDate': iso(d.foundDate),
            'status': d.status,
            'notes': d.notes,
          },
      ],
      'medications': [
        for (final m in allMeds)
          {
            'id': m.id,
            'profileId': m.profileId,
            'name': m.name,
            'dosage': m.dosage,
            'dosageUnit': m.dosageUnit,
            'timesPerDay': m.timesPerDay,
            'startDate': iso(m.startDate),
            'endDate': iso(m.endDate),
            'status': m.status,
            'notes': m.notes,
          },
      ],
      'reminders': [
        for (final r in await _db.select(_db.reminders).get())
          {
            'id': r.id,
            'profileId': r.profileId,
            'kind': r.kind,
            'title': r.title,
            'detail': r.detail,
            'relatedMetricId': r.relatedMetricId,
            'relatedMedicationId': r.relatedMedicationId,
            'dueDate': iso(r.dueDate),
            'dailyTimes': r.dailyTimes,
            'enabled': r.enabled,
            'completedAt': iso(r.completedAt),
          },
      ],
    };
  }

  /// 删除全部本地健康数据（各表清空）。
  /// 注意：原始报告图片的清理由上层（按 report_images 目录）负责。
  Future<void> clearAllHealthData() async {
    await _db.transaction(() async {
      await _db.delete(_db.healthMetrics).go();
      await _db.delete(_db.dailyHealthRecords).go();
      await _db.delete(_db.medicalReports).go();
      await _db.delete(_db.diseases).go();
      await _db.delete(_db.medications).go();
      await _db.delete(_db.reminders).go();
      await _db.delete(_db.userProfile).go();
      await _db.delete(_db.personProfiles).go();
    });
    _activeProfileId = defaultProfileId;
    await ensureDefaultPersonProfile();
  }

  /// 在同一个数据库事务里执行 [action]。
  ///
  /// 用于「先清空再重建」这类多步骤操作（如备份恢复）：只要 [action] 还没正常
  /// 返回就提交，App 中途崩溃/被杀不会提交任何一半的改动，重启后仍是操作前的
  /// 完整数据，不会出现「清空了但没写完」的中间态。
  Future<T> transaction<T>(Future<T> Function() action) =>
      _db.transaction(action);
}
