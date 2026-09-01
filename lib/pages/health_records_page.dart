import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'allergy_page.dart';
import 'condition_page.dart';
import 'medical_summary_page.dart';
import 'medication_page.dart';

/// 「健康资料」：不常看、看医生时才用的东西。从右上角头像菜单进入。
/// UI 与「家庭成员」一致，走 iOS 分组内嵌列表。
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
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              _row(
                icon: CupertinoIcons.checkmark_square,
                title: '慢性病',
                info: _conditions > 0 ? '$_conditions 项' : null,
                onTap: () => _push(const ConditionPage()),
              ),
              _row(
                icon: CupertinoIcons.capsule,
                title: '用药',
                info: _meds > 0 ? '$_meds 条' : null,
                onTap: () => _push(const MedicationPage()),
              ),
              _row(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: '过敏史',
                info: _allergies > 0 ? '$_allergies 条' : null,
                onTap: () => _push(const AllergyPage()),
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            footer: const Text('整理成一页，方便就诊时给医生看。'),
            children: [
              _row(
                icon: CupertinoIcons.doc_text,
                title: '给医生看的摘要',
                info: '导出',
                onTap: () => _push(const MedicalSummaryPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    String? info,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile.notched(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      additionalInfo: info == null ? null : Text(info),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}
