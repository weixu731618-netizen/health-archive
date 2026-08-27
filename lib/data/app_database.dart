import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// 健康指标记录表（手工录入 或 报告导入的化验 / 检查指标）
class HealthMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  // T1：所有健康观测归属一个人员档案；旧数据迁移到默认“本人”(id=1)。
  IntColumn get profileId => integer().withDefault(const Constant(1))();
  TextColumn get metricId => text()();
  TextColumn get metricName => text()();
  RealColumn get value => real()();
  TextColumn get rawValue => text().nullable()();
  RealColumn get numericValue => real().nullable()();
  TextColumn get unit => text()();
  RealColumn get canonicalValue => real().nullable()();
  TextColumn get canonicalUnit => text().nullable()();
  RealColumn get referenceMin => real().nullable()();
  RealColumn get referenceMax => real().nullable()();
  TextColumn get referenceRangeRaw => text().nullable()();
  TextColumn get sourceAbnormalFlag => text().nullable()();
  TextColumn get status => text()();
  TextColumn get bodySystem => text()();
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get sourceType => text().withDefault(const Constant('manual'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // V0.4A：所属报告 id，可空。手工录入为 null；报告导入为对应 medical_reports.id。
  // 不声明数据库外键约束，保持生成与迁移最简单（应用层维护关联）。
  IntColumn get reportId => integer().nullable()();
  // V0.4D：原报告指标名 / 匹配类型 / 识别置信度（用于追踪与质量统计）
  TextColumn get rawName => text().nullable()();
  TextColumn get matchType => text().withDefault(const Constant('manual'))();
  RealColumn get recognitionConfidence => real().nullable()();
  TextColumn get verificationStatus =>
      text().withDefault(const Constant('user_confirmed'))();
  IntColumn get sourcePage => integer().nullable()();
  TextColumn get sourceBoundingBox => text().nullable()();
}

/// 日常健康记录表（体重 / 血压 / 血糖 / 心率）
class DailyHealthRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().withDefault(const Constant(1))();
  TextColumn get type =>
      text()(); // weight / blood_pressure / blood_glucose / heart_rate
  RealColumn get value1 => real()();
  RealColumn get value2 => real().nullable()();
  TextColumn get unit => text()();
  TextColumn get context => text().nullable()(); // 测量状态等附加信息
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// V0.4A：化验单报告表（保留原始报告信息，作为结构化指标的来源）
class MedicalReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().withDefault(const Constant(1))();
  TextColumn get hospitalName => text()();
  DateTimeColumn get reportDate => dateTime()();
  TextColumn get reportType => text()();
  TextColumn get sourceImagePath => text().nullable()(); // 原始图片路径（可空，Web 无落盘）
  TextColumn get rawText => text().nullable()(); // 原始识别文本（全文，不进日志）
  // V0.4B：识别流程状态（pending / processing / review / confirmed / failed）
  TextColumn get recognitionStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
}

/// MVP：疾病史表
class Diseases extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  DateTimeColumn get foundDate => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('不确定'))(); // 当前存在/已恢复/不确定
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// MVP：用药记录表
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get dosage => text().nullable()(); // 剂量（保留原文，如 5）
  TextColumn get dosageUnit => text().nullable()(); // 单位，如 mg
  TextColumn get timesPerDay => text().nullable()(); // 每日次数（如 2）
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('当前使用'))(); // 当前使用/已停用
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// MVP：个人资料（单行，id 恒为 1）
class UserProfile extends Table {
  IntColumn get id => integer()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  TextColumn get gender => text().withDefault(const Constant(''))(); // 男/女/其他
  DateTimeColumn get birthDate => dateTime().nullable()();
  RealColumn get heightCm => real().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

/// T1：人员档案。当前只自动维护默认“本人”，为后续家庭成员隔离预留。
class PersonProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withDefault(const Constant('本人'))();
  TextColumn get relationship => text().withDefault(const Constant('self'))();
  TextColumn get sex => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// App 本地数据库主入口（跨端：Android / iOS / Web）
@DriftDatabase(tables: [
  HealthMetrics,
  DailyHealthRecords,
  MedicalReports,
  Diseases,
  Medications,
  UserProfile,
  PersonProfiles,
])
class AppDatabase extends _$AppDatabase {
  /// 生产环境下使用 drift_flutter 提供的跨端数据库：
  /// - 原生平台（Android/iOS）使用本地 SQLite 文件，无需额外配置；
  /// - Web 平台需要 sqlite3.wasm 与 drift_worker.js（放置在 web/ 目录下）。
  /// 测试时可传入自定义 executor（如内存数据库）。
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'health_archive_db',
                // Web 平台需要两个文件（放在 web/ 目录）；原生平台忽略此配置。
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  /// V0.4A：1→2（medical_reports、health_metrics.reportId）；V0.4B：2→3（recognitionStatus）；
  /// V0.4D：3→4（health_metrics 增加 rawName/matchType/recognitionConfidence）；
  /// MVP：4→5（新增 diseases/medications/user_profile）。
  /// T1：5→6（person_profiles、profileId 与可信观测字段）。
  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // 从 V0.3（schemaVersion=1）升级到 V0.4（=2）
          if (from < 2) {
            await m.createTable(medicalReports);
            await m.addColumn(healthMetrics, healthMetrics.reportId);
          }
          // V0.4B：medical_reports 增加识别状态字段
          if (from < 3) {
            await m.addColumn(medicalReports, medicalReports.recognitionStatus);
          }
          // V0.4D：health_metrics 增加匹配追踪字段
          if (from < 4) {
            await m.addColumn(healthMetrics, healthMetrics.rawName);
            await m.addColumn(healthMetrics, healthMetrics.matchType);
            await m.addColumn(
                healthMetrics, healthMetrics.recognitionConfidence);
          }
          // MVP：新增疾病史 / 用药 / 个人资料表
          if (from < 5) {
            await m.createTable(diseases);
            await m.createTable(medications);
            await m.createTable(userProfile);
          }
          if (from < 6) {
            await m.createTable(personProfiles);
            await m.addColumn(healthMetrics, healthMetrics.profileId);
            await m.addColumn(healthMetrics, healthMetrics.rawValue);
            await m.addColumn(healthMetrics, healthMetrics.numericValue);
            await m.addColumn(healthMetrics, healthMetrics.canonicalValue);
            await m.addColumn(healthMetrics, healthMetrics.canonicalUnit);
            await m.addColumn(healthMetrics, healthMetrics.referenceRangeRaw);
            await m.addColumn(healthMetrics, healthMetrics.sourceAbnormalFlag);
            await m.addColumn(healthMetrics, healthMetrics.verificationStatus);
            await m.addColumn(healthMetrics, healthMetrics.sourcePage);
            await m.addColumn(healthMetrics, healthMetrics.sourceBoundingBox);
            await m.addColumn(dailyHealthRecords, dailyHealthRecords.profileId);
            await m.addColumn(medicalReports, medicalReports.profileId);
            await m.addColumn(diseases, diseases.profileId);
            await m.addColumn(medications, medications.profileId);
            await customStatement(
              "INSERT OR IGNORE INTO person_profiles "
              "(id, display_name, relationship, created_at, updated_at) "
              "VALUES (1, '本人', 'self', "
              "CAST(strftime('%s', 'now') AS INTEGER) * 1000, "
              "CAST(strftime('%s', 'now') AS INTEGER) * 1000)",
            );
          }
        },
      );
}
