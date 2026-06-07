import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/notification_action.dart';
import '../domain/notification_action_type.dart';
import 'snooze_reminder_usecase.dart';

/// Handles notification action taps by delegating to task use cases / router.
class NotificationActionHandler {
  NotificationActionHandler({
    required this.completeTask,
    required this.snooze,
    required this.router,
  });

  final Future<void> Function(String taskId) completeTask;
  final SnoozeReminderUseCase snooze;
  final GoRouter router;

  Future<void> handle(String taskId, NotificationActionType type) async {
    switch (type) {
      case NotificationActionType.markDone:
        await completeTask(taskId);
      case NotificationActionType.snooze:
        await snooze.call(taskId, const Duration(minutes: 15));
      case NotificationActionType.open:
        router.go('/task/$taskId');
    }
  }

  Future<void> handleAction(NotificationAction action) async {
    final type = parseNotificationActionType(action.actionId);
    if (type == null) return;
    await handle(action.taskId, type);
  }
}

/// Provides the application [GoRouter] for notification deep links.
final routerProvider = Provider<GoRouter>((ref) {
  throw UnimplementedError('Override routerProvider in app bootstrap.');
});
