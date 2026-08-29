import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_database.dart';
import 'data/health_repository.dart';
import 'pages/add_page.dart';
import 'pages/body_page.dart';
import 'pages/home_page.dart';
import 'pages/records_page.dart';
import 'services/cloud_backup_service.dart';
import 'services/identity_service.dart';
import 'services/local_backup_service.dart';
import 'services/notification_service.dart';
import 'services/push_service.dart';
import 'services/report_ocr_service.dart';

/// 全局仓库实例：页面通过它读写本地数据库。
/// 在 main() 里初始化，属于简单依赖注入，不使用状态管理框架。
HealthRepository? appRepository;

/// 全局 OCR 服务（V0.4C-1）：上传图片到自有后端做真实百度 OCR。
/// 后端地址由编译期变量 REPORT_API_BASE 提供；未配置时 isConfigured=false，
/// 前端会提示未配置，不再回退到 Mock 假数据。
ReportOcrService reportOcrService = RemoteOcrService();

/// V0.5：匿名身份服务（首次启动自动创建匿名用户并安全保存 token/恢复码）。
final IdentityService identityService = IdentityService();

/// V0.5：云端备份/恢复客户端（需要自建后端，进阶可选项）。
final CloudBackupService cloudBackupService =
    CloudBackupService(identity: identityService);

/// V0.5.1：本地完整备份（zip 打包 + 系统分享面板），免服务器，推荐默认路径。
final LocalBackupService localBackupService = LocalBackupService();

/// 全局数据库实例（可复用同一连接）
AppDatabase? appDatabase;

/// B1：当前档案 id 的全局通知器。切换家庭成员时更新，`MainShell` 监听它整棵重建，
/// 各页面 initState 重新按新档案加载数据。
final ValueNotifier<int> activeProfileNotifier =
    ValueNotifier<int>(HealthRepository.defaultProfileId);

const String _kActiveProfilePrefKey = 'active_profile_id';

/// B2：提醒有变动后调用——把 notifications 表补齐，并用全部可排程提醒重排系统本地通知。
/// 任何失败都不抛出（[NotificationService] 内部已 try/catch）。
Future<void> syncReminders() async {
  final repo = appRepository;
  if (repo == null) return;
  try {
    await repo.syncNotificationsFromReminders();
  } catch (_) {}
  try {
    await NotificationService.instance
        .syncAll(await repo.getAllSchedulableReminders());
  } catch (_) {}
}

/// 切换当前档案：写仓库 + 持久化 + 通知 UI 重建。
Future<void> switchActiveProfile(int id) async {
  final repo = appRepository;
  if (repo == null) return;
  final applied = await repo.setActiveProfileId(id);
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kActiveProfilePrefKey, applied);
  } catch (_) {
    // 持久化失败不影响本次会话切换
  }
  activeProfileNotifier.value = applied;
}

/// 全局颜色定义（整个 App 统一使用）
abstract final class AppColors {
  /// 主色调：柔和医疗蓝绿
  static const Color primary = Color(0xFF00796B);

  /// 页面背景：浅灰白
  static const Color background = Color(0xFFF6F7F9);

  static const Color textPrimary = Color(0xFF1C2733);
  static const Color textSecondary = Color(0xFF6B7785);

  /// 状态色：正常 / 需要关注 / 异常 / 数据不足
  /// 注意：颜色永远不是唯一表达方式，界面上同时显示状态文字。
  static const Color normal = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
  static const Color abnormal = Color(0xFFC62828);
  static const Color insufficient = Color(0xFF757575);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化本地数据库与仓库（跨端：Android / iOS / Web）。
  // 使用 try/catch：若当前平台无法打开数据库（例如某些 Web 非 wasm 环境），
  // 也不阻塞 UI 启动，页面仍用假数据展示；appRepository 保持为空。
  try {
    final db = AppDatabase();
    appDatabase = db;
    appRepository = HealthRepository(db);
    // 执行一次真实查询，强制触发 drift 惰性连接；若打开失败则进入 catch，
    // 使 appRepository 保持为 null，页面显示「数据库未就绪」而不是崩溃。
    await db.customSelect('SELECT 1').get();
    await appRepository!.ensureDefaultPersonProfile();
    // B1：恢复上次选中的档案（校验仍存在，否则回落到「本人」）。
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_kActiveProfilePrefKey);
      if (saved != null) {
        final applied = await appRepository!.setActiveProfileId(saved);
        activeProfileNotifier.value = applied;
      }
    } catch (_) {
      // 读取失败就用默认「本人」
    }
  } catch (e, st) {
    debugPrint('AppDatabase init failed: $e\n$st');
    appDatabase = null;
    appRepository = null;
  }
  // B2：本地系统通知 + 远程推送骨架。都不阻塞启动（内部 try/catch）。
  unawaited(NotificationService.instance.init());
  unawaited(PushService.instance.init());
  unawaited(syncReminders());
  // V0.5 云端备份/匿名账号在 v1 精简版暂不启用（UI 入口已隐藏，见 profile_page.dart），
  // 故这里不再启动时自动调用 /api/anonymous/register：
  // 1) 避免每次启动都打一个后端根本没挂载对应路由（v1 后端只保留 OCR 接口）的请求；
  // 2) identityService 本身仍保留、未删除，v2 重新启用云备份时把这行加回来即可。
  // unawaited(identityService.ensureIdentity().then((_) {}, onError: (_) {}));
  runApp(const HealthArchiveApp());
}

class HealthArchiveApp extends StatefulWidget {
  const HealthArchiveApp({super.key});

  @override
  State<HealthArchiveApp> createState() => _HealthArchiveAppState();
}

class _HealthArchiveAppState extends State<HealthArchiveApp>
    with WidgetsBindingObserver {
  // App 切到后台/多任务切换的瞬间，系统会给当前画面拍一张快照用作缩略图；
  // 这里在非 resumed 状态时盖一层遮罩，避免快照里带出健康数据。
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final obscured = state != AppLifecycleState.resumed;
    if (obscured != _obscured) setState(() => _obscured = obscured);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康档案',
      debugShowCheckedModeBanner: false,
      // 中文界面：让系统自带组件（如日期、提示）也显示中文
      locale: const Locale('zh'),
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(),
      home: const MainShell(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_obscured) const _PrivacyCover(),
          ],
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE6EAED)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        height: 68,
      ),
    );
  }
}

/// 后台/多任务切换时盖住内容的遮罩，防止系统截图带出健康数据。
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Material(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety,
                  size: 56, color: AppColors.primary),
              SizedBox(height: 12),
              Text(
                '健康档案',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// App 主框架：底部三个 Tab（首页 / 身体 / 记录）。
/// 「我的 / 个人中心」不再占一级导航，收进每页右上角的头像入口（见 [ProfileSwitcher]）。
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// 每次切换 Tab 都重新构建对应页面，确保「记录」「身体」等页能加载到最新保存的数据。
  /// 「添加」不是底部 Tab，改为悬浮按钮，见 [build] 里的 floatingActionButton。
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const BodyPage();
      case 2:
        return const RecordsPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // B1：切换家庭成员时，用新的 key 重建当前 Tab 页，触发其 initState 按新档案重新加载。
      body: ValueListenableBuilder<int>(
        valueListenable: activeProfileNotifier,
        builder: (context, profileId, _) => KeyedSubtree(
          key: ValueKey('tab-$_index-profile-$profileId'),
          child: _buildPage(_index),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: '添加健康数据',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddPage()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.accessibility_new),
            label: '身体',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '记录',
          ),
        ],
      ),
    );
  }
}
