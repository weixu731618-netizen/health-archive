// 全量编译校验：导入所有新增/改动的页面与数据层，验证无编译错误。

// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';

// 数据层
import 'package:health_archive/data/app_database.dart';
import 'package:health_archive/data/health_repository.dart';
import 'package:health_archive/models/body_area_health.dart';
import 'package:health_archive/models/app_metadata.dart';
import 'package:health_archive/models/metric_dictionary.dart';
import 'package:health_archive/models/metric_source.dart';
// 慢病升级 步骤1：病种字典
import 'package:health_archive/models/chronic_condition_dictionary.dart';
// 慢病升级 步骤3：控制目标
import 'package:health_archive/models/control_target.dart';
// 慢病升级 步骤4：随访模板 + 排期
import 'package:health_archive/models/followup_template.dart';
import 'package:health_archive/services/followup_scheduler.dart';
// 慢病升级 步骤5：过敏史
import 'package:health_archive/pages/allergy_page.dart';
import 'package:health_archive/pages/health_records_page.dart';
// 首页重做：报告驱动 + 检查驱动完成度
import 'package:health_archive/pages/home_page.dart';
import 'package:health_archive/models/checkup_coverage.dart';

// 页面
import 'package:health_archive/pages/manual_metric_entry_page.dart';
import 'package:health_archive/pages/daily_health_entry_page.dart';
import 'package:health_archive/pages/daily_history_page.dart';
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

// 影像/病理报告存档（图文，无数字指标）
import 'package:health_archive/pages/imaging_report_page.dart';

// A2：单份报告分享 / 导出原件
import 'package:health_archive/utils/report_export.dart';

// A3：PDF 报告导入
import 'package:health_archive/utils/pdf_support.dart';

// B1：多人家庭档案
import 'package:health_archive/pages/family_members_page.dart';
import 'package:health_archive/widgets/profile_switcher.dart';

// B2：备忘 / 提醒 + 本地通知 + 远程推送骨架
import 'package:health_archive/pages/reminders_page.dart';
import 'package:health_archive/pages/notification_center_page.dart';
import 'package:health_archive/services/notification_service.dart';
import 'package:health_archive/services/push_service.dart';
import 'package:health_archive/utils/reminder_schedule.dart';

// B3：记录页搜索 / 筛选 / 标签
import 'package:health_archive/utils/records_filter.dart';

// B4：首页/我的重构 + 给医生看的一页纸
import 'package:health_archive/pages/medical_summary_page.dart';
import 'package:health_archive/utils/medical_summary.dart';

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
    expect(DailyHistoryPage, isA<Type>());
    expect(DailyEntryType.values.length, 5); // 慢病升级 步骤6：+腰围
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
    // 慢病升级 步骤1：病种字典
    expect(CHRONIC_CONDITION_DICTIONARY, isNotEmpty);
    expect(findChronicCondition('hypertension')?.name, '高血压');
    expect(matchChronicCondition('T2DM')?.code, 'type2_diabetes');
    expect(chronicConditionsByCategory(ChronicCategory.metabolic), isNotEmpty);
    expect(metricsForCondition('type2_diabetes'), isNotEmpty);
    expect(chronicCategoryLabel(ChronicCategory.other), isA<String>());
    // 慢病升级 步骤3：控制目标
    expect(CONTROL_TARGET_DICTIONARY, isNotEmpty);
    expect(resolveControlTargets({'dyslipidemia', 'chd'})['LDLC']?.max, 1.8);
    expect(
        evaluateTarget(
            resolveControlTargets({'gout'})['UA']!,
            value: 300),
        TargetStatus.met);
    expect(targetStatusLabel(TargetStatus.notMet), '未达标');
    // 慢病升级 步骤4：随访模板 + 排期
    expect(FOLLOWUP_TEMPLATES, isNotEmpty);
    expect(followUpTemplateFor('type2_diabetes')?.items, isNotEmpty);
    expect(planFollowUps, isA<Function>());
    expect(PlannedFollowUp, isA<Type>());
    // 慢病升级 步骤5：过敏史 + 健康资料入口
    expect(AllergyPage, isA<Type>());
    expect(HealthRecordsPage, isA<Type>());
    // 首页重做
    expect(HomePage, isA<Type>());
    expect(CHECKUP_ASPECTS, isNotEmpty);
    expect(buildCheckupCoverage, isA<Function>());
    expect(bodyAreaForSystem('血糖代谢'), '内分泌/代谢');
    expect(bodyAreaForSystem('电解质'), '肾脏/泌尿'); // 指标分类下沉到器官/系统
    expect(bodyAreaForSystem('未知系统XYZ'), '其他'); // 未知一律归其他，不再自成一级
    expect(AppMetadata.versionName, '1.9.5');
    expect(AppMetadata.versionCode, 34);
    // V0.4C-1：OCR 服务与调试页
    expect(ReportOcrService, isA<Type>());
    expect(RemoteOcrService, isA<Type>());
    expect(OcrLine, isA<Type>());
    expect(OcrDebugPage, isA<Type>());
    // 影像/病理报告存档
    expect(ImagingReportPage, isA<Type>());
    expect(imagingReportTypes.contains('CT'), isTrue);
    // A2：报告分享 / 导出原件的内容组装
    expect(buildReportSharePayload, isA<Function>());
    expect(reportShareCaption, isA<Function>());
    // A3：PDF 报告导入
    expect(isPdfFileName('a.pdf'), isTrue);
    expect(renderPdfFirstPageToPng, isA<Function>());
    // B1：多人家庭档案
    expect(FamilyMembersPage, isA<Type>());
    expect(ProfileSwitcher, isA<Type>());
    expect(kMemberRelationships.contains('配偶'), isTrue);
    // B2：备忘 / 提醒
    expect(RemindersPage, isA<Type>());
    expect(NotificationCenterPage, isA<Type>());
    expect(NotificationService.instance, isNotNull);
    expect(PushService.pushEnabled, isFalse); // 默认不启用远程推送
    expect(defaultMedicationTimes(2), ['09:00', '21:00']);
    // B3：记录页搜索 / 筛选 / 标签
    expect(const RecordFilter().activeCount, 0);
    expect(const RecordFilter(tags: {'体检'}).isReportOnly, isTrue);
    // B4：给医生看的一页纸
    expect(MedicalSummaryPage, isA<Type>());
    expect(buildMedicalSummary, isA<Function>());
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
    // 第三阶段：来源体系（含未来预留项）
    expect(metricSourceKindFromWire('report_import'), MetricSourceKind.reportOcr);
    expect(metricSourceLabelFromWire('daily'), '日常记录');
    expect(metricSourceWire(MetricSourceKind.appleHealth), 'apple_health');
    expect(visibleRecordSourceFilters, isNotEmpty);
  });
}
