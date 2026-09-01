import 'package:flutter/cupertino.dart';

import '../main.dart';
import '../utils/patient_name_match.dart';

/// 保存报告前的「家庭成员核对」。在核对页 / 图文报告页点保存时调用。
///
/// 两件事：
/// 1. 姓名比对：OCR 姓名与当前档案「认识的真名」明显不一致 → 弹框问是否存错档案。
///    首次遇到真名则静默记住（不打扰）。
/// 2. 资料预填：报告读到性别 / 出生日期、而当前档案对应字段为空 → 轻量询问是否补充。
///
/// 返回 true 表示可以继续保存；false 表示用户取消。
Future<bool> guardReportAgainstActiveProfile(
  BuildContext context, {
  required String ocrPatientName,
  String ocrGender = '',
  DateTime? ocrBirthDate,
}) async {
  final repo = appRepository;
  if (repo == null) return true;

  final profileId = repo.activeProfileId;
  final profile = await repo.getPersonProfile(profileId);
  if (profile == null) return true;

  // —— 1. 姓名比对 ——
  final check = checkReportNameAgainstProfile(
    ocrPatientName: ocrPatientName,
    knownNamesStored: profile.knownNames,
  );
  switch (check) {
    case NameCheckResult.firstSeen:
      await repo.addKnownName(profileId, ocrPatientName);
    case NameCheckResult.mismatch:
      if (!context.mounted) return true;
      final known = parseKnownNames(profile.knownNames).join('、');
      final proceed = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('是不是存错档案了？'),
          content: Text(
            '这份报告上的姓名是「$ocrPatientName」，'
            '但当前档案「${profile.displayName}」记录的是「$known」。\n\n'
            '仍要把它保存到「${profile.displayName}」吗？',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('仍存到「${profile.displayName}」'),
            ),
          ],
        ),
      );
      if (proceed != true) return false;
      // 用户确认了：把这个名字也并入该档案「认识的真名」，之后不再为它反复提醒。
      await repo.addKnownName(profileId, ocrPatientName);
    case NameCheckResult.ok:
    case NameCheckResult.noOpinion:
      break;
  }

  // —— 2. 资料预填（性别 / 出生日期）——
  final fillGender = ocrGender.isNotEmpty && (profile.sex ?? '').isEmpty;
  final fillBirth = ocrBirthDate != null && profile.dateOfBirth == null;
  if ((fillGender || fillBirth) && context.mounted) {
    final parts = <String>[
      if (fillGender) '性别$ocrGender',
      if (fillBirth)
        '出生日期${ocrBirthDate.year}-${ocrBirthDate.month.toString().padLeft(2, '0')}-${ocrBirthDate.day.toString().padLeft(2, '0')}',
    ];
    final apply = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('补充档案资料？'),
        content: Text('报告上读到${parts.join('、')}，'
            '当前档案「${profile.displayName}」还没填。补充进去吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('不用'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('补充'),
          ),
        ],
      ),
    );
    if (apply == true) {
      await repo.updatePersonProfileFields(
        profileId,
        sex: fillGender ? ocrGender : (profile.sex),
        dateOfBirth: fillBirth ? ocrBirthDate : (profile.dateOfBirth),
        displayName: profile.displayName,
        relationship: profile.relationship,
        heightCm: profile.heightCm,
      );
    }
  }

  return true;
}
