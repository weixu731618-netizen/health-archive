import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_database.dart';
import 'data/health_repository.dart';
import 'pages/add_page.dart';
import 'pages/body_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/records_page.dart';
import 'services/report_ocr_service.dart';
import 'services/report_recognition_service.dart';

/// 全局仓库实例：页面通过它读写本地数据库。
/// 在 main() 里初始化，属于简单依赖注入，不使用状态管理框架。
HealthRepository? appRepository;

/// 全局报告识别服务。
/// 默认使用 Mock（跑通全流程、无真实网络）。
/// Debug 阶段可用 `flutter run --dart-define=REPORT_AI=remote` 切换 Remote（需后端接入后）；
/// 普通用户构建不含此开关，也不会看到任何开发选项。
ReportRecognitionService reportRecognitionService =
    _buildRecognitionService();

ReportRecognitionService _buildRecognitionService() {
  const mode = String.fromEnvironment('REPORT_AI');
  if (mode == 'remote' && !kReleaseMode) {
    return RemoteReportRecognitionService();
  }
  return MockReportRecognitionService();
}

/// 全局 OCR 服务（V0.4C-1）：上传图片到自有后端做真实百度 OCR。
/// 后端地址由编译期变量 REPORT_API_BASE 提供；未配置时 isConfigured=false，
/// 前端会回退到 Mock 结构化流程。
ReportOcrService reportOcrService = RemoteOcrService();

/// 全局数据库实例（可复用同一连接）
AppDatabase? appDatabase;

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
  } catch (_) {
    appDatabase = null;
    appRepository = null;
  }
  runApp(const HealthArchiveApp());
}

class HealthArchiveApp extends StatelessWidget {
  const HealthArchiveApp({super.key});

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

/// App 主框架：底部固定 5 个 Tab
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// 每次切换 Tab 都重新构建对应页面，确保「记录」「身体」等页能加载到最新保存的数据。
  /// 保留 5 个底部 Tab 与各处导航逻辑不变。
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const BodyPage();
      case 2:
        return const RecordsPage();
      case 3:
        return const AddPage();
      case 4:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_index),
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
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: '添加',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
