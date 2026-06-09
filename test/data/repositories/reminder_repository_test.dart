import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/reminder.dart';
import 'package:liveline/core/models/task_draft.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_reminder_repository.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';

void main() {
  late AppDatabase db;
  late DriftReminderRepository repo;
  late String taskId;

  setUp(() async {
    db = newTestDb();
    repo = DriftReminderRepository(db);
    // Reminders FK -> tasks(id); create a parent task first.
    final task = await DriftTaskRepository(
      db,
    ).create(const TaskDraft(title: 'parent'));
    taskId = task.valueOrNull!.id;
  });
  tearDown(() => db.close());

  Reminder reminder(String id, DateTime at, {bool fired = false}) => Reminder(
    id: id,
    taskId: taskId,
    triggerAt: at,
    type: ReminderType.beforeDue,
    offsetMin: 15,
    isFired: fired,
  );

  test('replaceForTask then getByTask returns reminders', () async {
    final res = await repo.replaceForTask(taskId, [
      reminder('r1', DateTime.utc(2026, 6, 1, 9)),
      reminder('r2', DateTime.utc(2026, 6, 2, 9)),
    ]);
    expect(res.isOk, isTrue);
    final got = await repo.getByTask(taskId);
    expect(got.valueOrNull!.map((r) => r.id), ['r1', 'r2']);
  });

  test('replaceForTask replaces the previous set', () async {
    await repo.replaceForTask(taskId, [
      reminder('r1', DateTime.utc(2026, 6, 1)),
    ]);
    await repo.replaceForTask(taskId, [
      reminder('r2', DateTime.utc(2026, 6, 2)),
    ]);
    final got = await repo.getByTask(taskId);
    expect(got.valueOrNull!.map((r) => r.id), ['r2']);
  });

  test('dueBefore returns only unfired reminders before the cutoff', () async {
    await repo.replaceForTask(taskId, [
      reminder('past', DateTime.utc(2026, 6, 1)),
      reminder('firedPast', DateTime.utc(2026, 6, 1), fired: true),
      reminder('future', DateTime.utc(2026, 7, 1)),
    ]);
    final res = await repo.dueBefore(DateTime.utc(2026, 6, 15));
    expect(res.valueOrNull!.map((r) => r.id), ['past']);
  });

  test('markFired flips the is_fired flag', () async {
    await repo.replaceForTask(taskId, [
      reminder('r1', DateTime.utc(2026, 6, 1)),
    ]);
    final res = await repo.markFired('r1');
    expect(res.isOk, isTrue);
    final got = await repo.getByTask(taskId);
    expect(got.valueOrNull!.single.isFired, isTrue);
  });
}
