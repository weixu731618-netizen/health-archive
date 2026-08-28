import 'package:flutter/material.dart';

import '../main.dart';
import 'about_page.dart';
import 'condition_page.dart';
import 'medication_page.dart';
import 'privacy_page.dart';
import 'profile_edit_page.dart';

/// 我的页面：个人资料卡 + 设置列表
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '徐先生';
  String _gender = '';
  double? _heightCm;
  int _diseaseCount = 0;
  int _medicationCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    final profile = await repo.getProfile();
    final diseases = await repo.getAllDiseases();
    final meds = await repo.getAllMedications();
    if (mounted) {
      setState(() {
        if (profile != null) {
          _nickname = profile.nickname.isEmpty ? '未设置昵称' : profile.nickname;
          _gender = profile.gender;
          _heightCm = profile.heightCm;
        }
        _diseaseCount = diseases.length;
        _medicationCount = meds.length;
      });
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        // 底部多留一点空间，避免最后一项被悬浮的"添加"按钮挡住。
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        children: [
          // 个人资料卡
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _nickname.isNotEmpty ? _nickname.substring(0, 1) : '徐',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _gender.isEmpty ? '请补全个人资料' : '性别：$_gender',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _heightCm == null
                              ? '去「个人资料」补全身高等'
                              : '身高 ${_fmtHeight(_heightCm!)} cm',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _open(const ProfileEditPage()),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SettingTile(
            title: '个人资料',
            onTap: () => _open(const ProfileEditPage()),
          ),
          _SettingTile(
            title: '疾病史',
            trailing: _diseaseCount > 0 ? '$_diseaseCount条' : null,
            onTap: () => _open(const ConditionPage()),
          ),
          _SettingTile(
            title: '用药记录',
            trailing: _medicationCount > 0 ? '$_medicationCount条' : null,
            onTap: () => _open(const MedicationPage()),
          ),
          _SettingTile(
            title: '数据与隐私',
            onTap: () => _open(const PrivacyPage()),
          ),
          _SettingTile(
            title: '关于健康档案',
            onTap: () => _open(const AboutPage()),
          ),
        ],
      ),
    );
  }

  static String _fmtHeight(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
