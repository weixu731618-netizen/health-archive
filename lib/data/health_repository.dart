import 'package:drift/drift.dart';

import 'app_database.dart';

/// 数据访问层：封装对本地数据库的读写。
/// 页面通过这个类操作数据，不直接接触 SQL。
class HealthRepository {
  final AppDatabase _db;

  HealthRepository(this._db);

  // ---------- 手工录入的检查指标 ----------

  /// 新增一条检查指标记录。
  /// 注：为兼容较旧版本的 SQLite（宿主机测试环境），不使用 insertReturning，
  /// 而是先插入再用返回的自增 id 读取回完整记录。
  Future<HealthMetric> insertMetric({
    required String metricId,
    required String metricName,
    required double value,
    required String unit,
    required double? referenceMin,
    required double? referenceMax,
    required String status,
    required String bodySystem,
    required DateTime measuredAt,
    String sourceType = 'manual',
    String? notes,
    int? reportId, // V0.4A：所属报告 id，手工录入为 null
    String? rawName, // V0.4D：原报告指标名
    String matchType = 'manual', // V0.4D：exact/alias/ai_suggested/unmatched/manual
    double? recognitionConfidence, // V0.4D：识别置信度
  }) async {
    final now = DateTime.now();
    final newId = await _db.into(_db.healthMetrics).insert(
          HealthMetricsCompanion.insert(
            metricId: metricId,
            metricName: metricName,
            value: value,
            unit: unit,
            referenceMin: Value(referenceMin),
            referenceMax: Value(referenceMax),
            status: status,
            bodySystem: bodySystem,
            measuredAt: measuredAt,
            sourceType: Value(sourceType),
            notes: Value(notes),
            reportId: Value(reportId),
            rawName: Value(rawName),
            matchType: Value(matchType),
            recognitionConfidence: Value(recognitionConfidence),
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
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 查询某个身体系统的检查指标记录（最新在前）
  Future<List<HealthMetric>> getMetricsByBodySystem(String bodySystem) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) => t.bodySystem.equals(bodySystem))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  /// 查询某指标 id 的所有历史记录（最新在前）
  Future<List<HealthMetric>> getMetricHistory(String metricId) {
    final q = _db.select(_db.healthMetrics)
      ..where((t) => t.metricId.equals(metricId))
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  // ---------- 日常健康记录 ----------

  /// 新增一条日常记录。
  /// 注：为兼容较旧版本的 SQLite（宿主机测试环境），不使用 insertReturning。
  Future<DailyHealthRecord> insertDaily({
    required String type,
    required double value1,
    double? value2,
    required String unit,
    String? context,
    required DateTime measuredAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newId = await _db.into(_db.dailyHealthRecords).insert(
          DailyHealthRecordsCompanion.insert(
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
      ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)]);
    return q.get();
  }

  // ---------- 化验单报告（V0.4A） ----------

  /// 新增一份报告，返回其 id。
  Future<int> insertReport({
    required String hospitalName,
    required DateTime reportDate,
    required String reportType,
    String? sourceImagePath,
    String? rawText,
    String recognitionStatus = 'review', // V0.4B：识别后进入确认阶段；确认保存后置 confirmed
  }) {
    return _db.into(_db.medicalReports).insert(
          MedicalReportsCompanion.insert(
            hospitalName: hospitalName,
            reportDate: reportDate,
            reportType: reportType,
            sourceImagePath: Value(sourceImagePath),
            rawText: Value(rawText),
            recognitionStatus: Value(recognitionStatus),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// 查询全部报告（按日期倒序，最新在前）
  Future<List<MedicalReport>> getAllReports() {
    final q = _db.select(_db.medicalReports)
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
      ..where((t) => t.reportId.equals(reportId))
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

  // ---------- 疾病史（MVP） ----------

  Future<int> insertDisease({
    required String name,
    DateTime? foundDate,
    String status = '不确定',
    String? notes,
  }) {
    return _db.into(_db.diseases).insert(DiseasesCompanion.insert(
      name: name,
      foundDate: Value(foundDate),
      status: Value(status),
      notes: Value(notes),
      createdAt: DateTime.now(),
    ));
  }

  Future<List<Disease>> getAllDiseases() {
    return _db.select(_db.diseases).get();
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
    required String name,
    String? dosage,
    String? dosageUnit,
    String? timesPerDay,
    DateTime? startDate,
    DateTime? endDate,
    String status = '当前使用',
    String? notes,
  }) {
    return _db.into(_db.medications).insert(MedicationsCompanion.insert(
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
    return _db.select(_db.medications).get();
  }

  Future<int> deleteMedication(int id) {
    return (_db.delete(_db.medications)..where((t) => t.id.equals(id))).go();
  }

  Future<bool> updateMedication(Medication m) async {
    return _db.update(_db.medications).replace(m);
  }

  // ---------- 个人资料（MVP，单行 id=1） ----------

  Future<UserProfileData?> getProfile() {
    return (_db.select(_db.userProfile)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
  }

  Future<void> upsertProfile({
    String nickname = '',
    String gender = '',
    DateTime? birthDate,
    double? heightCm,
  }) async {
    final now = DateTime.now();
    final found = await getProfile();
    if (found == null) {
      await _db.into(_db.userProfile).insert(UserProfileCompanion.insert(
        id: 1,
        nickname: Value(nickname),
        gender: Value(gender),
        birthDate: Value(birthDate),
        heightCm: Value(heightCm),
        updatedAt: Value(now),
      ));
    } else {
      await (_db.update(_db.userProfile)..where((t) => t.id.equals(1)))
          .write(UserProfileCompanion(
        nickname: Value(nickname),
        gender: Value(gender),
        birthDate: Value(birthDate),
        heightCm: Value(heightCm),
        updatedAt: Value(now),
      ));
    }
  }

  // ---------- MVP：导出 / 删除 ----------

  /// 汇总全部健康数据为可 JSON 序列化的 map（不包含原始图片内容）。
  Future<Map<String, dynamic>> exportHealthData() async {
    String? iso(DateTime? d) => d?.toIso8601String();
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': (await getProfile()) == null
          ? null
          : {
              'nickname': (await getProfile())!.nickname,
              'gender': (await getProfile())!.gender,
              'birthDate': iso((await getProfile())!.birthDate),
              'heightCm': (await getProfile())!.heightCm,
            },
      'metrics': [
        for (final m in await getAllMetrics())
          {
            'id': m.id,
            'metricId': m.metricId,
            'metricName': m.metricName,
            'rawName': m.rawName,
            'matchType': m.matchType,
            'value': m.value,
            'unit': m.unit,
            'referenceMin': m.referenceMin,
            'referenceMax': m.referenceMax,
            'status': m.status,
            'bodySystem': m.bodySystem,
            'measuredAt': iso(m.measuredAt),
            'sourceType': m.sourceType,
            'notes': m.notes,
            'reportId': m.reportId,
          },
      ],
      'dailyRecords': [
        for (final d in await getAllDailyRecords())
          {
            'id': d.id,
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
        for (final r in await getAllReports())
          {
            'id': r.id,
            'hospitalName': r.hospitalName,
            'reportDate': iso(r.reportDate),
            'reportType': r.reportType,
            'sourceImagePath': r.sourceImagePath,
            'recognitionStatus': r.recognitionStatus,
            'metricCount': (await getMetricsByReport(r.id)).length,
          },
      ],
      'diseases': [
        for (final d in await getAllDiseases())
          {
            'id': d.id,
            'name': d.name,
            'foundDate': iso(d.foundDate),
            'status': d.status,
            'notes': d.notes,
          },
      ],
      'medications': [
        for (final m in await getAllMedications())
          {
            'id': m.id,
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
      await _db.delete(_db.userProfile).go();
    });
  }
}
