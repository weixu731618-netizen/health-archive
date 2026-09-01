import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/app_metadata.dart';
import '../models/body_area_health.dart';
import '../models/report_models.dart' show kUnlinkedReportType;
import '../utils/file_image.dart';
import '../utils/format.dart';
import '../utils/report_export.dart';
import '../utils/report_image_save.dart';
import '../widgets/current_profile_badge.dart';
import '../widgets/health_status_card.dart';
import '../widgets/normal_items_toggle.dart';
import '../widgets/section_title.dart';
import 'imaging_report_page.dart' show imagingReportTypes;
import 'manual_metric_entry_page.dart';

/// 检查详情页。
/// - 不传 [reportId] → 显示空状态，不注入演示数据。
/// - 报告导入：传 [reportId] → 加载并显示真实报告（信息 / 原始图 / 指标 / 删除）。
class ReportDetailPage extends StatefulWidget {
  final int? reportId;

  const ReportDetailPage({super.key, this.reportId});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  MedicalReport? _report;
  List<HealthMetric> _metrics = [];
  List<String> _organs = const [];
  bool _loading = true;
  String? _error;
  bool _showNormalMetrics = false;

  bool get _isImported => widget.reportId != null;

  @override
  void initState() {
    super.initState();
    if (_isImported) _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    final rid = widget.reportId;
    if (repo == null || rid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final report = await repo.getReportById(rid);
      final metrics = await repo.getMetricsByReport(rid);
      List<String> organs = const [];
      try {
        organs = await repo.getReportOrgans(rid);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _report = report;
          _metrics = metrics;
          _organs = organs;
          _loading = false;
          _error = report == null ? '报告不存在或已删除' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败';
        });
      }
    }
  }

  bool get _isFailed => _report?.recognitionStatus == 'failed';
  bool get _isUnlinked => _report?.reportType == kUnlinkedReportType;

  /// 未关联记录归类：选一个已知类型 → 把 reportType 改过去，变成正式的影像/病历报告。
  Future<void> _reclassifyUnlinked() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('归类为哪一种？',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final t in imagingReportTypes)
              ListTile(title: Text(t), onTap: () => Navigator.pop(context, t)),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    await appRepository!.updateReportInfo(widget.reportId!, reportType: picked);
    await _load();
  }

  /// 「归类里没有合适的」→ 把这份的识别文字 + 原图通过系统分享发给开发者（用户自己），
  /// 由开发者判断要不要新增一类处理。
  Future<void> _sendUnlinkedToDev() async {
    final r = _report;
    if (r == null) return;
    final lines = <String>[
      '【未关联记录 · 待判断是否新增类型】',
      'App 版本：${AppMetadata.versionName}+${AppMetadata.versionCode}',
      '记录时间：${formatDate(r.reportDate)}',
      if (r.hospitalName.trim().isNotEmpty) '医院：${r.hospitalName}',
      '',
      '—— 识别出的文字 ——',
      (r.rawText ?? '').trim().isEmpty ? '（无）' : r.rawText!.trim(),
    ];
    final img = r.sourceImagePath;
    final withImage = img != null &&
        !img.toLowerCase().endsWith('.pdf') &&
        File(img).existsSync();
    await SharePlus.instance.share(ShareParams(
      text: lines.join('\n'),
      files: withImage ? [XFile(img)] : null,
      subject: '健康档案 · 未关联记录反馈',
    ));
  }

  Future<void> _editInfoText(
      String label, String current, Future<void> Function(String) save) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('修改$label'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: '填写$label'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('保存')),
        ],
      ),
    );
    if (result == null) return;
    try {
      await save(result);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
      }
    }
  }

  Future<void> _editDate() async {
    final repo = appRepository;
    final rid = widget.reportId;
    final current = _report?.reportDate;
    if (repo == null || rid == null || current == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null) return;
    try {
      await repo.updateReportDate(rid, picked);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
      }
    }
  }

  Future<void> _addMetricsManually() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManualMetricEntryPage()),
    );
    if (mounted) _load();
  }

  Future<void> _shareReport() async {
    final report = _report;
    if (report == null) return;
    try {
      final shared = await shareReport(report);
      if (!shared && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              const SnackBar(content: Text('该报告没有可导出的原图或文字')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('分享失败，请重试')));
      }
    }
  }

  Future<void> _deleteReport() async {
    final repo = appRepository;
    final rid = widget.reportId;
    if (repo == null || rid == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这份报告？'),
        content: const Text('与该报告关联的检查指标也会一并删除，且无法恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final imagePath = _report?.sourceImagePath;
      await repo.deleteReportCascade(rid);
      // 数据库行删除成功后再清理本地原图文件，避免遗留占用存储空间。
      await deleteManagedReportImage(imagePath);
      // F6：报告可能关联过复查提醒，删除后重排一次，避免提醒悬空。
      try {
        await syncReminders();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('报告已删除')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报告详情'),
        actions: [
          if (_isImported && _report != null)
            IconButton(
              tooltip: '分享 / 导出原件',
              icon: const Icon(Icons.ios_share),
              onPressed: _shareReport,
            ),
        ],
      ),
      body: _isImported ? _buildImported() : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '没有可显示的报告。请从首页「拍报告 / 导入报告」添加。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildImported() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('返回'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _load();
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ],
            ),
          )
        else ...[
          const CurrentProfileBadge(),
          if (_isFailed) ...[
            _FailedNotice(onAddMetrics: _addMetricsManually),
            const SizedBox(height: 12),
          ],
          if (_isUnlinked) ...[
            _UnlinkedNotice(
              onReclassify: _reclassifyUnlinked,
              onSendToDev: _sendUnlinkedToDev,
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    label: '医院',
                    value: (_report?.hospitalName ?? '').trim().isEmpty
                        ? '未填写'
                        : _report!.hospitalName,
                    onTap: () => _editInfoText(
                      '医院',
                      _report?.hospitalName ?? '',
                      (v) => appRepository!
                          .updateReportInfo(widget.reportId!, hospitalName: v),
                    ),
                  ),
                  _InfoRow(
                    label: '检查日期',
                    value: _report == null
                        ? '—'
                        : formatDate(_report!.reportDate),
                    onTap: _report == null ? null : _editDate,
                  ),
                  _InfoRow(
                    label: '类型',
                    value: (_report?.reportType ?? '').trim().isEmpty
                        ? '未填写'
                        : _report!.reportType,
                    onTap: () => _editInfoText(
                      '类型',
                      _report?.reportType ?? '',
                      (v) => appRepository!
                          .updateReportInfo(widget.reportId!, reportType: v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((_report?.rawText ?? '').trim().isNotEmpty) ...[
            const SectionTitle(title: '报告结论'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _report!.rawText!.trim(),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                ),
              ),
            ),
          ],
          // 关联器官：化验单从指标推导，影像 / 图文报告用保存时手选的。
          if (_effectiveAreas.isNotEmpty) ...[
            const SectionTitle(title: '关联器官'),
            _AffectedBodyAreasCard(areas: _effectiveAreas),
          ],
          // 影像/病理等图文报告没有结构化指标，收起「检查指标」区块；
          // 若连结论文字也没有，给一句说明避免页面过空。
          if (_metrics.isNotEmpty) ...[
            const SectionTitle(title: '检查指标'),
            for (final m in _attentionMetrics) ...[
              _ImportedMetricCard(metric: m),
              const SizedBox(height: 12),
            ],
            if (_attentionMetrics.isEmpty)
              for (final m in _normalMetrics) ...[
                _ImportedMetricCard(metric: m),
                const SizedBox(height: 12),
              ]
            else ...[
              NormalItemsToggle(
                expanded: _showNormalMetrics,
                hiddenCount: _normalMetrics.length,
                onTap: () =>
                    setState(() => _showNormalMetrics = !_showNormalMetrics),
              ),
              if (_showNormalMetrics) ...[
                const SizedBox(height: 12),
                for (final m in _normalMetrics) ...[
                  _ImportedMetricCard(metric: m),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ] else if (!_isFailed && (_report?.rawText ?? '').trim().isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('本报告为图文报告，未录入文字内容',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ),
          const SectionTitle(title: '原始报告'),
          _buildOriginalImage(),
          const SizedBox(height: 24),
          // F7：分享入口只保留 AppBar 右上角图标，正文不再重复放按钮。
          // F8：删除是破坏性操作，放最底、用弱化的红色文字按钮，不与其它操作抢视觉。
          Center(
            child: TextButton(
              onPressed: _deleteReport,
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.abnormal),
              child: const Text('删除报告'),
            ),
          ),
        ],
      ],
    );
  }

  bool _needsAttention(HealthMetric m) =>
      isMetricAbnormalStatus(m.status) || isMetricAttentionStatus(m.status);

  /// 异常/需关注的指标：始终展示在前；正常（含未判断）的可折叠。
  List<HealthMetric> get _attentionMetrics {
    final list = _metrics.where(_needsAttention).toList();
    list.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return list;
  }

  List<HealthMetric> get _normalMetrics {
    final list = _metrics.where((m) => !_needsAttention(m)).toList();
    list.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return list;
  }

  /// 关联器官 = 显式关联（影像 / 图文报告手选）∪ 从指标推导（化验单）。
  List<String> get _effectiveAreas {
    final set = <String>{
      ..._organs,
      ...affectedBodyAreasForMetrics(_metrics),
    }..removeWhere((e) => e.trim().isEmpty);
    final list = set.toList()..sort();
    return list;
  }

  Widget _buildOriginalImage() {
    final path = _report?.sourceImagePath;
    if (path == null || path.isEmpty) return _imagePlaceholder();
    if (path.toLowerCase().endsWith('.pdf')) return _pdfOriginalCard();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: buildLocalFileImage(path, height: 220),
    );
  }

  Widget _pdfOriginalCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf_outlined,
            color: AppColors.primary),
        title: const Text('PDF 原件', style: TextStyle(fontSize: 15)),
        subtitle: const Text('用「分享 / 导出原件」发送或保存这份 PDF',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: IconButton(
          icon: const Icon(Icons.ios_share),
          onPressed: _shareReport,
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 36, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text('未保存原始图片',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AffectedBodyAreasCard extends StatelessWidget {
  final List<String> areas;

  const _AffectedBodyAreasCard({required this.areas});

  @override
  Widget build(BuildContext context) {
    final text = areas.isEmpty ? '暂无可追溯的身体部位影响' : areas.join('、');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_tree_outlined,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 报告导入指标卡片
class _ImportedMetricCard extends StatelessWidget {
  final HealthMetric metric;
  const _ImportedMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final hasRange = metric.referenceMin != null && metric.referenceMax != null;
    final rangeText = hasRange
        ? '  ·  参考 ${_fmt(metric.referenceMin!)}–${_fmt(metric.referenceMax!)}'
        : '';
    final sourceFlag = metric.sourceAbnormalFlag == null ||
            metric.sourceAbnormalFlag!.isEmpty
        ? ''
        : '  ·  报告标记 ${metric.sourceAbnormalFlag}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.metricName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_fmt(metric.value)} ${metric.unit}$rangeText$sourceFlag',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _verificationLabel(metric.verificationStatus),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            StatusChip(
              text: metric.status,
              color: valueStatusColor(metric.status),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一行「标签 + 值」信息。传了 [onTap] 时整行可点、右侧显示编辑图标。
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

/// F1：OCR 失败落库的报告在详情页的说明 + 补录入口，避免变成死路。
class _UnlinkedNotice extends StatelessWidget {
  final VoidCallback onReclassify;
  final VoidCallback onSendToDev;
  const _UnlinkedNotice(
      {required this.onReclassify, required this.onSendToDev});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('未关联记录 · 待整理',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          const Text('识别时归不到已知类型，先存了原图和文字。是哪一类可以在这里归类；'
              '如果哪一类都不合适，可以提交给开发者判断要不要新增。',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onReclassify,
                icon: const Icon(Icons.label_outline, size: 18),
                label: const Text('归类'),
              ),
              OutlinedButton.icon(
                onPressed: onSendToDev,
                icon: const Icon(Icons.outgoing_mail, size: 18),
                label: const Text('归类里没有 · 提交给开发者'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FailedNotice extends StatelessWidget {
  final VoidCallback onAddMetrics;
  const _FailedNotice({required this.onAddMetrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('这份报告没能自动识别',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          const Text('原件已存进档案，不会丢失。你可以手动补录其中的指标。',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onAddMetrics,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('补录指标'),
          ),
        ],
      ),
    );
  }
}


String _verificationLabel(String status) {
  switch (status) {
    case 'user_modified':
      return '用户已修改';
    case 'user_confirmed':
      return '用户已确认';
    default:
      return '待核对';
  }
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}
