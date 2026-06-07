import '../../../core/contracts/i_notification_service.dart';
import '../../../core/contracts/i_task_repository.dart';
import '../../../core/models/notification_request.dart';
import 'reminder_scheduler.dart';

/// Schedules a one-off snooze notification for [taskId] after [delay].
class SnoozeReminderUseCase {
  const SnoozeReminderUseCase(this._tasks, this._notif);

  final ITaskRepository _tasks;
  final INotificationService _notif;

  Future<void> call(String taskId, Duration delay) async {
    final found = await _tasks.findById(taskId);
    final task = found.valueOrNull;
    if (task == null) return;

    final when = DateTime.now().toUtc().add(delay);
    await _notif.schedule(
      NotificationRequest(
        id: stableId('snooze-$taskId'),
        taskId: taskId,
        title: task.title,
        body: 'Snoozed reminder',
        scheduledAt: when,
      ),
    );
  }
}
