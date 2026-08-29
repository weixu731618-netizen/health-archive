import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../data/app_database.dart';
import 'format.dart';

/// 一份报告可导出的内容。
/// - [filePaths] 非空：把原图文件交给系统分享面板（iOS 上可「存储到文件 / 存储图像 / AirDrop / 微信」等）。
/// - [filePaths] 为空但 [text] 非空：没有原图，退化为分享报告的文字内容（说明 + 结论）。
/// - [hasAnything] 为 false：这份报告既没有原图也没有文字，没有可导出的东西。
class ReportSharePayload {
  final List<String> filePaths;
  final String text;
  final bool hasAnything;

  const ReportSharePayload({
    required this.filePaths,
    required this.text,
    required this.hasAnything,
  });
}

/// 报告的一行说明：医院 · 类型 · 日期（缺项自动跳过）。
String reportShareCaption(MedicalReport report) {
  final parts = <String>[
    if (report.hospitalName.trim().isNotEmpty) report.hospitalName.trim(),
    if (report.reportType.trim().isNotEmpty) report.reportType.trim(),
    formatDate(report.reportDate),
  ];
  return parts.join(' · ');
}

/// 组装一份报告的可分享内容。
///
/// [fileExists] 仅供测试注入；生产用 `File(path).existsSync()`。
ReportSharePayload buildReportSharePayload(
  MedicalReport report, {
  bool Function(String path)? fileExists,
}) {
  final exists = fileExists ?? (p) => File(p).existsSync();
  final caption = reportShareCaption(report);
  final rawText = (report.rawText ?? '').trim();

  final imagePath = report.sourceImagePath;
  final hasImage =
      imagePath != null && imagePath.trim().isNotEmpty && exists(imagePath);

  if (hasImage) {
    // 有原图：分享原图文件即可；结论文字在详情页里能看，这里不塞进分享文本免得化验单的
    // OCR 全文噪音太大。
    return ReportSharePayload(
      filePaths: [imagePath],
      text: caption,
      hasAnything: true,
    );
  }
  if (rawText.isNotEmpty) {
    // 没有原图（旧数据 / Web / 只填了文字的影像报告）：把文字内容导出去。
    return ReportSharePayload(
      filePaths: const [],
      text: '$caption\n\n$rawText',
      hasAnything: true,
    );
  }
  return const ReportSharePayload(filePaths: [], text: '', hasAnything: false);
}

/// 通过系统分享面板导出一份报告。返回 false 表示这份报告没有可导出的内容。
Future<bool> shareReport(MedicalReport report) async {
  final payload = buildReportSharePayload(report);
  if (!payload.hasAnything) return false;
  await SharePlus.instance.share(
    ShareParams(
      files: payload.filePaths.isEmpty
          ? null
          : [for (final path in payload.filePaths) XFile(path)],
      text: payload.text,
      subject: reportShareCaption(report),
    ),
  );
  return true;
}
