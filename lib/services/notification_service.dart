import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/app_database.dart';
import '../utils/reminder_schedule.dart';

/// B2：本地系统通知（复查提醒一次性、服药提醒每日重复）。
///
/// 与远程 APNs 推送（[PushService]）互补：本地通知离线可用、按设备时区定时；
/// 二者最终都对应 `notifications` 表里的记录。任何一步失败都只 debugPrint，不抛出，
/// 不阻塞 App 启动 / 保存流程。
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _channelId = 'health_reminders';
  static const String _channelName = '健康提醒';
  static const String _channelDesc = '复查提醒与服药提醒';

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        // 取不到设备时区就用默认（UTC），不阻塞。
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(
            android: android, iOS: darwin, macOS: darwin),
      );
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  /// 申请通知权限。返回 true 表示已授权。
  Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        final ok = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return ok ?? false;
      }
      if (Platform.isAndroid) {
        final ok = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return ok ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService.requestPermission failed: $e');
    }
    return false;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  /// 用「所有启用且未完成的提醒」重排本地系统通知：先全部取消，再逐条排程。
  /// 传入的应当是全部档案的可排程提醒（系统通知不区分档案）。
  Future<void> syncAll(List<Reminder> reminders) async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      final now = tz.TZDateTime.now(tz.local);
      for (final r in reminders) {
        if (!r.enabled || r.completedAt != null) continue;
        final ids = notificationIdsForReminder(r);
        if (ids.isEmpty) continue;

        if ((r.kind == 'recheck' || r.kind == 'followup') &&
            r.dueDate != null) {
          final when = tz.TZDateTime(
              tz.local, r.dueDate!.year, r.dueDate!.month, r.dueDate!.day, 9);
          if (when.isAfter(now)) {
            await _plugin.zonedSchedule(
              ids.first,
              r.title,
              (r.detail == null || r.detail!.isEmpty) ? '到复查时间了' : r.detail,
              when,
              _details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        } else if (r.kind == 'medication') {
          final times = parseDailyTimes(r.dailyTimes);
          for (var i = 0; i < times.length && i < ids.length; i++) {
            await _plugin.zonedSchedule(
              ids[i],
              '该服药：${r.title}',
              r.detail,
              _nextInstanceOf(times[i].hour, times[i].minute, now),
              _details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('NotificationService.syncAll failed: $e');
    }
  }

  Future<void> cancelAll() async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAll failed: $e');
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute, tz.TZDateTime now) {
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
