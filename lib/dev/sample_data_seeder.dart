import '../data/health_repository.dart';
import '../models/metric_dictionary.dart';

/// 仅用于开发 / 演示：往本地库灌一套连贯的示例健康数据，方便逐个页面自查。
///
/// 不参与任何生产逻辑；唯一入口是 `PrivacyPage` 里 `kDebugMode` 保护的调试按钮，
/// release 构建里会被 tree-shaking 掉。
class SampleDataSeeder {
  const SampleDataSeeder._();

  /// 清空现有数据后写入示例数据。调用方负责先清理报告原图目录。
  static Future<void> run(HealthRepository repo) async {
    await repo.clearAllHealthData();

    final now = DateTime.now();
    DateTime daysAgo(int d) => DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: d));

    await repo.upsertProfile(
      nickname: '徐先生',
      gender: '男',
      birthDate: DateTime(1978, 5, 12),
      heightCm: 172,
    );

    // 演示：一个常见的「糖尿病 + 高血压」中年男性，数据量刻意克制。

    // —— 报告 1：生化全套（约 3 个月前）——
    final r1 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(95),
      reportType: '生化检查',
      recognitionStatus: 'confirmed',
      tags: const ['慢病随访'],
      rawText: '空腹血糖、糖化血红蛋白偏高；血脂轻度升高；肝肾功能正常。建议规律用药、控制饮食。',
    );
    await _addMetrics(repo, r1, daysAgo(95), {
      'FPG': 7.4, 'HBA1C': 7.4,
      'CREA': 84, 'EGFR': 98, 'UACR': 22,
      'TC': 5.4, 'TG': 1.9, 'LDLC': 3.3, 'HDLC': 1.1,
      'ALT': 28,
    });

    // —— 报告 2：糖尿病随访（约 6 周前）——
    final r2 = await repo.insertReport(
      hospitalName: '社区健康服务中心',
      reportDate: daysAgo(42),
      reportType: '糖尿病随访',
      recognitionStatus: 'confirmed',
      rawText: '糖化血红蛋白 7.1%，较前略降；空腹血糖 6.9 mmol/L。继续当前方案。',
    );
    await _addMetrics(repo, r2, daysAgo(42), {'HBA1C': 7.1, 'FPG': 6.9});

    // —— 报告 3：生化复查（约 2 周前，好转趋势）——
    final r3 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(14),
      reportType: '生化复查',
      recognitionStatus: 'confirmed',
      rawText: '糖化 6.8%、空腹血糖 6.6 mmol/L，较前下降；血脂达标。肝肾功能正常。',
    );
    await _addMetrics(repo, r3, daysAgo(14), {
      'FPG': 6.6, 'HBA1C': 6.8,
      'CREA': 86, 'EGFR': 96, 'UACR': 18,
      'TC': 4.8, 'TG': 1.5, 'LDLC': 2.4, 'HDLC': 1.2,
    });

    // —— 日常记录：体重（约每周一次，缓慢下降）——
    for (var w = 6; w >= 0; w--) {
      final v = 80.0 - (6 - w) * 0.4;
      await repo.insertDaily(
        type: 'weight',
        value1: double.parse(v.toStringAsFixed(1)),
        unit: 'kg',
        measuredAt: daysAgo(w * 7 + 1),
      );
    }
    // —— 日常记录：血压（逐步改善，最近达标）——
    const bp = [
      [146, 94], [142, 90], [138, 88], [136, 86], [134, 84], [132, 84],
    ];
    for (var i = 0; i < bp.length; i++) {
      await repo.insertDaily(
        type: 'blood_pressure',
        value1: bp[i][0].toDouble(),
        value2: bp[i][1].toDouble(),
        unit: 'mmHg',
        context: '晨起',
        measuredAt: daysAgo(i * 12 + 2),
      );
    }
    // —— 日常记录：空腹血糖 ——
    const glu = [7.3, 7.0, 6.8, 6.6, 6.5];
    for (var i = 0; i < glu.length; i++) {
      await repo.insertDaily(
        type: 'blood_glucose',
        value1: glu[i],
        unit: 'mmol/L',
        context: '空腹',
        measuredAt: daysAgo(i * 12 + 4),
      );
    }

    // —— 疾病史：只有两个慢病 ——
    await repo.insertDisease(
        name: '2型糖尿病',
        foundDate: daysAgo(700),
        status: '当前存在',
        conditionCode: 'type2_diabetes',
        stage: '无并发症',
        diagnosisBasis: '2023-09 深圳市人民医院 内分泌 OGTT');
    await repo.insertDisease(
        name: '高血压',
        foundDate: daysAgo(500),
        status: '当前存在',
        conditionCode: 'hypertension',
        stage: '1 级');

    // —— 过敏史：一条 ——
    await repo.insertAllergy(
        substance: '青霉素',
        category: '药物',
        reaction: '皮疹',
        severity: '中',
        notedDate: daysAgo(2000));

    // —— 用药：两种 ——
    await repo.insertMedication(
      name: '二甲双胍缓释片',
      dosage: '0.5',
      dosageUnit: 'g',
      timesPerDay: '2',
      startDate: daysAgo(680),
      status: '当前使用',
      conditionCode: 'type2_diabetes',
      notes: '早晚餐后',
    );
    await repo.insertMedication(
      name: '氨氯地平片',
      dosage: '5',
      dosageUnit: 'mg',
      timesPerDay: '1',
      startDate: daysAgo(480),
      status: '当前使用',
      conditionCode: 'hypertension',
    );

    // —— 服药提醒：二甲双胍 ——
    final meds = await repo.getAllMedications();
    final metformin = meds.where((m) => m.name == '二甲双胍缓释片');
    if (metformin.isNotEmpty) {
      await repo.setMedicationReminder(
        medicationId: metformin.first.id,
        profileId: repo.activeProfileId,
        medName: '二甲双胍缓释片',
        times: const ['08:00', '20:00'],
        enabled: true,
        detail: '每次 0.5g',
      );
    }
  }

  /// 按字典定义批量写入某份报告的指标：单位 / 参考范围 / 状态都取自 `METRIC_DICTIONARY`，
  /// 状态用本地 `computeStatus` 计算，和真实导入路径一致。
  static Future<void> _addMetrics(
    HealthRepository repo,
    int reportId,
    DateTime measuredAt,
    Map<String, num> values,
  ) async {
    for (final entry in values.entries) {
      final def = findMetricDefinition(entry.key);
      if (def == null) continue;
      final v = entry.value.toDouble();
      await repo.insertMetric(
        metricId: def.metricId,
        metricName: def.metricName,
        value: v,
        rawValue: '${_n(v)} ${def.unit}',
        numericValue: v,
        unit: def.unit,
        referenceMin: def.typicalRange.min,
        referenceMax: def.typicalRange.max,
        referenceRangeRaw: _rangeText(def.typicalRange),
        status: computeStatus(v, def.typicalRange),
        bodySystem: def.bodySystem,
        measuredAt: measuredAt,
        sourceType: 'report_import',
        reportId: reportId,
        rawName: def.metricName,
        matchType: 'exact',
        recognitionConfidence: 0.95,
        verificationStatus: 'user_confirmed',
      );
    }
  }

  static String? _rangeText(ReferenceRange r) {
    if (r.min != null && r.max != null) return '${_n(r.min!)}-${_n(r.max!)}';
    if (r.min != null) return '≥${_n(r.min!)}';
    if (r.max != null) return '≤${_n(r.max!)}';
    return null;
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}
