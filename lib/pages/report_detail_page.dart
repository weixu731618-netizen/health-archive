import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../models/body_area_health.dart';
import '../utils/file_image.dart';
import '../utils/format.dart';
import '../utils/report_image_save.dart';
import '../widgets/health_status_card.dart';
import '../widgets/normal_items_toggle.dart';
import '../widgets/section_title.dart';

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
      if (mounted) {
        setState(() {
          _report = report;
          _metrics = metrics;
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

  Future<void> _deleteReport() async {
    final repo = appRepository;
    final rid = widget.reportId;
    if (repo == null || rid == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除报告后，与该报告关联的检查指标也将删除。是否继续？'),
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
      appBar: AppBar(title: const Text('报告详情')),
      body: _isImported ? _buildImported() : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '没有可显示的报告。请从「添加」页导入真实报告。',
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
            child: Center(
                child: Text(_error!,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary))),
          )
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: '医院', value: _report?.hospitalName ?? '—'),
                  _InfoRow(
                      label: '检查日期',
                      value: _report == null
                          ? '—'
                          : formatDate(_report!.reportDate)),
                  _InfoRow(label: '类型', value: _report?.reportType ?? '—'),
                ],
              ),
            ),
          ),
          const SectionTitle(title: '影响部位'),
          _AffectedBodyAreasCard(areas: affectedBodyAreasForMetrics(_metrics)),
          const SectionTitle(title: '检查指标'),
          if (_metrics.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('该报告未关联任何指标',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            )
          else ...[
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
          ],
          const SectionTitle(title: '原始报告'),
          _buildOriginalImage(),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _deleteReport,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.abnormal,
            ),
            child: const Text('删除报告', style: TextStyle(fontSize: 16)),
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

  Widget _buildOriginalImage() {
    final path = _report?.sourceImagePath;
    if (path != null && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: buildLocalFileImage(path, height: 220),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
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

/// 一行「标签 + 值」信息
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
