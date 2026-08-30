import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
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
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加其他疾病'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '疾病名称'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
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

    return Scaffold(
      appBar: AppBar(title: const Text('慢性病')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    '勾选你或家人确诊的慢性病。勾上之后，提醒页会按这个病自动安排复查。',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < defs.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        CheckboxListTile(
                          value: _rowFor(defs[i].code) != null,
                          onChanged: _busy
                              ? null
                              : (v) => _toggle(defs[i], v ?? false),
                          title: Text(defs[i].name,
                              style: const TextStyle(fontSize: 15)),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('其他疾病',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addOther,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                if (others.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('清单里没有的病可以在这里补',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  )
                else
                  for (final d in others)
                    Card(
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title:
                            Text(d.name, style: const TextStyle(fontSize: 15)),
                        subtitle: d.foundDate == null
                            ? null
                            : Text('发现于 ${formatDate(d.foundDate!)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.abnormal),
                          onPressed: () => _removeOther(d),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
