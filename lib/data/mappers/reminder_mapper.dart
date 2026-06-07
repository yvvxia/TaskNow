import '../../core/enums/enums.dart';
import '../../core/models/reminder.dart';
import '../db/app_database.dart';
import 'time_mapper.dart';

/// Pure, bidirectional mapping between [ReminderRow] and [Reminder].
abstract final class ReminderMapper {
  static Reminder toEntity(ReminderRow row) {
    return Reminder(
      id: row.id,
      taskId: row.taskId,
      triggerAt: dateTimeFromUtcMs(row.triggerAt),
      type: _typeFromIndex(row.type),
      isFired: row.isFired,
      offsetMin: row.offsetMin,
      notifId: row.notifId,
    );
  }

  static ReminderRow toRow(Reminder reminder) {
    return ReminderRow(
      id: reminder.id,
      taskId: reminder.taskId,
      triggerAt: reminder.triggerAt.msUtc,
      type: reminder.type.index,
      offsetMin: reminder.offsetMin,
      isFired: reminder.isFired,
      notifId: reminder.notifId,
    );
  }

  static ReminderType _typeFromIndex(int index) {
    final i = index.clamp(0, ReminderType.values.length - 1);
    return ReminderType.values[i];
  }
}
