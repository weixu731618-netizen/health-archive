import '../data/health_repository.dart';

/// 把 exportHealthData() 产出的快照 Map 重新写回本地 Drift。
///
/// 被两条备份路径共用：
/// - CloudBackupService：快照来自服务器（无图片，图片恢复是已知限制）；
/// - LocalBackupService：快照来自本地导出的 zip 包（图片已随包落盘，可完整恢复）。
///
/// 恢复策略是「先清空本地再重建」（覆盖），调用方必须在 UI 层先弹二次确认。
/// 单条记录解析失败会被跳过、不会中断整体恢复；只有清空/写入这类基础设施性异常
/// 才会中断并把错误信息带回给用户。
class SnapshotImporter {
  const SnapshotImporter._();

  /// 执行恢复，返回给用户看的状态说明。
  ///
  /// [reportImagePaths]：旧报告本地 id（字符串形式）-> 已经落盘的新图片路径。
  /// 网络恢复没有图片可传 null/空 map；本地 zip 恢复应传入解压后的映射。
  static Future<String> restore(
    HealthRepository repo,
    Map<String, dynamic> snapshot, {
    Map<String, String>? reportImagePaths,
  }) async {
    try {
      // 清空 + 重建放进同一个数据库事务：只有整段都跑完才会提交，
      // 中途崩溃/被杀不会提交任何一半的改动，重启后数据库会保持恢复前的完整状态，
      // 不会出现「已清空但没写完新数据」导致数据永久丢失的中间态。
      await repo.transaction(() async {
        await repo.clearAllHealthData();
        await _importPersonProfiles(repo, snapshot['personProfiles']);
        await _importProfile(repo, snapshot['profile']);
        final encounterIdMap =
            await _importEncounters(repo, snapshot['encounters']);
        final reportIdMap = await _importReports(
            repo, snapshot['reports'], reportImagePaths, encounterIdMap);
        await _importMetrics(repo, snapshot['metrics'], reportIdMap);
        await _importDaily(repo, snapshot['dailyRecords']);
        await _importDiseases(repo, snapshot['diseases']);
        await _importMedications(repo, snapshot['medications']);
        await _importAllergies(repo, snapshot['allergies']);
        await _importReminders(repo, snapshot['reminders']);
        await _importReportOrgans(repo, snapshot['reportOrgans'], reportIdMap);
        await _importMetricMatchCache(repo, snapshot['metricMatchCache']);
      });
    } catch (e) {
      return '恢复过程中出现错误，部分数据可能未恢复：$e';
    }
    return '恢复成功';
  }

  /// B1：先按原始 id 重建全部人员档案（本人 + 家庭成员），
  /// 各条健康记录的 profileId 才能正确对上。
  static Future<void> _importPersonProfiles(
      HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      final id = _toInt(item['id']);
      if (id == null) continue;
      try {
        await repo.restorePersonProfile(
          id: id,
          displayName: (item['displayName'] ?? '本人').toString(),
          relationship: (item['relationship'] ?? 'other').toString(),
          sex: item['sex']?.toString(),
          dateOfBirth: DateTime.tryParse('${item['dateOfBirth']}'),
          heightCm: _toDouble(item['heightCm']),
        );
      } catch (_) {
        // 单条失败跳过
      }
    }
  }

  /// 兼容旧备份（没有 personProfiles 列表、只有单个 profile）：写回「本人」资料。
  static Future<void> _importProfile(HealthRepository repo, dynamic profile) async {
    if (profile is! Map) return;
    try {
      await repo.upsertProfile(
        nickname: (profile['nickname'] ?? '').toString(),
        gender: (profile['gender'] ?? '').toString(),
        birthDate: DateTime.tryParse('${profile['birthDate']}'),
        heightCm: _toDouble(profile['heightCm']),
      );
    } catch (_) {
      // 资料恢复失败不影响其余数据恢复
    }
  }

  /// 重建就诊记录，返回 旧 id -> 新 id 映射（供报告重新归属）。
  static Future<Map<int, int>> _importEncounters(
      HealthRepository repo, dynamic list) async {
    final idMap = <int, int>{};
    if (list is! List) return idMap;
    for (final item in list) {
      if (item is! Map) continue;
      final oldId = item['id'];
      if (oldId is! num) continue;
      try {
        final newId = await repo.insertEncounter(
          profileId: _toInt(item['profileId']) ??
              HealthRepository.defaultProfileId,
          visitDate:
              DateTime.tryParse('${item['visitDate']}') ?? DateTime.now(),
          hospitalName: (item['hospitalName'] ?? '').toString(),
          department: (item['department'] ?? '').toString(),
          diagnosis: item['diagnosis']?.toString(),
          advice: item['advice']?.toString(),
          notes: item['notes']?.toString(),
          conditionCode: item['conditionCode']?.toString(),
        );
        idMap[oldId.toInt()] = newId;
      } catch (_) {}
    }
    return idMap;
  }

  static Future<void> _importAllergies(
      HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        await repo.insertAllergy(
          profileId: _toInt(item['profileId']) ??
              HealthRepository.defaultProfileId,
          substance: (item['substance'] ?? '').toString(),
          category: (item['category'] ?? '药物').toString(),
          reaction: item['reaction']?.toString(),
          severity: (item['severity'] ?? '不确定').toString(),
          notedDate: DateTime.tryParse('${item['notedDate']}'),
          notes: item['notes']?.toString(),
        );
      } catch (_) {}
    }
  }

  /// 重建报告记录，返回旧报告本地 id -> 新报告本地 id 的映射，供指标恢复时重新关联。
  static Future<Map<int, int>> _importReports(
    HealthRepository repo,
    dynamic list,
    Map<String, String>? reportImagePaths,
    Map<int, int> encounterIdMap,
  ) async {
    final idMap = <int, int>{};
    if (list is! List) return idMap;
    for (final item in list) {
      if (item is! Map) continue;
      final oldId = item['id'];
      if (oldId is! num) continue;
      try {
        final imagePath = reportImagePaths?[oldId.toInt().toString()];
        final oldEnc = _toInt(item['encounterId']);
        final newId = await repo.insertReport(
          profileId: _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          hospitalName: (item['hospitalName'] ?? '').toString(),
          reportDate: DateTime.tryParse('${item['reportDate']}') ?? DateTime.now(),
          reportType: (item['reportType'] ?? '').toString(),
          sourceImagePath: imagePath,
          rawText: item['rawText']?.toString(),
          tags: HealthRepository.parseTags(item['tags']?.toString()),
          recognitionStatus: (item['recognitionStatus'] ?? 'confirmed').toString(),
          conditionCode: item['conditionCode']?.toString(),
          encounterId: oldEnc == null ? null : encounterIdMap[oldEnc],
        );
        idMap[oldId.toInt()] = newId;
      } catch (_) {
        // 单条失败跳过，不中断整体恢复
      }
    }
    return idMap;
  }

  static Future<void> _importMetrics(
    HealthRepository repo,
    dynamic list,
    Map<int, int> reportIdMap,
  ) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        final oldReportId = item['reportId'];
        final mappedReportId =
            oldReportId is num ? reportIdMap[oldReportId.toInt()] : null;
        await repo.insertMetric(
          profileId: _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          metricId: (item['metricId'] ?? '').toString(),
          metricName: (item['metricName'] ?? '').toString(),
          value: (item['value'] ?? 0).toDouble(),
          rawValue: item['rawValue']?.toString(),
          numericValue: _toDouble(item['numericValue']),
          unit: (item['unit'] ?? '').toString(),
          canonicalValue: _toDouble(item['canonicalValue']),
          canonicalUnit: item['canonicalUnit']?.toString(),
          referenceMin: _toDouble(item['referenceMin']),
          referenceMax: _toDouble(item['referenceMax']),
          referenceRangeRaw: item['referenceRangeRaw']?.toString(),
          sourceAbnormalFlag: item['sourceAbnormalFlag']?.toString(),
          status: (item['status'] ?? '未判断').toString(),
          bodySystem: (item['bodySystem'] ?? '其他').toString(),
          measuredAt: DateTime.tryParse('${item['measuredAt']}') ?? DateTime.now(),
          sourceType: (item['sourceType'] ?? 'manual').toString(),
          sourceId: item['sourceId']?.toString(),
          notes: item['notes']?.toString(),
          rawName: item['rawName']?.toString(),
          matchType: (item['matchType'] ?? 'manual').toString(),
          recognitionConfidence: _toDouble(item['recognitionConfidence']),
          verificationStatus:
              (item['verificationStatus'] ?? 'user_confirmed').toString(),
          sourcePage: _toInt(item['sourcePage']),
          sourceBoundingBox: item['sourceBoundingBox']?.toString(),
          reportId: mappedReportId,
        );
      } catch (_) {
        // 单条失败跳过，不中断整体恢复
      }
    }
  }

  static Future<void> _importDaily(HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        await repo.insertDaily(
          profileId: _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          type: (item['type'] ?? '').toString(),
          value1: (item['value1'] ?? 0).toDouble(),
          value2: _toDouble(item['value2']),
          unit: (item['unit'] ?? '').toString(),
          context: item['context']?.toString(),
          measuredAt: DateTime.tryParse('${item['measuredAt']}') ?? DateTime.now(),
          notes: item['notes']?.toString(),
        );
      } catch (_) {}
    }
  }

  static Future<void> _importDiseases(HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        await repo.insertDisease(
          profileId: _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          name: (item['name'] ?? '').toString(),
          foundDate: DateTime.tryParse('${item['foundDate']}'),
          status: (item['status'] ?? '不确定').toString(),
          notes: item['notes']?.toString(),
          conditionCode: item['conditionCode']?.toString(),
          stage: item['stage']?.toString(),
          diagnosisBasis: item['diagnosisBasis']?.toString(),
        );
      } catch (_) {}
    }
  }

  static Future<void> _importMedications(HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        await repo.insertMedication(
          profileId: _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          name: (item['name'] ?? '').toString(),
          dosage: item['dosage']?.toString(),
          dosageUnit: item['dosageUnit']?.toString(),
          usage: item['usage']?.toString(),
          timesPerDay: item['timesPerDay']?.toString(),
          startDate: DateTime.tryParse('${item['startDate']}'),
          endDate: DateTime.tryParse('${item['endDate']}'),
          status: (item['status'] ?? '当前使用').toString(),
          notes: item['notes']?.toString(),
          conditionCode: item['conditionCode']?.toString(),
        );
      } catch (_) {}
    }
  }

  static Future<void> _importReminders(
      HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      try {
        await repo.restoreReminder(
          profileId:
              _toInt(item['profileId']) ?? HealthRepository.defaultProfileId,
          kind: (item['kind'] ?? 'recheck').toString(),
          title: (item['title'] ?? '').toString(),
          detail: item['detail']?.toString(),
          relatedMetricId: item['relatedMetricId']?.toString(),
          relatedMedicationId: _toInt(item['relatedMedicationId']),
          dueDate: DateTime.tryParse('${item['dueDate']}'),
          dailyTimes: item['dailyTimes']?.toString(),
          enabled: item['enabled'] == null ? true : item['enabled'] == true,
          completedAt: DateTime.tryParse('${item['completedAt']}'),
          conditionCode: item['conditionCode']?.toString(),
          followUpKey: item['followUpKey']?.toString(),
          sourceType: (item['sourceType'] ?? 'user').toString(),
          areaName: item['areaName']?.toString(),
          recommendedDate: DateTime.tryParse('${item['recommendedDate']}'),
        );
      } catch (_) {
        // 单条失败跳过
      }
    }
  }

  /// 03：报告-器官关联。旧 reportId 经 [reportIdMap] 映射到新库里的 id。
  static Future<void> _importReportOrgans(
    HealthRepository repo,
    dynamic list,
    Map<int, int> reportIdMap,
  ) async {
    if (list is! List) return;
    final byReport = <int, List<String>>{};
    final profileByReport = <int, int>{};
    for (final item in list) {
      if (item is! Map) continue;
      final oldId = item['reportId'];
      final newId = oldId is num ? reportIdMap[oldId.toInt()] : null;
      final area = item['areaName']?.toString();
      if (newId == null || area == null || area.isEmpty) continue;
      byReport.putIfAbsent(newId, () => []).add(area);
      final pid = _toInt(item['profileId']);
      if (pid != null) profileByReport[newId] = pid;
    }
    for (final entry in byReport.entries) {
      try {
        await repo.setReportOrgans(
          entry.key,
          entry.value,
          profileId: profileByReport[entry.key],
        );
      } catch (_) {
        // 单条失败跳过
      }
    }
  }

  /// 指标名归一化缓存（deepseek / learned / manual 映射）。丢了最多某项重新
  /// 识别一次，所以单条失败静默跳过。
  static Future<void> _importMetricMatchCache(
      HealthRepository repo, dynamic list) async {
    if (list is! List) return;
    for (final item in list) {
      if (item is! Map) continue;
      final canonicalId = item['canonicalId']?.toString();
      final rawDisplay = item['rawDisplay']?.toString();
      if (canonicalId == null ||
          canonicalId.isEmpty ||
          rawDisplay == null ||
          rawDisplay.isEmpty) {
        continue;
      }
      try {
        await repo.upsertMetricMatch(
          rawDisplay: rawDisplay,
          canonicalId: canonicalId,
          source: (item['source'] ?? 'deepseek').toString(),
          confidence: _toDouble(item['confidence']),
          originReportId: _toInt(item['originReportId']),
        );
      } catch (_) {}
    }
  }

  static double? _toDouble(dynamic v) => v is num ? v.toDouble() : null;

  static int? _toInt(dynamic v) => v is num ? v.toInt() : null;
}
