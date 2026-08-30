import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';
import '../utils/format.dart';
import '../utils/medical_summary.dart';

/// B4：「给医生看的一页纸」——当前档案的疾病史 / 用药 / 近期异常指标 / 近期报告，
/// 可导出为一张长图或分享文字，就诊时给医生看。不含任何医疗诊断。
class MedicalSummaryPage extends StatefulWidget {
  const MedicalSummaryPage({super.key});

  @override
  State<MedicalSummaryPage> createState() => _MedicalSummaryPageState();
}

class _MedicalSummaryPageState extends State<MedicalSummaryPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  MedicalSummary? _summary;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) {
      setState(() => _loading = false);
      return;
    }
    final profile = await repo.getProfile();
    final diseases = await repo.getAllDiseases();
    final meds = await repo.getAllMedications();
    final allergies = await repo.getAllAllergies();
    final metrics = await repo.getAllMetrics();
    final reports = await repo.getAllReports();
    final counts = <int, int>{};
    for (final r in reports) {
      counts[r.id] = (await repo.getMetricsByReport(r.id)).length;
    }
    final summary = buildMedicalSummary(
      profile: profile,
      diseases: diseases,
      medications: meds,
      allergies: allergies,
      metrics: metrics,
      reports: reports,
      reportMetricCounts: counts,
    );
    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  Future<void> _exportImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('内容未就绪');
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('导出失败');
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path,
          'health_summary_${DateTime.now().millisecondsSinceEpoch}.png'));
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '健康摘要 · ${_summary?.personName ?? ''}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('导出失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() async {
    final s = _summary;
    if (s == null) return;
    await SharePlus.instance.share(ShareParams(text: s.toPlainText()));
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('给医生看的摘要'),
        actions: [
          if (s != null && !s.isEmpty)
            IconButton(
              tooltip: '分享文字',
              icon: const Icon(Icons.notes_outlined),
              onPressed: _busy ? null : _shareText,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : s == null || s.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '当前档案还没有疾病史、用药或检查记录，先录入一些再生成摘要。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: _SummaryCard(summary: s),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _exportImage,
                          icon: const Icon(Icons.ios_share),
                          label: Text(_busy ? '导出中…' : '导出为图片并分享'),
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MedicalSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('健康摘要 · ${summary.personName}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          if ((summary.ageSexLine ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(summary.ageSexLine!,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 2),
          Text('生成于 ${formatDate(summary.generatedAt)}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const Divider(height: 24),
          _section('疾病史', [
            if (summary.diseases.isEmpty) '（无记录）',
            ...summary.diseases,
          ]),
          _section('当前用药', [
            if (summary.medications.isEmpty) '（无记录）',
            ...summary.medications,
          ]),
          _section('过敏史', [
            if (summary.allergies.isEmpty) '（无记录）',
            ...summary.allergies,
          ]),
          _metricsSection(),
          _reportsSection(),
          const SizedBox(height: 12),
          const Text('本摘要由「健康档案」App 生成，仅供就诊参考，不含医疗诊断。',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> lines) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('· $l',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
            ),
        ],
      ),
    );
  }

  Widget _metricsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('近期异常指标',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          if (summary.abnormalMetrics.isEmpty)
            const Text('· （近期指标均在参考范围内）',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary))
          else
            for (final m in summary.abnormalMetrics)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4),
                    children: [
                      TextSpan(text: '· ${m.name} '),
                      TextSpan(
                          text: '${m.valueText} ',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: '${m.status}${m.trend} ',
                          style:
                              const TextStyle(color: AppColors.abnormal)),
                      TextSpan(
                        text:
                            '${m.referenceText == null ? '' : '（${m.referenceText}）'} '
                            '${formatDate(m.measuredAt)}'
                            '${m.previousText == null ? '' : ' · ${m.previousText}'}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _reportsSection() {
    if (summary.recentReports.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('近期报告',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        for (final r in summary.recentReports)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              '· ${formatDate(r.date)} ${r.hospital} ${r.type}'
              '${r.metricCount > 0 ? '（${r.metricCount} 项）' : ''}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            ),
          ),
      ],
    );
  }
}
