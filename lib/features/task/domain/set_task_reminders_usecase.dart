import 'package:uuid/uuid.dart';

import '../../../core/contracts/i_reminder_repository.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/reminder.dart';
import '../../../core/models/task.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';
import 'reminder_template.dart';

/// Persists reminder templates for a task and reschedules OS notifications.
final class SetTaskRemindersUseCase {
  const SetTaskRemindersUseCase(this._reminders, this._scheduler);

  final IReminderRepository _reminders;
  final ReminderScheduler _scheduler;

  Future<Result<void>> call(Task task, List<ReminderTemplate> templates) async {
    final placeholder = DateTime.now().toUtc();
    final reminders = templates
        .map(
          (t) => Reminder(
            id: const Uuid().v4(),
            taskId: task.id,
            triggerAt: placeholder,
            type: t.type,
            offsetMin: t.offsetMin,
          ),
        )
        .toList();

    final saved = await _reminders.replaceForTask(task.id, reminders);
    if (saved case Err(:final error)) return Err(error);

    if (templates.isEmpty) {
      await _scheduler.cancel(task.id);
    } else {
      await _scheduler.sync(task);
    }
    return const Ok(null);
  }
}

/// Converts persisted [Reminder] rows into editable [ReminderTemplate]s.
List<ReminderTemplate> remindersToTemplates(List<Reminder> reminders) {
  return reminders
      .map((r) => ReminderTemplate(type: r.type, offsetMin: r.offsetMin))
      .toList();
}

/// Default templates shown when a task has a due date but no saved reminders.
List<ReminderTemplate> defaultReminderTemplates({int defaultOffsetMin = 15}) {
  return [
    ReminderTemplate(type: ReminderType.beforeDue, offsetMin: defaultOffsetMin),
  ];
}
