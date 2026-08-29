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
      birthDate: DateTime(1986, 5, 12),
      heightCm: 172,
    );

    // —— 报告 1：入院生化 + 血脂 + 血糖（约 3 个月前，异常偏多）——
    final r1 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(92),
      reportType: '生化检查',
      recognitionStatus: 'confirmed',
      tags: const ['体检', '慢病随访'],
      rawText: '生化全套：尿酸、空腹血糖、血脂多项升高，肝功能轻度异常，肾功能大致正常。'
          '建议内分泌科随诊，低嘌呤低脂饮食。',
    );
    await _addMetrics(repo, r1, daysAgo(92), {
      'ALT': 41, 'AST': 30, 'GGT': 62, 'TBIL': 14.2,
      'CREA': 88, 'EGFR': 96, 'BUN': 5.6,
      'UA': 508, 'FPG': 7.4,
      'TC': 6.1, 'TG': 2.6, 'LDLC': 4.3, 'HDLC': 0.95,
      'K': 4.3, 'NA': 140,
    });

    // —— 报告 2：血常规（与报告 1 同日）——
    final r2 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(92),
      reportType: '血常规',
      recognitionStatus: 'confirmed',
      rawText: '血常规：各项大致正常。',
    );
    await _addMetrics(repo, r2, daysAgo(92), {
      'WBC': 6.8, 'RBC': 5.0, 'HGB': 151, 'HCT': 45, 'PLT': 232, 'NEUT': 4.1,
    });

    // —— 报告 3：糖尿病随访 · 糖化血红蛋白（约 2 个月前）——
    final r3 = await repo.insertReport(
      hospitalName: '社区健康服务中心',
      reportDate: daysAgo(60),
      reportType: '糖尿病随访',
      recognitionStatus: 'confirmed',
      rawText: '糖化血红蛋白偏高，空腹血糖偏高，建议加强饮食运动管理。',
    );
    await _addMetrics(repo, r3, daysAgo(60), {'HBA1C': 7.1, 'FPG': 7.0});

    // —— 报告 4：甲状腺功能（约 5 周前，正常）——
    final r4 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(35),
      reportType: '甲状腺功能',
      recognitionStatus: 'confirmed',
      rawText: '甲状腺功能三项均在参考范围内。',
    );
    await _addMetrics(repo, r4, daysAgo(35), {'TSH': 2.1, 'FT3': 4.8, 'FT4': 15.2});

    // —— 报告 5：生化复查（约 2 周前，部分好转，形成趋势）——
    final r5 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(14),
      reportType: '生化复查',
      recognitionStatus: 'confirmed',
      rawText: '复查：尿酸、血糖、血脂较前下降，仍偏高；肝功能恢复正常。继续用药，1 个月后复查。',
    );
    await _addMetrics(repo, r5, daysAgo(14), {
      'UA': 442, 'FPG': 6.6, 'HBA1C': 6.7,
      'CREA': 90, 'EGFR': 94,
      'TC': 5.2, 'TG': 1.9, 'LDLC': 3.1, 'ALT': 33,
    });

    // —— 报告 6：胸部 CT（影像，约 5 周前，无结构化指标）——
    await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(35),
      reportType: 'CT',
      recognitionStatus: 'confirmed',
      tags: const ['体检'],
      rawText: '胸部CT平扫：两肺纹理清晰，未见明显实质性病变；\n'
          '右肺上叶见数枚微小结节，最大约 2mm，考虑良性，建议年度复查；\n'
          '纵隔内未见肿大淋巴结。心影不大，主动脉硬化。',
    );

    // —— 报告 7：腹部 B 超（影像，约 3 周前，无结构化指标）——
    await repo.insertReport(
      hospitalName: '社区健康服务中心',
      reportDate: daysAgo(21),
      reportType: 'B超',
      recognitionStatus: 'confirmed',
      rawText: '肝脏形态饱满，实质回声增粗增强，提示轻度脂肪肝；\n'
          '胆囊、胰腺、脾脏、双肾未见明显异常。',
    );

    // —— 日常记录：体重（缓慢下降）——
    for (var w = 12; w >= 0; w--) {
      final v = 82.5 - (12 - w) * 0.35;
      await repo.insertDaily(
        type: 'weight',
        value1: double.parse(v.toStringAsFixed(1)),
        unit: 'kg',
        measuredAt: daysAgo(w * 7 + 1),
      );
    }

    // —— 日常记录：血压（偏高，逐步改善）——
    const bp = [
      [142, 92], [138, 90], [140, 91], [135, 87],
      [133, 85], [136, 88], [130, 84], [128, 82],
    ];
    for (var i = 0; i < bp.length; i++) {
      await repo.insertDaily(
        type: 'blood_pressure',
        value1: bp[i][0].toDouble(),
        value2: bp[i][1].toDouble(),
        unit: 'mmHg',
        context: '晨起',
        measuredAt: daysAgo(i * 10 + 2),
      );
    }

    // —— 日常记录：空腹血糖 ——
    const glu = [7.6, 7.1, 7.3, 6.9, 6.6, 6.8, 6.4, 6.7];
    for (var i = 0; i < glu.length; i++) {
      await repo.insertDaily(
        type: 'blood_glucose',
        value1: glu[i],
        unit: 'mmol/L',
        context: '空腹',
        measuredAt: daysAgo(i * 9 + 3),
      );
    }

    // —— 日常记录：心率 ——
    for (var i = 0; i < 6; i++) {
      await repo.insertDaily(
        type: 'heart_rate',
        value1: 70 + (i % 3) * 5.0,
        unit: 'bpm',
        measuredAt: daysAgo(i * 12 + 4),
      );
    }

    // —— 疾病史 ——
    await repo.insertDisease(
        name: '2型糖尿病',
        foundDate: daysAgo(400),
        status: '确诊',
        notes: '口服降糖药控制中');
    await repo.insertDisease(
        name: '高血压1级', foundDate: daysAgo(300), status: '确诊');
    await repo.insertDisease(
        name: '高尿酸血症',
        foundDate: daysAgo(210),
        status: '确诊',
        notes: '无痛风急性发作史');
    await repo.insertDisease(
        name: '轻度脂肪肝', foundDate: daysAgo(21), status: '确诊');
    await repo.insertDisease(
        name: '甲状腺结节',
        foundDate: daysAgo(120),
        status: '随访',
        notes: '每年复查甲功 + 超声');

    // —— 用药 ——
    await repo.insertMedication(
      name: '二甲双胍缓释片',
      dosage: '0.5',
      dosageUnit: 'g',
      timesPerDay: '2',
      startDate: daysAgo(380),
      status: '当前使用',
      notes: '早晚餐后',
    );
    await repo.insertMedication(
      name: '苯溴马隆片',
      dosage: '50',
      dosageUnit: 'mg',
      timesPerDay: '1',
      startDate: daysAgo(180),
      status: '当前使用',
      notes: '多饮水，碱化尿液',
    );
    await repo.insertMedication(
      name: '氨氯地平片',
      dosage: '5',
      dosageUnit: 'mg',
      timesPerDay: '1',
      startDate: daysAgo(280),
      status: '当前使用',
    );
    await repo.insertMedication(
      name: '阿托伐他汀钙片',
      dosage: '20',
      dosageUnit: 'mg',
      timesPerDay: '1',
      startDate: daysAgo(90),
      status: '当前使用',
      notes: '每晚睡前服用',
    );
    await repo.insertMedication(
      name: '非布司他片',
      dosage: '40',
      dosageUnit: 'mg',
      timesPerDay: '1',
      startDate: daysAgo(230),
      endDate: daysAgo(185),
      status: '已停用',
      notes: '换用苯溴马隆',
    );

    // —— 提醒（演示 B2）——
    await repo.insertReminder(
      kind: 'recheck',
      title: '复查 尿酸',
      detail: '上次 442 μmol/L（偏高）',
      relatedMetricId: 'UA',
      dueDate: daysAgo(-18),
    );
    await repo.insertReminder(
      kind: 'recheck',
      title: '复查 糖化血红蛋白',
      detail: '上次 6.7%（偏高）',
      relatedMetricId: 'HBA1C',
      dueDate: daysAgo(-5),
    );
    for (final med in [
      ('二甲双胍缓释片', '08:00,20:00', '每次 0.5g'),
      ('阿托伐他汀钙片', '21:00', '每次 20mg'),
    ]) {
      final rows = await repo.getAllMedications();
      final match = rows.where((m) => m.name == med.$1);
      if (match.isNotEmpty) {
        await repo.setMedicationReminder(
          medicationId: match.first.id,
          profileId: repo.activeProfileId,
          medName: med.$1,
          times: med.$2.split(','),
          enabled: true,
          detail: med.$3,
        );
      }
    }

    // —— 家庭成员：配偶（数据量较少，用于演示档案切换）——
    final spouseId = await repo.insertPersonProfile(
      displayName: '徐女士',
      relationship: '配偶',
      sex: '女',
      dateOfBirth: DateTime(1988, 9, 3),
      heightCm: 162,
    );
    final selfId = repo.activeProfileId;
    await repo.setActiveProfileId(spouseId);
    final sr = await repo.insertReport(
      hospitalName: '社区健康服务中心',
      reportDate: daysAgo(20),
      reportType: '入职体检',
      recognitionStatus: 'confirmed',
      tags: const ['体检'],
      rawText: '血常规、肝肾功能、血脂大致正常；建议均衡饮食、规律作息。',
    );
    await _addMetrics(repo, sr, daysAgo(20), {
      'HGB': 132, 'WBC': 6.1, 'PLT': 210,
      'ALT': 18, 'CREA': 62, 'TC': 4.6, 'LDLC': 2.5, 'FPG': 5.1,
    });
    for (var w = 6; w >= 0; w--) {
      await repo.insertDaily(
        type: 'weight',
        value1: 55.0 + (6 - w) * 0.1,
        unit: 'kg',
        measuredAt: daysAgo(w * 7 + 1),
      );
    }
    await repo.insertDisease(
        name: '缺铁性贫血', foundDate: daysAgo(500), status: '已恢复');
    await repo.setActiveProfileId(selfId);
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
