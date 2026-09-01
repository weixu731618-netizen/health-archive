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

    // —— 血常规（血液系统）——
    final r4 = await repo.insertReport(
      hospitalName: '深圳市人民医院',
      reportDate: daysAgo(30),
      reportType: '血常规',
      recognitionStatus: 'confirmed',
      rawText: '白细胞、红细胞、血红蛋白、血小板均在正常范围。',
    );
    await _addMetrics(repo, r4, daysAgo(30), {
      'WBC': 6.1, 'RBC': 4.8, 'HGB': 148, 'PLT': 240, 'NEUT': 58, 'LYMPH': 32,
    });

    // —— 甲状腺功能（内分泌/代谢）+ 骨密度/维D（骨骼关节）+ 肿瘤标志物（其他）——
    final r5 = await repo.insertReport(
      hospitalName: '体检中心',
      reportDate: daysAgo(20),
      reportType: '甲状腺功能',
      recognitionStatus: 'confirmed',
      rawText: 'TSH、FT4 正常；骨密度 T 值 -1.2 骨量减少；维生素D 略低。CEA 正常。',
    );
    await _addMetrics(repo, r5, daysAgo(20), {
      'TSH': 2.1, 'FT4': 15.5, 'BMD_T': -1.2, 'VITD': 22, 'CEA': 2.3,
    });

    // —— 图文/影像报告：给「化验查不到」的部位各挂一条 ——
    Future<void> imaging(String type, String hospital, int ago,
        Set<String> organs, String text) async {
      final id = await repo.insertReport(
        hospitalName: hospital,
        reportDate: daysAgo(ago),
        reportType: type,
        recognitionStatus: 'confirmed',
        rawText: text,
      );
      await repo.setReportOrgans(id, organs);
    }

    await imaging('CT', '深圳市人民医院', 60, {'呼吸系统'},
        '胸部CT平扫：双肺纹理清晰，未见结节及实变。');
    await imaging('彩超', '深圳市人民医院', 55, {'肝胆', '胰腺', '肾脏/泌尿'},
        '上腹部彩超：肝、胆、胰、脾、双肾未见明显异常。');
    await imaging('门诊病历', '社区健康服务中心', 50, {'消化系统'},
        '胃镜：慢性非萎缩性胃炎，Hp 阴性。');
    await imaging('彩超', '市第二人民医院', 45, {'心血管'},
        '心脏彩超：左室射血分数 62%，各瓣膜未见异常。');
    await imaging('门诊病历', '眼科医院', 40, {'眼睛'},
        '眼底检查：双眼视网膜未见糖尿病视网膜病变。');
    await imaging('门诊病历', '口腔医院', 35, {'口腔牙齿'},
        '口腔检查：牙结石 II 度，建议洁牙。');
    await imaging('门诊病历', '社区健康服务中心', 28, {'耳鼻喉'},
        '耳鼻喉检查：双耳听力正常，鼻咽部未见异常。');
    await imaging('MRI', '市第二人民医院', 22, {'骨骼关节'},
        '颈椎MRI：C5/6 椎间盘轻度突出。');
    await imaging('门诊病历', '皮肤病医院', 16, {'皮肤与足部'},
        '皮肤科：足部皮肤干燥，无破溃，糖尿病足风险低。');
    await imaging('彩超', '市第二人民医院', 12, {'生殖系统'},
        '前列腺彩超：前列腺轻度增生，大小约 3.8×3.0×2.6cm。');

    // —— 一条「未关联记录」（识别归不到类型时的兜底）——
    await repo.insertReport(
      hospitalName: '某医院',
      reportDate: daysAgo(8),
      reportType: '未关联记录',
      recognitionStatus: 'confirmed',
      rawText: '（识别出的文字，归不到已知类型，待整理）会诊意见：建议内分泌科随访。',
    );

    // —— 心率日常记录 ——
    const hr = [78, 82, 76, 80, 74];
    for (var i = 0; i < hr.length; i++) {
      await repo.insertDaily(
        type: 'heart_rate',
        value1: hr[i].toDouble(),
        unit: 'bpm',
        measuredAt: daysAgo(i * 10 + 3),
      );
    }

    // —— 复查提醒：内分泌/代谢，3 个月后 ——
    final due = now.add(const Duration(days: 90));
    await repo.insertReminder(
      kind: 'recheck',
      title: '复查 内分泌/代谢',
      detail: '糖化血红蛋白偏高 · 手动设置',
      dueDate: due,
      sourceType: 'user',
      areaName: '内分泌/代谢',
      recommendedDate: due,
    );
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
