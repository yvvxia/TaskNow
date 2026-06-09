import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/contracts/i_notification_service.dart';
import '../../core/models/notification_action.dart';
import '../../core/models/notification_request.dart';
import '../../features/notification/domain/notification_action_type.dart';

/// Android / iOS / Windows local notification implementation.
class FlutterLocalNotificationService implements INotificationService {
  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _actionController = StreamController<NotificationAction>.broadcast();
  bool _initialized = false;
  bool _exactAlarmsAllowed = true;

  static const _channelId = 'plan_list_reminders';
  static const _channelName = 'Task Reminders';

  @override
  Stream<NotificationAction> get onAction => _actionController.stream;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const windows = WindowsInitializationSettings(
      appName: 'PlanList',
      appUserModelId: 'com.planlist.app',
      guid: 'PlanList-Notification-GUID',
    );
    const initSettings = InitializationSettings(
      android: android,
      windows: windows,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    // Handle the case where the app was launched by tapping a notification
    // while terminated. Referencing this method is also required to avoid an
    // AOT tree-shaking crash in flutter_local_notifications_windows on
    // `flutter build windows --release` (see MaikuB/flutter_local_notifications#2615).
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails!.notificationResponse;
      if (response != null) {
        _onResponse(response);
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      _exactAlarmsAllowed =
          await androidPlugin?.requestExactAlarmsPermission() ?? false;
    }

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static void _onBackgroundResponse(NotificationResponse response) {
    // Background isolate cannot emit to stream; foreground init handles taps.
  }

  void _onResponse(NotificationResponse response) {
    final taskId = response.payload;
    if (taskId == null || taskId.isEmpty) return;

    final actionId = response.actionId ?? 'open';
    if (!_actionController.isClosed) {
      _actionController.add(
        NotificationAction(taskId: taskId, actionId: actionId),
      );
    }
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission() ?? false;
      _exactAlarmsAllowed =
          await android?.requestExactAlarmsPermission() ?? false;
      return granted;
    }

    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    // Windows / desktop: assume available when plugin initializes.
    return true;
  }

  @override
  Future<void> schedule(NotificationRequest request) async {
    await init();

    final scheduled = tz.TZDateTime.from(request.scheduledAt.toUtc(), tz.UTC);
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      actions: const [
        AndroidNotificationAction('markDone', 'Mark done'),
        AndroidNotificationAction('snooze', 'Snooze 15m'),
      ],
    );
    const windowsDetails = WindowsNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      windows: windowsDetails,
    );

    AndroidScheduleMode mode = AndroidScheduleMode.exactAllowWhileIdle;
    if (!_exactAlarmsAllowed) {
      mode = AndroidScheduleMode.inexactAllowWhileIdle;
    }

    await _plugin.zonedSchedule(
      id: request.id,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: mode,
      payload: request.taskId,
      title: request.title,
      body: request.body,
    );
  }

  @override
  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<void> cancelForTask(String taskId) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.payload == taskId) {
        await _plugin.cancel(id: p.id);
      }
    }
  }

  @override
  Future<List<int>> pending() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).toList();
  }

  Future<void> dispose() async {
    await _actionController.close();
  }
}

/// Maps a [NotificationAction] to [NotificationActionType] if recognized.
NotificationActionType? actionTypeFrom(NotificationAction action) =>
    parseNotificationActionType(action.actionId);
