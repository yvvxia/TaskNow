import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'reminder_dao.g.dart';

/// Data-access object for reminders.
@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Future<List<ReminderRow>> getByTask(String taskId) {
    return (select(reminders)
          ..where((r) => r.taskId.equals(taskId))
          ..orderBy([(r) => OrderingTerm(expression: r.triggerAt)]))
        .get();
  }

  /// Replaces all reminders for a task atomically.
  Future<void> replaceForTask(String taskId, List<ReminderRow> rows) async {
    await transaction(() async {
      await (delete(reminders)..where((r) => r.taskId.equals(taskId))).go();
      if (rows.isNotEmpty) {
        await batch((b) => b.insertAll(reminders, rows));
      }
    });
  }

  /// Reminders that should have fired before [cutoffMs] and have not yet fired.
  Future<List<ReminderRow>> dueBefore(int cutoffMs) {
    return (select(reminders)
          ..where(
            (r) =>
                r.triggerAt.isSmallerThanValue(cutoffMs) &
                r.isFired.equals(false),
          )
          ..orderBy([(r) => OrderingTerm(expression: r.triggerAt)]))
        .get();
  }

  Future<int> markFired(String reminderId) {
    return (update(reminders)..where((r) => r.id.equals(reminderId))).write(
      const RemindersCompanion(isFired: Value(true)),
    );
  }
}
