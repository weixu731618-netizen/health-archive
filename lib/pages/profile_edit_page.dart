import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/format.dart';

/// 个人资料编辑页（MVP：昵称/性别/出生日期/身高）。
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nickCtrl;
  late final TextEditingController _heightCtrl;
  late String _gender = '';
  DateTime? _birth;

  static const List<String> _genders = ['男', '女', '其他'];

  @override
  void initState() {
    super.initState();
    _nickCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    final p = await repo.getProfile();
    if (p == null || !mounted) return;
    setState(() {
      _nickCtrl.text = p.nickname;
      _gender = p.gender;
      _birth = p.birthDate;
      _heightCtrl.text = p.heightCm == null ? '' : _fmt(p.heightCm!);
    });
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nickCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = appRepository;
    if (repo == null) return;
    await repo.upsertProfile(
      nickname: _nickCtrl.text.trim(),
      gender: _gender,
      birthDate: _birth,
      heightCm: double.tryParse(_heightCtrl.text.trim()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已保存')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextFormField(
            controller: _nickCtrl,
            decoration: _input('昵称'),
          ),
          const SizedBox(height: 12),
          const Text('性别',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final g in _genders)
                ChoiceChip(
                  label: Text(g),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.cake_outlined, color: AppColors.textSecondary),
            title: const Text('出生日期'),
            trailing: Text(_birth == null ? '未填' : formatDate(_birth!),
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textPrimary)),
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: _birth ?? DateTime(1990),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (p != null) setState(() => _birth = p);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _heightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '身高（cm）',
              suffixText: 'cm',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('保存', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
