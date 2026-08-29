import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_metadata.dart';
import 'about_page.dart';
import 'family_members_page.dart';
import 'notification_center_page.dart';
import 'privacy_page.dart';
import 'reminders_page.dart';

/// 我的页面：只放**账户与设置**——不随当前健康档案人物变化的东西。
/// 疾病史 / 用药记录 / 给医生看的摘要这些属于「当前人物的健康背景」，已挪到「身体」页；
/// 个人资料编辑并入「家庭成员」（点某个人 → 编辑资料）。
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _memberCount = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = appRepository;
    if (repo == null) return;
    final people = await repo.getAllPersonProfiles();
    if (mounted) setState(() => _memberCount = people.length);
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const _GroupLabel('档案'),
          _SettingTile(
            icon: Icons.people_alt_outlined,
            title: '家庭成员',
            trailing: '$_memberCount 人',
            subtitle: '新增 / 编辑 / 删除档案人物，编辑个人资料也在这里',
            onTap: () => _open(const FamilyMembersPage()),
          ),
          const _GroupLabel('提醒与通知'),
          _SettingTile(
            icon: Icons.alarm_outlined,
            title: '提醒设置',
            subtitle: '复查提醒、服药计划',
            onTap: () => _open(const RemindersPage()),
          ),
          _SettingTile(
            icon: Icons.notifications_none,
            title: '通知',
            subtitle: '已产生的通知记录（与首页铃铛同一处）',
            onTap: () => _open(const NotificationCenterPage()),
          ),
          const _GroupLabel('数据'),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: '数据与隐私',
            subtitle: '备份与恢复、导出全部数据、清除本机数据',
            onTap: () => _open(const PrivacyPage()),
          ),
          const _GroupLabel('关于'),
          _SettingTile(
            icon: Icons.info_outline,
            title: '关于健康档案',
            trailing: 'v${AppMetadata.versionName}',
            onTap: () => _open(const AboutPage()),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
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
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
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
