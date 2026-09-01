import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/health_ui.dart';
import 'allergy_page.dart';
import 'condition_page.dart';
import 'medical_summary_page.dart';
import 'medication_page.dart';

/// 「健康资料」：不常看、看医生时才用的东西。从右上角头像菜单进入。
/// 现代 iOS（Health / Fitness 风）：独立卡片，大留白，不做 inset 列表。
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _CategoryCard(
            icon: CupertinoIcons.checkmark_seal,
            title: '慢性病',
            count: _conditions,
            unit: '项',
            onTap: () => _push(const ConditionPage()),
          ),
          const SizedBox(height: 12),
          _CategoryCard(
            icon: CupertinoIcons.capsule,
            title: '用药',
            count: _meds,
            unit: '条',
            onTap: () => _push(const MedicationPage()),
          ),
          const SizedBox(height: 12),
          _CategoryCard(
            icon: CupertinoIcons.exclamationmark_triangle,
            title: '过敏史',
            count: _allergies,
            unit: '条',
            onTap: () => _push(const AllergyPage()),
          ),
          const HealthSectionHeader('就诊'),
          _CategoryCard(
            icon: CupertinoIcons.doc_plaintext,
            title: '给医生看的摘要',
            subtitle: '整理成一页，方便就诊时给医生看',
            onTap: () => _push(const MedicalSummaryPage()),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int? count;
  final String? unit;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.count,
    this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 23, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 10),
            Text('$count',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }
}
