// V0.5.1：本地完整备份（zip 打包 + 分享面板）的往返测试。
// 验证 exportBundle -> restoreFromFile 后，数据库记录与报告原图都能正确恢复，
// 且 metrics.reportId 能正确重新映射到恢复后的新报告 id。
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/main.dart';
import 'package:health_archive/services/local_backup_service.dart';
import 'package:health_archive/utils/report_image_save.dart';

/// 伪造应用文档目录：测试环境没有平台通道，用系统临时目录代替。
class _FakePathProviderPlatform extends PathProviderPlatform {
  final Directory dir;
  _FakePathProviderPlatform(this.dir);

  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

void main() {
  late AppDatabase db;
  late HealthRepository repo;
  late Directory tempDocs;
  final backup = LocalBackupService();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tempDocs = Directory.systemTemp.createTempSync('health_archive_test_docs_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDocs);

    db = AppDatabase(NativeDatabase.memory());
    repo = HealthRepository(db);
    appDatabase = db;
    appRepository = repo;
  });

  tearDown(() async {
    appRepository = null;
    appDatabase = null;
    await db.close();
    try {
      tempDocs.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('导出为 zip 再恢复，数据库记录与报告原图能正确往返', () async {
    // 准备一张假的报告原图
    final imageBytes = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final savedImagePath = await saveReportImageLocally(imageBytes, '.jpg');

    await repo.upsertProfile(
      nickname: '小明',
      gender: '男',
      birthDate: DateTime(1990, 1, 1),
      heightCm: 175,
    );

    final reportId = await repo.insertReport(
      hospitalName: '市第一医院',
      reportDate: DateTime(2026, 8, 1),
      reportType: '血常规',
      sourceImagePath: savedImagePath,
      rawText: '血常规各项均在参考范围内',
      recognitionStatus: 'confirmed',
    );

    await repo.insertMetric(
      metricId: 'HBA1C',
      metricName: '糖化血红蛋白',
      value: 6.8,
      unit: '%',
      referenceMin: 4.0,
      referenceMax: 6.0,
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 8, 1),
      reportId: reportId,
    );

    await repo.insertDaily(
      type: '血压',
      value1: 120,
      value2: 80,
      unit: 'mmHg',
      measuredAt: DateTime(2026, 8, 2),
    );

    await repo.insertDisease(name: '高血压', status: '确诊');
    await repo.insertMedication(name: '二甲双胍', dosage: '0.5', dosageUnit: 'g');

    // 导出打包
    final zipPath = await backup.exportBundle();
    expect(File(zipPath).existsSync(), isTrue);

    // 恢复前先记录旧图片路径，恢复后旧文件不会被删除（新文件是另一份拷贝）
    expect(File(savedImagePath).existsSync(), isTrue);

    // 从 zip 恢复（内部会先 clearAllHealthData 再重建）
    final msg = await backup.restoreFromFile(zipPath);
    expect(msg, '恢复成功');

    // 校验 profile
    final profile = await repo.getProfile();
    expect(profile, isNotNull);
    expect(profile!.nickname, '小明');
    expect(profile.gender, '男');
    expect(profile.heightCm, 175);

    // 校验 report + 图片
    final reports = await repo.getAllReports();
    expect(reports.length, 1);
    final restoredReport = reports.single;
    expect(restoredReport.hospitalName, '市第一医院');
    expect(restoredReport.sourceImagePath, isNotNull);
    expect(restoredReport.sourceImagePath, isNot(savedImagePath));
    expect(restoredReport.rawText, '血常规各项均在参考范围内');
    final restoredImageFile = File(restoredReport.sourceImagePath!);
    expect(restoredImageFile.existsSync(), isTrue);
    expect(await restoredImageFile.readAsBytes(), imageBytes);

    // 校验 metric 与新 reportId 的映射
    final metrics = await repo.getAllMetrics();
    expect(metrics.length, 1);
    expect(metrics.single.metricId, 'HBA1C');
    expect(metrics.single.reportId, restoredReport.id);

    // 校验日常记录 / 疾病 / 用药
    final dailies = await repo.getAllDailyRecords();
    expect(dailies.length, 1);
    expect(dailies.single.value1, 120);

    final diseases = await repo.getAllDiseases();
    expect(diseases.length, 1);
    expect(diseases.single.name, '高血压');

    final medications = await repo.getAllMedications();
    expect(medications.length, 1);
    expect(medications.single.name, '二甲双胍');
  });

  test('多人家庭档案：本人 + 家庭成员及各自数据完整往返', () async {
    await repo.ensureDefaultPersonProfile();
    await repo.upsertProfile(nickname: '徐先生', gender: '男', heightCm: 172);
    await repo.insertMetric(
      metricId: 'SELF_UA',
      metricName: '尿酸',
      value: 480,
      unit: 'μmol/L',
      referenceMin: 210,
      referenceMax: 420,
      status: '偏高',
      bodySystem: '肾脏',
      measuredAt: DateTime(2026, 7, 1),
    );

    final momId = await repo.insertPersonProfile(
        displayName: '妈妈', relationship: '母亲', sex: '女');
    await repo.setActiveProfileId(momId);
    await repo.insertMetric(
      metricId: 'MOM_GLU',
      metricName: '空腹血糖',
      value: 7.2,
      unit: 'mmol/L',
      referenceMin: 3.9,
      referenceMax: 6.1,
      status: '偏高',
      bodySystem: '血糖代谢',
      measuredAt: DateTime(2026, 7, 2),
    );
    await repo.insertMedication(name: '格列美脲');

    final zipPath = await backup.exportBundle();
    // 恢复前切回本人，验证恢复能重建「当前档案之外」的成员数据
    await repo.setActiveProfileId(HealthRepository.defaultProfileId);
    final msg = await backup.restoreFromFile(zipPath);
    expect(msg, '恢复成功');

    final people = await repo.getAllPersonProfiles();
    expect(people.map((p) => p.displayName), containsAll(['徐先生', '妈妈']));
    final mom = people.firstWhere((p) => p.displayName == '妈妈');
    expect(mom.relationship, '母亲');

    // 本人只看到本人的指标
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['SELF_UA']);
    // 切到妈妈能看到她的指标和用药
    await repo.setActiveProfileId(mom.id);
    expect((await repo.getAllMetrics()).map((m) => m.metricId), ['MOM_GLU']);
    expect((await repo.getAllMedications()).single.name, '格列美脲');
  });

  test('影像/病理报告（无指标、无原图，仅结论文字）也能完整往返', () async {
    await repo.insertReport(
      hospitalName: '市中心医院',
      reportDate: DateTime(2026, 8, 5),
      reportType: 'CT',
      rawText: '双肺纹理清晰，未见明显异常密度影；纵隔居中。',
      recognitionStatus: 'confirmed',
    );

    final zipPath = await backup.exportBundle();
    final msg = await backup.restoreFromFile(zipPath);
    expect(msg, '恢复成功');

    final reports = await repo.getAllReports();
    expect(reports, hasLength(1));
    expect(reports.single.reportType, 'CT');
    expect(reports.single.rawText, '双肺纹理清晰，未见明显异常密度影；纵隔居中。');
    expect(reports.single.sourceImagePath, isNull);
    expect(await repo.getMetricsByReport(reports.single.id), isEmpty);
  });

  test('加密备份：正确密码能恢复，缺少或错误密码会失败', () async {
    await repo.insertDisease(name: '高血压', status: '确诊');

    final zipPath = await backup.exportBundle(password: 'secret123');
    expect(File(zipPath).existsSync(), isTrue);

    // 不给密码：无法解密内容
    await expectLater(
      backup.restoreFromFile(zipPath),
      throwsA(anything),
    );

    // 密码错误：同样无法解密
    await expectLater(
      backup.restoreFromFile(zipPath, password: 'wrong-password'),
      throwsA(anything),
    );

    // 正确密码：能正常恢复
    final msg = await backup.restoreFromFile(zipPath, password: 'secret123');
    expect(msg, '恢复成功');
    final diseases = await repo.getAllDiseases();
    expect(diseases.length, 1);
    expect(diseases.single.name, '高血压');
  });

  test('未加密的旧备份文件：不传密码也能正常恢复（向后兼容）', () async {
    await repo.insertDisease(name: '高血压', status: '确诊');

    final zipPath = await backup.exportBundle(); // 不设密码
    final msg = await backup.restoreFromFile(zipPath); // 不传密码
    expect(msg, '恢复成功');
  });

  test('取消核对清理：只删除 App 管理的单张报告原图', () async {
    final imageBytes = Uint8List.fromList(List<int>.generate(32, (i) => 255 - i));
    final savedImagePath = await saveReportImageLocally(imageBytes, '.jpg');
    final imageFile = File(savedImagePath);
    expect(imageFile.existsSync(), isTrue);

    await deleteManagedReportImage(savedImagePath);
    expect(imageFile.existsSync(), isFalse);

    final external = File('${tempDocs.path}${Platform.pathSeparator}external.jpg');
    await external.writeAsBytes(imageBytes);
    expect(external.existsSync(), isTrue);

    await deleteManagedReportImage(external.path);
    expect(external.existsSync(), isTrue);
  });

  test('exportBundle 成功后记录 lastBackupAt（首页据此判断是否提醒备份）', () async {
    expect(await backup.getLastBackupAt(), isNull);

    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await repo.insertDisease(name: '高血压', status: '确诊');
    await backup.exportBundle();

    final at = await backup.getLastBackupAt();
    expect(at, isNotNull);
    expect(at!.isAfter(before), isTrue);
  });
}
