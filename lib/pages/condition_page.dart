import 'package:flutter/cupertino.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/ios_nav.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_tap.dart';
import '../models/chronic_condition_dictionary.dart';
import '../utils/format.dart';

/// 「慢性病」页：勾选式登记，不填表单。
///
/// 勾一个病 → 写入一条疾病史（带 conditionCode），提醒页会自动排它的随访。
/// 取消勾选 → 删掉那条记录。字典外的病用「其他」自由文本补。
class ConditionPage extends StatefulWidget {
  const ConditionPage({super.key});

  @override
  State<ConditionPage> createState() => _ConditionPageState();
}

/// 勾选清单里列出的常见慢性病（按用途挑选，不是全字典）。
const List<String> _checklistCodes = [
  'hypertension',
  'type2_diabetes',
  'type1_diabetes',
  'dyslipidemia',
  'hyperuricemia',
  'gout',
  'nafld',
  'ckd',
  'chd',
  'stroke',
  'atrial_fibrillation',
  'heart_failure',
  'copd',
  'osteoporosis',
  'hypothyroidism',
  'hyperthyroidism',
  'thyroid_nodule',
  'chronic_hepatitis_b',
];

class _ConditionPageState extends State<ConditionPage> {
  List<Disease> _diseases = [];
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
      if (mounted) setState(() => _loading = false);
      return;
    }
    final list = await repo.getAllDiseases();
    if (mounted) {
      setState(() {
        _diseases = list;
        _loading = false;
      });
    }
  }

  Disease? _rowFor(String code) {
    for (final d in _diseases) {
      if (d.conditionCode == code) return d;
    }
    return null;
  }

  Future<void> _toggle(ChronicConditionDef def, bool on) async {
    final repo = appRepository;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    try {
      if (on) {
        await repo.insertDisease(
          name: def.name,
          conditionCode: def.code,
          status: '当前存在',
        );
      } else {
        final row = _rowFor(def.code);
        if (row != null) await repo.deleteDisease(row.id);
      }
      // 随访提醒按最新的慢病清单重排。
      await syncReminders();
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addOther() async {
    final ctrl = TextEditingController();
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('添加其他疾病'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: ctrl,
            autofocus: true,
            placeholder: '疾病名称',
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
        ),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('添加')),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty) return;
    await appRepository?.insertDisease(name: name, status: '当前存在');
    _load();
  }

  Future<void> _removeOther(Disease d) async {
    await appRepository?.deleteDisease(d.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final defs = [
      for (final c in _checklistCodes)
        if (findChronicCondition(c) case final d?) d,
    ];
    final others =
        _diseases.where((d) => (d.conditionCode ?? '').isEmpty).toList();

    return IosLargeTitleScaffold(
      title: '慢性病',
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: _loading
          ? const [
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CupertinoActivityIndicator()),
              )
            ]
          : [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    '勾选你或家人确诊的慢性病。勾上之后，提醒页会按这个病自动安排复查。',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                HealthCard(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                  child: Column(
                    children: [
                      for (final def in defs)
                        _CheckRow(
                          label: def.name,
                          checked: _rowFor(def.code) != null,
                          onTap: _busy
                              ? null
                              : () => _toggle(
                                  def, _rowFor(def.code) == null),
                        ),
                    ],
                  ),
                ),
                HealthSectionHeader('其他疾病',
                    actionLabel: '添加', onAction: _addOther),
                if (others.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('清单里没有的病可以在这里补',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  )
                else
                  HealthCard(
                    padding: const EdgeInsets.fromLTRB(18, 4, 8, 4),
                    child: Column(
                      children: [
                        for (final d in others)
                          HealthRow(
                            title: d.name,
                            subtitle: d.foundDate == null
                                ? null
                                : '发现于 ${formatDate(d.foundDate!)}',
                            trailing: CupertinoButton(
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(0, 0),
                              onPressed: () => _removeOther(d),
                              child: const Icon(CupertinoIcons.delete,
                                  size: 20, color: AppColors.abnormal),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
    );
  }
}

/// Health 风的勾选行：左侧圆圈勾，右侧无 chevron，整行可点。
class _CheckRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback? onTap;
  const _CheckRow({required this.label, required this.checked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IosTap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(
              checked
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 22,
              color: checked ? AppColors.primary : AppColors.insufficient,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
