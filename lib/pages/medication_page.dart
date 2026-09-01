import 'package:drift/drift.dart' as drift;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../main.dart';
import '../widgets/health_ui.dart';
import '../widgets/ios_button.dart';
import '../services/notification_service.dart';
import '../utils/format.dart';
import '../utils/reminder_schedule.dart';

/// 用药记录页（MVP）：真实可增删改存。
class MedicationPage extends StatefulWidget {
  /// 从「添加」菜单点「用药」进来时为 true：不停在列表页，直接弹「新增用药」表单，
  /// 免得用户已经选过一次「用药」还要再点右下角「+」。
  final bool startAdding;

  const MedicationPage({super.key, this.startAdding = false});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<Medication> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.startAdding) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _addOrEdit());
    }
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final repo = appRepository;
    if (repo != null) {
      final list = await repo.getAllMedications();
      if (mounted) {
        setState(() {
          _items = list;
          _loading = false;
        });
      }
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addOrEdit([Medication? existing]) async {
    final r = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => _MedicationEditPage(medication: existing)),
    );
    if (r == true) _load();
  }

  Future<void> _delete(Medication m) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('删除这条用药记录？'),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = appRepository;
    if (repo != null) {
      await repo.deleteMedication(m.id);
      await repo.deleteMedicationReminder(m.id);
      await syncReminders();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用药记录'),
        actions: [
          IconButton(
            tooltip: '新增',
            icon: const Icon(CupertinoIcons.add),
            onPressed: () => _addOrEdit(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('暂无用药记录，点右上角 + 添加',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  children: [
                    for (final m in _items) ...[
                      _medCard(m),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
    );
  }

  Widget _medCard(Medication m) {
    final detail = [
      if (m.dosage != null)
        '${m.dosage}${m.dosageUnit ?? ''}'
      else if (m.dosageUnit != null)
        m.dosageUnit!,
      if ((m.usage ?? '').isNotEmpty) m.usage!,
      if (m.timesPerDay != null) '每日 ${m.timesPerDay ?? ''} 次',
      if (m.startDate != null) '起 ${formatDate(m.startDate!)}',
      if (m.endDate != null) '止 ${formatDate(m.endDate!)}',
    ].join(' · ');
    return HealthCard(
      onTap: () => _addOrEdit(m),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          const Icon(CupertinoIcons.capsule,
              size: 22, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${m.status}${detail.isEmpty ? '' : ' · $detail'}'
                  '${(m.notes ?? '').isEmpty ? '' : ' · ${m.notes}'}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(0, 0),
            onPressed: () => _delete(m),
            child: const Icon(CupertinoIcons.delete,
                size: 20, color: AppColors.abnormal),
          ),
        ],
      ),
    );
  }
}

class _MedicationEditPage extends StatefulWidget {
  final Medication? medication;
  const _MedicationEditPage({this.medication});

  @override
  State<_MedicationEditPage> createState() => _MedicationEditPageState();
}

class _MedicationEditPageState extends State<_MedicationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _usageCtrl;
  late final TextEditingController _timesCtrl;
  late final TextEditingController _notesCtrl;
  late String _status = '当前使用';
  DateTime? _start;
  DateTime? _end;
  String? _conditionCode;

  // B2：服药提醒
  bool _remindEnabled = false;
  List<String> _remindTimes = const [];

  bool get _isEdit => widget.medication != null;

  static const List<String> _options = ['当前使用', '已停用'];

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _dosageCtrl = TextEditingController(text: m?.dosage ?? '');
    _unitCtrl = TextEditingController(text: m?.dosageUnit ?? '');
    _usageCtrl = TextEditingController(text: m?.usage ?? '');
    _timesCtrl = TextEditingController(text: m?.timesPerDay ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _status = m?.status ?? '当前使用';
    _start = m?.startDate;
    _end = m?.endDate;
    _conditionCode = m?.conditionCode;
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final m = widget.medication;
    final repo = appRepository;
    if (m == null || repo == null) return;
    final existing = await repo.getMedicationReminder(m.id);
    if (existing != null && mounted) {
      setState(() {
        _remindEnabled = existing.enabled;
        _remindTimes = parseDailyTimes(existing.dailyTimes)
            .map((t) => t.text)
            .toList();
      });
    }
  }

  void _ensureTimes() {
    if (_remindTimes.isEmpty) {
      _remindTimes =
          defaultMedicationTimes(timesPerDayCount(_timesCtrl.text.trim()));
    }
  }

  Future<void> _editTime(int index) async {
    final parts = _remindTimes[index].split(':');
    final now = DateTime.now();
    final picked = await pickCupertinoDate(
      context,
      initial: DateTime(now.year, now.month, now.day,
          int.tryParse(parts[0]) ?? 9,
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0),
      mode: CupertinoDatePickerMode.time,
    );
    if (picked == null) return;
    setState(() {
      _remindTimes[index] =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _remindTimes = parseDailyTimes(_remindTimes.join(','))
          .map((t) => t.text)
          .toList();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _dosageCtrl,
      _unitCtrl,
      _usageCtrl,
      _timesCtrl,
      _notesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final repo = appRepository;
    if (repo == null) return;
    if (_isEdit) {
      final m = widget.medication!;
      final updated = m.copyWith(
        name: name,
        dosage: drift.Value(
            _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim()),
        dosageUnit: drift.Value(
            _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim()),
        usage: drift.Value(
            _usageCtrl.text.trim().isEmpty ? null : _usageCtrl.text.trim()),
        timesPerDay: drift.Value(
            _timesCtrl.text.trim().isEmpty ? null : _timesCtrl.text.trim()),
        startDate: drift.Value(_start),
        endDate: drift.Value(_end),
        status: _status,
        notes: drift.Value(
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        conditionCode: drift.Value(_conditionCode),
      );
      await repo.updateMedication(updated);
    } else {
      final newId = await repo.insertMedication(
        name: name,
        dosage:
            _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        dosageUnit:
            _unitCtrl.text.trim().isEmpty ? null : _unitCtrl.text.trim(),
        usage: _usageCtrl.text.trim().isEmpty ? null : _usageCtrl.text.trim(),
        timesPerDay:
            _timesCtrl.text.trim().isEmpty ? null : _timesCtrl.text.trim(),
        startDate: _start,
        endDate: _end,
        status: _status,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        conditionCode: _conditionCode,
      );
      _savedMedicationId = newId;
    }

    // B2：同步服药提醒
    final medId = _isEdit ? widget.medication!.id : _savedMedicationId;
    if (medId != null) {
      if (_remindEnabled) {
        _ensureTimes();
        await NotificationService.instance.requestPermission();
      }
      final dose = [
        if (_dosageCtrl.text.trim().isNotEmpty)
          '${_dosageCtrl.text.trim()}${_unitCtrl.text.trim()}',
      ].join();
      await repo.setMedicationReminder(
        medicationId: medId,
        profileId: repo.activeProfileId,
        medName: name,
        times: _remindEnabled ? _remindTimes : const [],
        enabled: _remindEnabled,
        detail: dose.isEmpty ? null : '每次 $dose',
      );
      await syncReminders();
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  int? _savedMedicationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑用药' : '新增用药')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            HealthCard(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                children: [
                  HealthFieldRow(
                    label: '药物名称',
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration: _input('必填'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入药物名称' : null,
                    ),
                  ),
                  HealthFieldRow(
                    label: '剂量',
                    child: Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _dosageCtrl,
                              decoration: _input('数值'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextFormField(
                              controller: _unitCtrl, decoration: _input('单位'))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextFormField(
                              controller: _timesCtrl,
                              decoration: _input('每日次数'))),
                    ]),
                  ),
                  HealthFieldRow(
                    label: '用法',
                    child: TextFormField(
                      controller: _usageCtrl,
                      decoration: _input('口服 / 饭前 / 饭后…（选填）'),
                    ),
                  ),
                  HealthFieldRow(
                    label: '开始日期',
                    onTap: () => _pickDate(true),
                    child: _rowValue(
                        _start == null ? '未填' : formatDate(_start!)),
                  ),
                  HealthFieldRow(
                    label: '结束日期',
                    onTap: () => _pickDate(false),
                    child: _rowValue(_end == null ? '未填' : formatDate(_end!)),
                  ),
                  HealthFieldRow(
                    label: '备注',
                    child: TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: _input('选填'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _MiniLabel('用药状态'),
            ChoicePills(
              options: _options,
              value: _status,
              toggle: false,
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 14),
            HealthCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('服药提醒',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('到点发系统通知提醒吃这个药',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: _remindEnabled,
                        onChanged: (v) => setState(() {
                          _remindEnabled = v;
                          if (v) _ensureTimes();
                        }),
                      ),
                    ],
                  ),
                  if (_remindEnabled) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _remindTimes.length; i++)
                            ChoicePill(
                              label: _remindTimes[i],
                              selected: true,
                              onTap: () => _editTime(i),
                            ),
                          ChoicePill(
                            label: '＋ 加时间',
                            selected: false,
                            onTap: () => setState(() {
                              _remindTimes = parseDailyTimes(
                                      [..._remindTimes, '12:00'].join(','))
                                  .map((t) => t.text)
                                  .toList();
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            IosButton.filled('保存', onPressed: _save, expand: true),
          ],
        ),
      ),
    );
  }

  Widget _rowValue(String v) => Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(v,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_forward,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      );

  Future<void> _pickDate(bool isStart) async {
    FocusScope.of(context).unfocus();
    final p = await pickCupertinoDate(context, initial: (isStart ? _start : (_end ?? _start)) ?? DateTime.now(), minimumDate: DateTime(1990), maximumDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (p != null) setState(() => isStart ? _start = p : _end = p);
  }

  InputDecoration _input(String hint) => InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 15, color: AppColors.textSecondary),
      );
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      );
}
