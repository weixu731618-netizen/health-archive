// 数据库迁移回归测试：覆盖 schemaVersion 5 -> 6 的真实升级路径。
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';

void main() {
  test('schema 5 升级到 6 后默认本人档案可正常读取', () async {
    final dir =
        Directory.systemTemp.createTempSync('health_archive_migration_');
    final file = File('${dir.path}${Platform.pathSeparator}v5.db');
    try {
      _createVersion5Database(file);

      final db = AppDatabase(NativeDatabase(file));
      final repo = HealthRepository(db);
      addTearDown(db.close);

      final profile = await repo.ensureDefaultPersonProfile();
      expect(profile.id, HealthRepository.defaultProfileId);
      expect(profile.displayName, '本人');
      expect(profile.createdAt, isA<DateTime>());
      expect(profile.updatedAt, isA<DateTime>());
    } finally {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  test('schema 5 升级到 6：已有的真实数据不会丢失，且自动归属默认档案', () async {
    final dir = Directory.systemTemp
        .createTempSync('health_archive_migration_data_');
    final file = File('${dir.path}${Platform.pathSeparator}v5_with_data.db');
    try {
      _createVersion5Database(file, withSampleData: true);

      final db = AppDatabase(NativeDatabase(file));
      final repo = HealthRepository(db);
      addTearDown(db.close);

      // 升级前 v5 库里已有一条指标、一份报告、一条日常记录、一条疾病史、
      // 一条用药记录：迁移只应新增列/新增表，不应删除或清空已有行。
      final metrics = await db.select(db.healthMetrics).get();
      expect(metrics, hasLength(1));
      expect(metrics.single.metricName, '糖化血红蛋白');
      expect(metrics.single.value, 6.8);
      // 新增的 profileId 列在旧数据上没有显式写过值，应落到列声明的默认值 1，
      // 而不是丢数据或变成迁移前不存在的 NULL。
      expect(metrics.single.profileId, HealthRepository.defaultProfileId);

      final reports = await db.select(db.medicalReports).get();
      expect(reports, hasLength(1));
      expect(reports.single.hospitalName, '深圳测试医院');
      expect(reports.single.profileId, HealthRepository.defaultProfileId);

      final daily = await db.select(db.dailyHealthRecords).get();
      expect(daily, hasLength(1));
      expect(daily.single.profileId, HealthRepository.defaultProfileId);

      final diseases = await db.select(db.diseases).get();
      expect(diseases, hasLength(1));
      expect(diseases.single.name, '高血压');
      expect(diseases.single.profileId, HealthRepository.defaultProfileId);

      final medications = await db.select(db.medications).get();
      expect(medications, hasLength(1));
      expect(medications.single.name, '氨氯地平');
      expect(medications.single.profileId, HealthRepository.defaultProfileId);

      // 迁移后默认档案应存在且能通过普通读接口查到刚才这些数据。
      final metricsByRepo = await repo.getMetricsByReport(reports.single.id);
      expect(metricsByRepo, isEmpty); // 该指标未关联报告，这里只验证查询本身不报错

      // B1（6→7 / 5→7）：user_profile 里的本人资料应并入 person_profiles 档案 1。
      final self = await repo.getPersonProfile(HealthRepository.defaultProfileId);
      expect(self, isNotNull);
      expect(self!.displayName, '徐先生');
      expect(self.sex, '男');
      expect(self.heightCm, 172);
      final view = await repo.getActiveProfileView();
      expect(view!.nickname, '徐先生');
      expect(view.heightCm, 172);
    } finally {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });
}

void _createVersion5Database(File file, {bool withSampleData = false}) {
  final db = sqlite3.sqlite3.open(file.path);
  try {
    db.execute('''
      CREATE TABLE health_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        metric_id TEXT NOT NULL,
        metric_name TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        reference_min REAL,
        reference_max REAL,
        status TEXT NOT NULL,
        body_system TEXT NOT NULL,
        measured_at INTEGER NOT NULL,
        source_type TEXT NOT NULL DEFAULT 'manual',
        notes TEXT,
        created_at INTEGER NOT NULL,
        report_id INTEGER,
        raw_name TEXT,
        match_type TEXT NOT NULL DEFAULT 'manual',
        recognition_confidence REAL
      );

      CREATE TABLE daily_health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        type TEXT NOT NULL,
        value1 REAL NOT NULL,
        value2 REAL,
        unit TEXT NOT NULL,
        context TEXT,
        measured_at INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL
      );

      CREATE TABLE medical_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        hospital_name TEXT NOT NULL,
        report_date INTEGER NOT NULL,
        report_type TEXT NOT NULL,
        source_image_path TEXT,
        raw_text TEXT,
        recognition_status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL
      );

      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        found_date INTEGER,
        status TEXT NOT NULL DEFAULT '不确定',
        notes TEXT,
        created_at INTEGER NOT NULL
      );

      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        dosage_unit TEXT,
        times_per_day TEXT,
        start_date INTEGER,
        end_date INTEGER,
        status TEXT NOT NULL DEFAULT '当前使用',
        notes TEXT,
        created_at INTEGER NOT NULL
      );

      CREATE TABLE user_profile (
        id INTEGER NOT NULL,
        nickname TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT '',
        birth_date INTEGER,
        height_cm REAL,
        updated_at INTEGER
      );

      PRAGMA user_version = 5;
    ''');

    if (withSampleData) {
      final now = DateTime.now().millisecondsSinceEpoch;
      db.execute('''
        INSERT INTO health_metrics
          (metric_id, metric_name, value, unit, status, body_system,
           measured_at, source_type, created_at)
        VALUES
          ('HBA1C', '糖化血红蛋白', 6.8, '%', '偏高', '血糖代谢', $now, 'manual', $now);

        INSERT INTO medical_reports
          (hospital_name, report_date, report_type, recognition_status, created_at)
        VALUES ('深圳测试医院', $now, '生化', 'confirmed', $now);

        INSERT INTO daily_health_records
          (type, value1, unit, measured_at, created_at)
        VALUES ('blood_pressure', 120, 'mmHg', $now, $now);

        INSERT INTO diseases (name, status, created_at)
        VALUES ('高血压', '进行中', $now);

        INSERT INTO medications (name, status, created_at)
        VALUES ('氨氯地平', '当前使用', $now);

        INSERT INTO user_profile (id, nickname, gender, height_cm, updated_at)
        VALUES (1, '徐先生', '男', 172, $now);
      ''');
    }
  } finally {
    db.dispose();
  }
}
