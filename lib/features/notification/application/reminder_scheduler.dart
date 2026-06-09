import 'package:intl/intl.dart';

import '../../../core/contracts/i_notification_service.dart';
import '../../../core/contracts/i_project_repository.dart';
import '../../../core/contracts/i_reminder_repository.dart';
import '../../../core/contracts/i_settings_store.dart';
import '../../../core/contracts/i_task_repository.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/notification_request.dart';
import '../../../core/models/reminder.dart';
import '../../../core/models/task.dart';
import '../../../core/utils/result.dart';
import '../domain/notification_settings.dart';
import '../domain/reminder_calculator.dart';
import '../domain/time_range.dart';

/// Orchestrates reminder computation, persistence, and OS notification scheduling.
class ReminderScheduler {
  ReminderScheduler(
    this._calc,
    this._reminders,
    this._notif,
    this._settings,
    this._tasks,
    this._projects,
  );

  final ReminderCalculator _calc;
  final IReminderRepository _reminders;
  final INotificationService _notif;
  final ISettingsStore _settings;
  final ITaskRepository _tasks;
  final IProjectRepository _projects;

  NotificationSettings get _notificationSettings =>
      NotificationSettings.fromStore(_settings);

  /// Recomputes and reschedules all reminders for [task].
  Future<void> sync(Task task) async {
    await _notif.cancelForTask(task.id);
    final settings = _notificationSettings;
    if (!settings.notificationsEnabled) return;
    if (task.status == TaskStatus.complete) return;

    final existing = await _reminders.getByTask(task.id);
    final configs = existing.valueOrNull ?? const <Reminder>[];

    final reminders = _calc.compute(
      task,
      settings.toAppSettings(),
      configs: configs,
    );

    await _reminders.replaceForTask(task.id, reminders);

    for (final r in reminders) {
      if (_isInDnd(r.triggerAt, settings) && r.type != ReminderType.overdue) {
        continue;
      }
      await _scheduleOne(task, r);
    }
  }

  /// Cancels all platform notifications for [taskId].
  Future<void> cancel(String taskId) => _notif.cancelForTask(taskId);

  /// Startup reconcile: reschedule missing pending notifications and cancel
  /// reminders for completed tasks within the next 30 days.
  Future<void> reconcileOnLaunch() async {
    final settings = _notificationSettings;
    if (!settings.notificationsEnabled) return;

    final cutoff = DateTime.now().toUtc().add(const Duration(days: 30));
    final dueResult = await _reminders.dueBefore(cutoff);
    final due = dueResult.valueOrNull ?? const <Reminder>[];
    final pending = (await _notif.pending()).toSet();

    for (final r in due) {
      final taskResult = await _tasks.findById(r.taskId);
      final task = taskResult.valueOrNull;
      if (task == null || task.status == TaskStatus.complete) {
        await _notif.cancelForTask(r.taskId);
        continue;
      }

      final notifId = r.notifId ?? stableId(r.id);
      if (!pending.contains(notifId)) {
        if (_isInDnd(r.triggerAt, settings) && r.type != ReminderType.overdue) {
          continue;
        }
        await _scheduleOne(task, r);
      }
    }
  }

  Future<void> _scheduleOne(Task task, Reminder reminder) async {
    final notifId = reminder.notifId ?? stableId(reminder.id);
    await _notif.schedule(
      NotificationRequest(
        id: notifId,
        taskId: task.id,
        title: task.title,
        body: await _composeBody(task),
        scheduledAt: reminder.triggerAt,
      ),
    );
  }

  Future<String> _composeBody(Task task) async {
    final due = task.dueDate;
    final dueLabel = due != null
        ? DateFormat('MM-dd HH:mm').format(due.toLocal())
        : '—';

    if (task.projectId == null) {
      return 'Due $dueLabel';
    }

    String projectName = 'Project';
    final projects = await _projects.getAll();
    if (projects case Ok(:final value)) {
      for (final p in value) {
        if (p.id == task.projectId) {
          projectName = p.name;
          break;
        }
      }
    }
    return '[$projectName] · Due $dueLabel';
  }

  bool _isInDnd(DateTime utc, NotificationSettings settings) {
    if (!settings.dndEnabled) return false;
    final local = utc.toLocal();
    final minutes = local.hour * 60 + local.minute;
    return TimeRange(
      settings.dndStartMinutes,
      settings.dndEndMinutes,
    ).containsMinutes(minutes);
  }
}

/// Stable platform notification id derived from a reminder id string.
int stableId(String reminderId) => reminderId.hashCode & 0x7fffffff;
