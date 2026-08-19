import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../main.dart';
import '../services/report_ocr_service.dart';

/// 开发阶段：OCR 结果预览页。
/// 展示「识别到 XX 行」与逐行 OCR 文字，用于验证真实百度 OCR 流程。
/// 本页仅为开发验证使用，不是最终结构化确认页。
class OcrDebugPage extends StatelessWidget {
  final List<OcrLine> lines;
  final Uint8List? imageBytes; // 可选：展示原图便于核对

  const OcrDebugPage({super.key, required this.lines, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR 结果预览')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '识别到 ${lines.length} 行',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          if (imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes!,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('未识别到文字',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              ),
            )
          else
            for (final line in lines) ...[
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          line.text,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.textPrimary),
                        ),
                      ),
                      if (line.text.isNotEmpty)
                        Text(
                          '[${line.left},${line.top}]',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}
