import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/reminder.dart';

int _seq = 0;

void resetReminderSeq() => _seq = 0;

/// Builds a [Reminder] with test defaults.
Reminder aReminder({
  String? id,
  String taskId = 'task-0',
  DateTime? triggerAt,
  ReminderType type = ReminderType.beforeDue,
  bool isFired = false,
  int? offsetMin,
  int? notifId,
}) {
  return Reminder(
    id: id ?? 'reminder-${_seq++}',
    taskId: taskId,
    triggerAt: triggerAt ?? DateTime.utc(2026, 6, 10, 9),
    type: type,
    isFired: isFired,
    offsetMin: offsetMin,
    notifId: notifId,
  );
}
