import '../../../core/enums/enums.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/reminder.dart';
import '../../../core/models/task.dart';
import 'notification_settings.dart';

/// Pure reminder trigger-time calculator (module 05 domain).
class ReminderCalculator {
  const ReminderCalculator();

  /// Computes absolute trigger times from [configs] and the task's dates.
  ///
  /// [configs] are the persisted reminder templates (type / offset). When
  /// empty and the task has a due date, a default [ReminderType.beforeDue]
  /// reminder is assumed using [settings.defaultAdvanceMin].
  List<Reminder> compute(
    Task task,
    AppSettings settings, {
    List<Reminder> configs = const [],
  }) {
    final templates = configs.isEmpty && task.dueDate != null
        ? [
            Reminder(
              id: '${task.id}-default-before-due',
              taskId: task.id,
              triggerAt: task.dueDate!,
              type: ReminderType.beforeDue,
            ),
          ]
        : configs;

    final out = <Reminder>[];
    for (final r in templates) {
      switch (r.type) {
        case ReminderType.beforeDue:
          if (task.dueDate == null) continue;
          final offset = r.offsetMin ?? settings.defaultReminderMinutes;
          out.add(
            r.copyWith(
              taskId: task.id,
              triggerAt: task.dueDate!.subtract(Duration(minutes: offset)),
            ),
          );
        case ReminderType.atStart:
          if (task.startDate == null) continue;
          out.add(r.copyWith(taskId: task.id, triggerAt: task.startDate!));
        case ReminderType.custom:
          out.add(r.copyWith(taskId: task.id));
        case ReminderType.overdue:
          if (task.dueDate == null) continue;
          out.add(r.copyWith(taskId: task.id, triggerAt: task.dueDate!));
      }
    }

    final now = DateTime.now().toUtc();
    return out
        .where(
          (r) => r.type == ReminderType.overdue || r.triggerAt.isAfter(now),
        )
        .toList();
  }

  /// Returns the next overdue repeat trigger after [lastFired], or null when
  /// repeat is disabled.
  DateTime? nextOverdue(DateTime lastFired, NotificationSettings settings) {
    if (settings.overdueRepeatHours == 0) return null;
    return lastFired.add(Duration(hours: settings.overdueRepeatHours));
  }
}
