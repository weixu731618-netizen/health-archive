// 全量编译校验：导入所有新增/改动的页面与数据层，验证无编译错误。

// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';

// 数据层
import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/models/body_area_health.dart';
import 'package:health_archive/models/app_metadata.dart';
import 'package:health_archive/models/metric_dictionary.dart';

// 页面
import 'package:health_archive/pages/manual_metric_entry_page.dart';
import 'package:health_archive/pages/daily_health_entry_page.dart';
import 'package:health_archive/pages/metric_history_page.dart';
import 'package:health_archive/pages/body_page.dart';
import 'package:health_archive/pages/records_page.dart';
import 'package:health_archive/pages/add_page.dart';
import 'package:health_archive/pages/about_page.dart';
import 'package:health_archive/pages/report_import_page.dart';
import 'package:health_archive/pages/report_review_page.dart';
import 'package:health_archive/pages/report_detail_page.dart';

// 组件
import 'package:health_archive/widgets/metric_selector.dart';

// 工具
import 'package:health_archive/utils/format.dart';

// V0.4A：服务与模型
import 'package:health_archive/services/report_recognition_service.dart';
import 'package:health_archive/models/report_models.dart';

// V0.4C-1：OCR 服务与调试页
import 'package:health_archive/services/report_ocr_service.dart';
import 'package:health_archive/pages/ocr_debug_page.dart';

// MVP 收尾：疾病史/用药/个人资料/数据隐私
import 'package:health_archive/pages/condition_page.dart';
import 'package:health_archive/pages/medication_page.dart';
import 'package:health_archive/pages/profile_edit_page.dart';
import 'package:health_archive/pages/privacy_page.dart';
import 'package:health_archive/pages/cloud_backup_page.dart';
import 'package:health_archive/services/identity_service.dart';
import 'package:health_archive/services/cloud_backup_service.dart';

// V0.5.1：本地完整备份（免服务器）
import 'package:health_archive/services/local_backup_service.dart';
import 'package:health_archive/services/snapshot_importer.dart';

void main() {
  test('所有 V0.3/V0.4 新增代码符号可引用（编译校验）', () {
    expect(HealthRepository, isA<Type>());
    expect(AppDatabase, isA<Type>());
    expect(ManualMetricEntryPage, isA<Type>());
    expect(DailyHealthEntryPage, isA<Type>());
    expect(DailyEntryType.values.length, 4);
    expect(MetricHistoryPage, isA<Type>());
    expect(BodyPage, isA<Type>());
    expect(RecordsPage, isA<Type>());
    expect(MetricSelectorSheet, isA<Type>());
    expect(findMetricDefinition('HBA1C')?.metricName, '糖化血红蛋白');
    expect(formatDate(DateTime(2026, 8, 19)), '2026-08-19');
    // V0.4A：报告识别相关
    expect(ReportImportPage, isA<Type>());
    expect(ReportReviewPage, isA<Type>());
    expect(ReportDetailPage, isA<Type>());
    expect(MockReportRecognitionService, isA<Type>());
    expect(RemoteReportRecognitionService, isA<Type>());
    expect(StructuredMedicalReport, isA<Type>());
    expect(RecognizedMetric, isA<Type>());
    expect(matchMetricId('血清肌酐'), 'CREA');
    expect(matchMetricId('Cr'), 'CREA');
    expect(matchMetricId('糖化血红蛋白'), 'HBA1C');
    expect(bodySystemForMetric('HBA1C'), '血糖代谢');
    expect(bodyAreaForSystem('血糖代谢'), '代谢');
    expect(AppMetadata.versionName, '1.1.0');
    expect(AppMetadata.versionCode, 4);
    // V0.4C-1：OCR 服务与调试页
    expect(ReportOcrService, isA<Type>());
    expect(RemoteOcrService, isA<Type>());
    expect(OcrLine, isA<Type>());
    expect(OcrDebugPage, isA<Type>());
    // MVP 收尾：疾病史/用药/资料/隐私
    expect(ConditionPage, isA<Type>());
    expect(MedicationPage, isA<Type>());
    expect(ProfileEditPage, isA<Type>());
    expect(PrivacyPage, isA<Type>());
    expect(AboutPage, isA<Type>());
    expect(HealthRepository, isA<Type>());
    // V0.5：匿名身份 + 云端备份
    expect(CloudBackupPage, isA<Type>());
    expect(IdentityService, isA<Type>());
    expect(CloudBackupService, isA<Type>());
    // V0.5.1：本地完整备份（免服务器）
    expect(LocalBackupService, isA<Type>());
    expect(SnapshotImporter, isA<Type>());
  });
}
