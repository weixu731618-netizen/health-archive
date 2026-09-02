import 'package:drift/drift.dart';

import '../models/metric_dictionary.dart'
    show
        matchMetricId,
        findMetricDefinition,
        bodySystemForMetric,
        guessSystemForRawName;
import '../services/followup_scheduler.dart';
import '../utils/patient_name_match.dart';
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

  /// 把一组写操作放进一个事务里执行：任一步抛异常则整体回滚。
  /// 用于「保存报告 + 批量写指标」这类必须全成功或全失败的场景。
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

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

  /// 读某个档案「认识的真名」串（person_profiles.knownNames，逗号分隔）。
  Future<String> getKnownNames(int profileId) async {
    final p = await getPersonProfile(profileId);
    return p?.knownNames ?? '';
  }

  /// 往某个档案的「认识的真名」里并入一个名字（宽松去重）。空名不写。
  Future<void> addKnownName(int profileId, String name) async {
    if (name.trim().isEmpty) return;
    final current = await getKnownNames(profileId);
    final next = appendKnownName(current, name);
    if (next == current) return;
    await (_db.update(_db.personProfiles)..where((t) => t.id.equals(profileId)))
        .write(PersonProfilesCompanion(
      knownNames: Value(next),
      updatedAt: Value(DateTime.now()),
    ));
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
      await (_db.delete(_db.encounters)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.allergies)..where((t) => t.profileId.equals(id)))
          .go();
      await (_db.delete(_db.personProfiles)..where((t) => t.id.equals(id)))
          .go();
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
    String? sourceId, // 3-1：通用来源标识（HealthKit 样本 id / 设备 id 等），可空
    String? notes,
    int? reportId, // V0.4A：所属报告 id，手工录入为 null
    String? rawName, // V0.4D：原报告指标名
    String matchType =
        'manual', // V0.4D：exact/alias/ai_suggested/unmatched/manual
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
            sourceId: Value(sourceId),
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
    final q = _db.select(_db.healthMetrics)..where((t) => t.id.equals(id));
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
          t.profileId.equals(_activeProfileId) &
          t.bodySystem.equals(bodySystem))
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
    final q = _db.select(_db.dailyHealthRecords)..where((t) => t.id.equals(id));
    return q.getSingleOrNull();
  }

  /// 更新一条日常记录
  Future<bool> updateDaily(DailyHealthRecord record) {
    return _db.update(_db.dailyHealthRecords).replace(record);
  }

  /// 删除一条日常记录
  Future<int> deleteDaily(int id) {
    return (_db.delete(_db.dailyHealthRecords)..where((t) => t.id.equals(id)))
        .go();
  }

  /// 查询全部日常记录（按测量日期倒序，最新在前）
  Future<List<DailyHealthRecord>> getAllDailyRecords() {
    final q = _db.select(_db.dailyHealthRecords)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 查询某一类日常记录的历史（weight / blood_pressure / blood_glucose / heart_rate），
  /// 按测量日期倒序。用于日常记录的趋势历史页。
  Future<List<DailyHealthRecord>> getDailyRecordsByType(String type) {
    final q = _db.select(_db.dailyHealthRecords)
      ..where((t) => t.profileId.equals(_activeProfileId) & t.type.equals(type))
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
    String? conditionCode,
    int? encounterId,
    String? examSummary,
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
            conditionCode: Value(conditionCode),
            encounterId: Value(encounterId),
            examSummary: Value(examSummary),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 更新报告的主关联慢病（null 清除关联）。
  Future<void> setReportCondition(int reportId, String? conditionCode) =>
      (_db.update(_db.medicalReports)..where((t) => t.id.equals(reportId)))
          .write(MedicalReportsCompanion(conditionCode: Value(conditionCode)));

  /// 把报告归属到某次就诊（null 解除归属）。
  Future<void> setReportEncounter(int reportId, int? encounterId) =>
      (_db.update(_db.medicalReports)..where((t) => t.id.equals(reportId)))
          .write(MedicalReportsCompanion(encounterId: Value(encounterId)));

  // ---------- 慢病升级 步骤5：就诊记录 ----------

  Future<int> insertEncounter({
    int? profileId,
    required DateTime visitDate,
    String hospitalName = '',
    String department = '',
    String? diagnosis,
    String? advice,
    String? notes,
    String? conditionCode,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.encounters).insert(EncountersCompanion.insert(
          profileId: Value(profileId ?? _activeProfileId),
          visitDate: visitDate,
          hospitalName: Value(hospitalName),
          department: Value(department),
          diagnosis: Value(diagnosis),
          advice: Value(advice),
          notes: Value(notes),
          conditionCode: Value(conditionCode),
          createdAt: DateTime.now(),
        ));
  }

  Future<List<Encounter>> getAllEncounters() {
    final q = _db.select(_db.encounters)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.visitDate)]);
    return q.get();
  }

  Future<Encounter?> getEncounterById(int id) =>
      (_db.select(_db.encounters)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<bool> updateEncounter(Encounter e) =>
      _db.update(_db.encounters).replace(e);

  /// 删除一次就诊：其下报告的 encounterId 置空（报告本身保留）。
  Future<void> deleteEncounter(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.medicalReports)
            ..where((t) => t.encounterId.equals(id)))
          .write(const MedicalReportsCompanion(encounterId: Value(null)));
      await (_db.delete(_db.encounters)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<MedicalReport>> getReportsForEncounter(int encounterId) {
    final q = _db.select(_db.medicalReports)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) &
          t.encounterId.equals(encounterId))
      ..orderBy([(t) => OrderingTerm.desc(t.reportDate)]);
    return q.get();
  }

  // ---------- 慢病升级 步骤5：过敏史 ----------

  Future<int> insertAllergy({
    int? profileId,
    required String substance,
    String category = '药物',
    String? reaction,
    String severity = '不确定',
    DateTime? notedDate,
    String? notes,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.allergies).insert(AllergiesCompanion.insert(
          profileId: Value(profileId ?? _activeProfileId),
          substance: substance,
          category: Value(category),
          reaction: Value(reaction),
          severity: Value(severity),
          notedDate: Value(notedDate),
          notes: Value(notes),
          createdAt: DateTime.now(),
        ));
  }

  Future<List<Allergy>> getAllAllergies() {
    final q = _db.select(_db.allergies)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.get();
  }

  Future<bool> updateAllergy(Allergy a) =>
      _db.update(_db.allergies).replace(a);

  Future<void> deleteAllergy(int id) =>
      (_db.delete(_db.allergies)..where((t) => t.id.equals(id))).go();

  /// 查询全部报告（按日期倒序，最新在前）
  Future<List<MedicalReport>> getAllReports() {
    final q = _db.select(_db.medicalReports)
      ..where((t) => t.profileId.equals(_activeProfileId))
      ..orderBy([(t) => OrderingTerm.desc(t.reportDate)]);
    return q.get();
  }

  /// 按 id 查询一份报告
  Future<MedicalReport?> getReportById(int id) {
    final q = _db.select(_db.medicalReports)..where((t) => t.id.equals(id));
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
    await (_db.delete(_db.healthMetrics)
          ..where((t) => t.reportId.equals(reportId)))
        .go();
    await (_db.delete(_db.medicalReports)..where((t) => t.id.equals(reportId)))
        .go();
  }

  /// 更新一份报告的识别状态（pending / processing / review / confirmed / failed）
  Future<bool> setReportStatus(int reportId, String status) async {
    return await (_db.update(_db.medicalReports)
              ..where((t) => t.id.equals(reportId)))
            .write(MedicalReportsCompanion(
          recognitionStatus: Value(status),
        )) >
        0;
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

  /// 用户在结果页 / 详情页确认或修改检查日期（§21）。
  Future<void> updateReportDate(int reportId, DateTime date) =>
      (_db.update(_db.medicalReports)..where((t) => t.id.equals(reportId)))
          .write(MedicalReportsCompanion(reportDate: Value(date)));

  /// 用户在报告详情页修改医院 / 类型（F2）。传 null 的字段不动。
  Future<void> updateReportInfo(
    int reportId, {
    String? hospitalName,
    String? reportType,
  }) =>
      (_db.update(_db.medicalReports)..where((t) => t.id.equals(reportId)))
          .write(MedicalReportsCompanion(
        hospitalName:
            hospitalName == null ? const Value.absent() : Value(hospitalName),
        reportType:
            reportType == null ? const Value.absent() : Value(reportType),
      ));

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
    String? conditionCode,
    String? stage,
    String? diagnosisBasis,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.diseases).insert(DiseasesCompanion.insert(
          profileId: Value(profileId ?? _activeProfileId),
          name: name,
          foundDate: Value(foundDate),
          status: Value(status),
          notes: Value(notes),
          conditionCode: Value(conditionCode),
          stage: Value(stage),
          diagnosisBasis: Value(diagnosisBasis),
          createdAt: DateTime.now(),
        ));
  }

  Future<List<Disease>> getAllDiseases() {
    final q = _db.select(_db.diseases)
      ..where((t) => t.profileId.equals(_activeProfileId));
    return q.get();
  }

  /// 已纳入慢病字典的疾病史（condition_code 非空）。
  Future<List<Disease>> getChronicDiseases() {
    final q = _db.select(_db.diseases)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) & t.conditionCode.isNotNull());
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
    String? usage,
    String? timesPerDay,
    DateTime? startDate,
    DateTime? endDate,
    String status = '当前使用',
    String? notes,
    String? conditionCode,
  }) async {
    await ensureDefaultPersonProfile();
    return _db.into(_db.medications).insert(MedicationsCompanion.insert(
          profileId: Value(profileId ?? _activeProfileId),
          name: name,
          dosage: Value(dosage),
          dosageUnit: Value(dosageUnit),
          usage: Value(usage),
          timesPerDay: Value(timesPerDay),
          startDate: Value(startDate),
          endDate: Value(endDate),
          status: Value(status),
          notes: Value(notes),
          conditionCode: Value(conditionCode),
          createdAt: DateTime.now(),
        ));
  }

  Future<List<Medication>> getAllMedications() {
    final q = _db.select(_db.medications)
      ..where((t) => t.profileId.equals(_activeProfileId));
    return q.get();
  }

  // ---------- 慢病升级 步骤2：按慢病聚合关联数据 ----------

  /// 关联到某慢病的用药：显式关联 [Medication.conditionCode] == code。
  Future<List<Medication>> getMedicationsForCondition(String code) {
    final q = _db.select(_db.medications)
      ..where((t) =>
          t.profileId.equals(_activeProfileId) &
          t.conditionCode.equals(code));
    return q.get();
  }

  /// 关联到某慢病的报告：显式关联 [MedicalReport.conditionCode] == code，
  /// 或该报告里含有该慢病相关指标（自动匹配）。按日期倒序。
  Future<List<MedicalReport>> getReportsForCondition(
    String code,
    Iterable<String> relatedMetricIds,
  ) async {
    final reports = await getAllReports();
    if (reports.isEmpty) return const [];
    final metricSet = relatedMetricIds.toSet();
    Set<int> autoLinkedReportIds = {};
    if (metricSet.isNotEmpty) {
      final metrics = await (_db.select(_db.healthMetrics)
            ..where((t) =>
                t.profileId.equals(_activeProfileId) &
                t.reportId.isNotNull()))
          .get();
      autoLinkedReportIds = {
        for (final mtr in metrics)
          if (metricSet.contains(mtr.metricId) && mtr.reportId != null)
            mtr.reportId!,
      };
    }
    return [
      for (final r in reports)
        if (r.conditionCode == code || autoLinkedReportIds.contains(r.id)) r,
    ];
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
    String? conditionCode,
    String? followUpKey,
    bool autoGenerated = false,
    String sourceType = 'user',
    String? areaName,
    DateTime? recommendedDate,
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
            conditionCode: Value(conditionCode),
            followUpKey: Value(followUpKey),
            autoGenerated: Value(autoGenerated),
            sourceType: Value(sourceType),
            areaName: Value(areaName),
            recommendedDate: Value(recommendedDate),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // ---------- 03：报告 ↔ 身体部位关联 ----------

  /// 覆盖式设置一份报告的关联部位（先清后插）。areaName 用 13 大类之一。
  Future<void> setReportOrgans(
    int reportId,
    Iterable<String> areas, {
    int? profileId,
  }) async {
    await ensureDefaultPersonProfile();
    final pid = profileId ?? _activeProfileId;
    await _db.transaction(() async {
      await (_db.delete(_db.reportOrgans)
            ..where((t) => t.reportId.equals(reportId)))
          .go();
      final now = DateTime.now();
      for (final a in areas.map((e) => e.trim()).toSet()) {
        if (a.isEmpty) continue;
        await _db.into(_db.reportOrgans).insert(ReportOrgansCompanion.insert(
              profileId: Value(pid),
              reportId: reportId,
              areaName: a,
              createdAt: now,
            ));
      }
    });
  }

  /// 一份报告显式关联的部位。
  Future<List<String>> getReportOrgans(int reportId) async {
    final rows = await (_db.select(_db.reportOrgans)
          ..where((t) => t.reportId.equals(reportId)))
        .get();
    return [for (final r in rows) r.areaName];
  }

  /// 当前档案下「显式关联到某部位」的报告 id。
  Future<List<int>> reportIdsForArea(String areaName) async {
    final rows = await (_db.select(_db.reportOrgans)
          ..where((t) =>
              t.profileId.equals(_activeProfileId) &
              t.areaName.equals(areaName)))
        .get();
    return [for (final r in rows) r.reportId];
  }

  /// 当前档案全部报告的显式部位关联：reportId → [areaName…]。
  Future<Map<int, List<String>>> getAllReportOrganLinks() async {
    final rows = await (_db.select(_db.reportOrgans)
          ..where((t) => t.profileId.equals(_activeProfileId)))
        .get();
    final out = <int, List<String>>{};
    for (final r in rows) {
      out.putIfAbsent(r.reportId, () => []).add(r.areaName);
    }
    return out;
  }

  // ---------- 指标名归一化缓存（Round 3b·下）----------

  /// 归一化 key：与 metric_dictionary 的 _norm 等价（去空白 / 横杠 / 括号 / 斜杠
  /// + 转小写）。缓存查询用它，不做「去百分比 / 绝对值」这类语义裁剪。
  static String normalizeMatchKey(String s) {
    var out = s.trim().toLowerCase();
    for (final ch in const [
      ' ', '\t', '(', ')', '-', '－', '—', '＿', '_', '／', '/'
    ]) {
      out = out.replaceAll(ch, '');
    }
    return out;
  }

  /// 全部缓存：归一化 key → canonicalId（只返回指向核心词典的；custom* 暂不启用）。
  Future<Map<String, String>> loadMetricMatchCache() async {
    final rows = await _db.select(_db.metricMatchCache).get();
    final out = <String, String>{};
    for (final r in rows) {
      final id = r.canonicalId;
      if (id != null && id.isNotEmpty) out[r.rawKey] = id;
    }
    return out;
  }

  /// 写一条映射；同 rawKey 覆盖（后写的赢）。
  Future<void> upsertMetricMatch({
    required String rawDisplay,
    required String canonicalId,
    String source = 'deepseek',
    double? confidence,
    int? originReportId,
  }) async {
    final key = normalizeMatchKey(rawDisplay);
    if (key.isEmpty || canonicalId.isEmpty) return;
    await _db.into(_db.metricMatchCache).insert(
          MetricMatchCacheCompanion.insert(
            rawKey: key,
            rawDisplay: rawDisplay.trim(),
            canonicalId: Value(canonicalId),
            source: Value(source),
            confidence: Value(confidence),
            originReportId: Value(originReportId),
            createdAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<List<MetricMatchCacheData>> getAllMetricMatches() =>
      _db.select(_db.metricMatchCache).get();

  Future<void> deleteMetricMatch(int id) =>
      (_db.delete(_db.metricMatchCache)..where((t) => t.id.equals(id))).go();

  /// 按当前词典 + 缓存把已入库的所有指标重新匹配一遍：能匹配上核心词典的
  /// 更新 metric_id / body_system；已经指向有效词典项且没变的不动；变回认不出
  /// 的（比如刚删了一条错误缓存）退回 UNKNOWN + 关键词粗归系统。返回改动条数。
  Future<int> rematchAllMetrics() async {
    final cache = await loadMetricMatchCache();
    final rows = await _db.select(_db.healthMetrics).get();
    var changed = 0;
    for (final r in rows) {
      final name = r.metricName;
      final byDict = matchMetricId(name);
      final byCache = cache[normalizeMatchKey(name)];
      final newId = byDict ??
          ((byCache != null && findMetricDefinition(byCache) != null)
              ? byCache
              : null);
      final String targetId = newId ?? 'UNKNOWN';
      final String targetSystem = newId != null
          ? bodySystemForMetric(newId)
          : guessSystemForRawName(name);
      if (targetId == r.metricId && targetSystem == r.bodySystem) continue;
      await (_db.update(_db.healthMetrics)..where((t) => t.id.equals(r.id)))
          .write(HealthMetricsCompanion(
        metricId: Value(targetId),
        bodySystem: Value(targetSystem),
      ));
      changed++;
    }
    return changed;
  }

  // ---------- 慢病升级 步骤4：随访计划自动排期 ----------

  /// 当前档案的随访提醒（kind='followup'），按到期日升序。
  Future<List<Reminder>> getFollowUpReminders({
    int? profileId,
    bool includeCompleted = true,
  }) {
    final pid = profileId ?? _activeProfileId;
    final q = _db.select(_db.reminders)
      ..where((t) => t.profileId.equals(pid) & t.kind.equals('followup'))
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    if (!includeCompleted) q.where((t) => t.completedAt.isNull());
    return q.get();
  }

  /// 对所有档案重算随访提醒（家庭模式）。幂等：新增缺的、更新到期日、撤掉不再成立的；
  /// 已「打勾」的项若新周期又到期则自动重新变回待办。
  Future<void> regenerateFollowUpsForAllProfiles({DateTime? now}) async {
    final ts = now ?? DateTime.now();
    final persons = await getAllPersonProfiles();
    for (final p in persons) {
      final diseases = await (_db.select(_db.diseases)
            ..where((t) =>
                t.profileId.equals(p.id) & t.conditionCode.isNotNull()))
          .get();
      final metrics = await (_db.select(_db.healthMetrics)
            ..where((t) => t.profileId.equals(p.id)))
          .get();
      final daily = await (_db.select(_db.dailyHealthRecords)
            ..where((t) => t.profileId.equals(p.id)))
          .get();
      final existing = await (_db.select(_db.reminders)
            ..where((t) =>
                t.profileId.equals(p.id) & t.kind.equals('followup')))
          .get();

      // 历史遗留去重：同一 key 有多条随访提醒（早期版本重复排期留下的，
      // 如「眼底检查」×2）——保留一条（优先有 completedAt 的、否则最早 id），
      // 其余删掉。否则首页 / 提醒页会重复显示。
      {
        final byKeyDedup = <String, Reminder>{};
        final dupIds = <int>[];
        for (final r in existing) {
          final key = '${r.conditionCode ?? ''}|${r.followUpKey ?? ''}';
          final kept = byKeyDedup[key];
          if (kept == null) {
            byKeyDedup[key] = r;
          } else {
            final keepR = (r.completedAt != null && kept.completedAt == null)
                ? r
                : (kept.id <= r.id ? kept : r);
            final dropR = identical(keepR, kept) ? r : kept;
            byKeyDedup[key] = keepR;
            dupIds.add(dropR.id);
          }
        }
        if (dupIds.isNotEmpty) {
          await (_db.delete(_db.reminders)..where((t) => t.id.isIn(dupIds)))
              .go();
          existing.removeWhere((r) => dupIds.contains(r.id));
        }
      }

      final lastCompleted = <String, DateTime>{};
      for (final r in existing) {
        final key = '${r.conditionCode ?? ''}|${r.followUpKey ?? ''}';
        if (r.completedAt != null) lastCompleted[key] = r.completedAt!;
      }

      final planned = planFollowUps(
        chronicDiseases: diseases,
        metrics: metrics,
        daily: daily,
        lastCompletedByKey: lastCompleted,
        now: ts,
      );
      final byKey = {
        for (final r in existing)
          '${r.conditionCode ?? ''}|${r.followUpKey ?? ''}': r,
      };
      final plannedKeys = planned.map((x) => x.dedupeKey).toSet();

      // 撤掉不再成立的（病删了 / 模板变了）。
      for (final r in existing) {
        final key = '${r.conditionCode ?? ''}|${r.followUpKey ?? ''}';
        if (!plannedKeys.contains(key)) {
          await (_db.delete(_db.reminders)..where((t) => t.id.equals(r.id)))
              .go();
        }
      }

      for (final x in planned) {
        final cur = byKey[x.dedupeKey];
        if (cur == null) {
          await _db.into(_db.reminders).insert(RemindersCompanion.insert(
                profileId: Value(p.id),
                kind: 'followup',
                title: x.title,
                detail: Value(x.detail),
                dueDate: Value(x.dueDate),
                conditionCode: Value(x.conditionCode),
                followUpKey: Value(x.itemKey),
                autoGenerated: const Value(true),
                createdAt: ts,
                updatedAt: ts,
              ));
          continue;
        }
        // 已打勾但新周期又到期（计划日期已到）→ 重新变回待办。
        final reopen = cur.completedAt != null &&
            !x.dueDate.isAfter(ts.add(const Duration(days: 7)));
        await (_db.update(_db.reminders)..where((t) => t.id.equals(cur.id)))
            .write(RemindersCompanion(
          title: Value(x.title),
          detail: Value(x.detail),
          dueDate: Value(x.dueDate),
          completedAt: reopen ? const Value(null) : const Value.absent(),
          updatedAt: Value(ts),
        ));
      }
    }
  }

  Future<void> setReminderEnabled(int id, bool enabled) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          enabled: Value(enabled),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markReminderCompleted(int id, {DateTime? at}) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          completedAt: Value(at ?? DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 把提醒到期日推后（首页「待跟进」里「推迟」用）。
  /// 注意：`followup` 类的到期日由 [regenerateFollowUpsForAllProfiles] 按模板重排，
  /// 推迟只对 `recheck` 类真正持久。
  Future<void> snoozeReminder(int id, DateTime newDue) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          dueDate: Value(newDue),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 撤销「已完成」——把复查提醒重新变回待办。
  Future<void> unmarkReminderCompleted(int id) =>
      (_db.update(_db.reminders)..where((t) => t.id.equals(id))).write(
        RemindersCompanion(
          completedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 自动清理：已完成满 [keepDays] 天的提醒自动删除（像 iOS 提醒事项那样，
  /// 打勾的过一阵就消失，不用手动删）。
  Future<void> purgeCompletedReminders({int keepDays = 20}) {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    return (_db.delete(_db.reminders)
          ..where((t) =>
              t.completedAt.isNotNull() &
              t.completedAt.isSmallerThanValue(cutoff) &
              // 随访提醒由 regenerateFollowUpsForAllProfiles 负责回滚，别在这里删，
              // 否则会丢掉「上次已复查时间」这个排期锚点。
              t.kind.equals('followup').not()))
        .go();
  }

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

  Future<void> deleteMedicationReminder(int medicationId) =>
      (_db.delete(_db.reminders)
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

  /// 只有「真正需要用户处理」的通知类别才计入首页红色 badge：
  /// 复查到期 / OCR 识别失败 / 待确认报告 / 上传失败。
  /// 日常服药提醒、资料归档、系统消息等按普通通知处理，不进红点
  /// （它们仍显示在通知中心列表里）。
  static const Set<String> actionableNotificationCategories = {
    'recheck',
    'followup',
    'ocr_failed',
    'report_confirm',
    'upload_failed',
  };

  Future<int> actionableUnreadCount() async {
    final rows = await (_db.select(_db.notifications)
          ..where((t) =>
              t.profileId.equals(_activeProfileId) &
              t.readAt.isNull() &
              t.deliveredAt.isNotNull()))
        .get();
    return rows
        .where((n) => actionableNotificationCategories.contains(n.category))
        .length;
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

  Future<void> markAllNotificationsRead() => (_db.update(_db.notifications)
        ..where(
            (t) => t.profileId.equals(_activeProfileId) & t.readAt.isNull()))
      .write(NotificationsCompanion(readAt: Value(DateTime.now())));

  Future<void> deleteNotification(int id) =>
      (_db.delete(_db.notifications)..where((t) => t.id.equals(id))).go();

  /// 清空当前档案的全部通知记录（用户主动「全部清除」）。
  Future<void> clearNotifications() => (_db.delete(_db.notifications)
        ..where((t) => t.profileId.equals(_activeProfileId)))
      .go();

  /// 自动清理：删掉计划时间早于 [keepDays] 天前的通知，避免越攒越多。
  /// 通知中心是「最近发生了什么」，不是永久归档。
  Future<void> purgeOldNotifications({int keepDays = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    return (_db.delete(_db.notifications)
          ..where((t) => t.scheduledFor.isSmallerThanValue(cutoff)))
        .go();
  }

  /// 幂等：把「当前档案未完成的提醒」落成 notifications 行——
  /// 复查提醒各 1 行（到期日 09:00），服药提醒补齐「今天」各时间点 1 行；
  /// 再把已过计划时间但未标记送达的行标记为已送达。返回本次新建条数。
  Future<int> syncNotificationsFromReminders({DateTime? now}) async {
    final ref = now ?? DateTime.now();
    final reminders = await getActiveReminders();

    // 服药提醒到点靠 iOS 系统本地通知（NotificationService.zonedSchedule），
    // 不再往 App 内「通知中心」记账——每天每时间点一条会把复查通知淹没，且
    // 到点提醒本身无可「处理」的内容。清掉历史遗留的服药通知行。
    await (_db.delete(_db.notifications)
          ..where((t) =>
              t.profileId.equals(_activeProfileId) &
              t.category.equals('medication')))
        .go();

    final existing = await getNotifications(limit: 1000);
    var inserted = 0;

    bool has(int reminderId, DateTime when) => existing.any((n) =>
        n.reminderId == reminderId && n.scheduledFor.isAtSameMomentAs(when));

    for (final r in reminders) {
      if (!r.enabled) continue;
      if ((r.kind == 'recheck' || r.kind == 'followup') &&
          r.dueDate != null &&
          r.completedAt == null) {
        final when =
            DateTime(r.dueDate!.year, r.dueDate!.month, r.dueDate!.day, 9);
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
    String? conditionCode,
    String? followUpKey,
    String sourceType = 'user',
    String? areaName,
    DateTime? recommendedDate,
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
            conditionCode: Value(conditionCode),
            followUpKey: Value(followUpKey),
            sourceType: Value(sourceType),
            areaName: Value(areaName),
            recommendedDate: Value(recommendedDate),
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
            'sourceId': m.sourceId,
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
            'conditionCode': r.conditionCode,
            'encounterId': r.encounterId,
            'examSummary': r.examSummary,
            'metricCount': metricCountByReport[r.id] ?? 0,
          },
      ],
      'encounters': [
        for (final e in await _db.select(_db.encounters).get())
          {
            'id': e.id,
            'profileId': e.profileId,
            'visitDate': iso(e.visitDate),
            'hospitalName': e.hospitalName,
            'department': e.department,
            'diagnosis': e.diagnosis,
            'advice': e.advice,
            'notes': e.notes,
            'conditionCode': e.conditionCode,
          },
      ],
      'allergies': [
        for (final a in await _db.select(_db.allergies).get())
          {
            'id': a.id,
            'profileId': a.profileId,
            'substance': a.substance,
            'category': a.category,
            'reaction': a.reaction,
            'severity': a.severity,
            'notedDate': iso(a.notedDate),
            'notes': a.notes,
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
            'conditionCode': d.conditionCode,
            'stage': d.stage,
            'diagnosisBasis': d.diagnosisBasis,
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
            'usage': m.usage,
            'timesPerDay': m.timesPerDay,
            'startDate': iso(m.startDate),
            'endDate': iso(m.endDate),
            'status': m.status,
            'notes': m.notes,
            'conditionCode': m.conditionCode,
          },
      ],
      'reminders': [
        for (final r in await _db.select(_db.reminders).get())
          // 自动生成的随访提醒是派生状态，恢复后会重新排期，不进备份。
          if (!(r.kind == 'followup' && r.autoGenerated))
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
              'conditionCode': r.conditionCode,
              'followUpKey': r.followUpKey,
              'sourceType': r.sourceType,
              'areaName': r.areaName,
              'recommendedDate': iso(r.recommendedDate),
            },
      ],
      'reportOrgans': [
        for (final r in await _db.select(_db.reportOrgans).get())
          {
            'id': r.id,
            'profileId': r.profileId,
            'reportId': r.reportId,
            'areaName': r.areaName,
          },
      ],
      'metricMatchCache': [
        for (final r in await _db.select(_db.metricMatchCache).get())
          {
            'rawKey': r.rawKey,
            'rawDisplay': r.rawDisplay,
            'canonicalId': r.canonicalId,
            'customName': r.customName,
            'customSystem': r.customSystem,
            'customUnit': r.customUnit,
            'source': r.source,
            'confidence': r.confidence,
            'originReportId': r.originReportId,
            'createdAt': iso(r.createdAt),
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
      await _db.delete(_db.reportOrgans).go();
      await _db.delete(_db.metricMatchCache).go();
      await _db.delete(_db.diseases).go();
      await _db.delete(_db.medications).go();
      await _db.delete(_db.reminders).go();
      await _db.delete(_db.encounters).go();
      await _db.delete(_db.allergies).go();
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
