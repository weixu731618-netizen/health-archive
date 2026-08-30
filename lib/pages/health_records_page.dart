import 'package:flutter/material.dart';

import '../main.dart';
import 'allergy_page.dart';
import 'condition_page.dart';
import 'medical_summary_page.dart';
import 'medication_page.dart';

/// 「健康资料」：不常看、看医生时才用的东西。从右上角头像菜单进入。
class HealthRecordsPage extends StatefulWidget {
  const HealthRecordsPage({super.key});

  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  int _conditions = 0;
  int _meds = 0;
  int _allergies = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    final c = await repo.getAllDiseases();
    final m = await repo.getAllMedications();
    final a = await repo.getAllAllergies();
    if (mounted) {
      setState(() {
        _conditions = c.length;
        _meds = m.length;
        _allergies = a.length;
      });
    }
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健康资料')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Tile(
            icon: Icons.checklist_rtl_outlined,
            title: '慢性病',
            trailing: _conditions > 0 ? '$_conditions 项' : null,
            onTap: () => _push(const ConditionPage()),
          ),
          _Tile(
            icon: Icons.medication_outlined,
            title: '用药',
            trailing: _meds > 0 ? '$_meds 条' : null,
            onTap: () => _push(const MedicationPage()),
          ),
          _Tile(
            icon: Icons.warning_amber_outlined,
            title: '过敏史',
            trailing: _allergies > 0 ? '$_allergies 条' : null,
            onTap: () => _push(const AllergyPage()),
          ),
          _Tile(
            icon: Icons.description_outlined,
            title: '给医生看的摘要',
            trailing: '导出',
            onTap: () => _push(const MedicalSummaryPage()),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
