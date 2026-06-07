import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/reminder.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/notification/application/reminder_scheduler.dart';
import 'package:plan_list/features/notification/domain/reminder_calculator.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository tasks;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late ReminderScheduler scheduler;

  setUp(() {
    tasks = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    scheduler = ReminderScheduler(
      const ReminderCalculator(),
      reminders,
      notif,
      settings,
      tasks,
      FakeProjectRepository(),
    );
  });

  tearDown(() {
    tasks.dispose();
    notif.dispose();
    settings.dispose();
  });

  test('reconcileOnLaunch reschedules missing pending notifications', () async {
    final due = DateTime.now().toUtc().add(const Duration(days: 1));
    const taskId = 'reconcile-task';
    tasks.seed([
      Task(id: taskId, title: 'Reconcile me', dueDate: due),
    ]);
    await reminders.replaceForTask(taskId, [
      Reminder(
        id: 'r1',
        taskId: taskId,
        triggerAt: due,
        type: ReminderType.beforeDue,
        offsetMin: 0,
      ),
    ]);

    expect(await notif.pending(), isEmpty);

    await scheduler.reconcileOnLaunch();

    expect(notif.scheduledRequests, hasLength(1));
    expect(notif.scheduledRequests.single.taskId, taskId);
  });

  test('reconcileOnLaunch cancels reminders for completed tasks', () async {
    final due = DateTime.now().toUtc().add(const Duration(days: 1));
    const taskId = 'done-task';
    tasks.seed([
      Task(
        id: taskId,
        title: 'Done',
        dueDate: due,
        status: TaskStatus.complete,
      ),
    ]);
    await reminders.replaceForTask(taskId, [
      Reminder(
        id: 'r1',
        taskId: taskId,
        triggerAt: due,
        type: ReminderType.beforeDue,
      ),
    ]);

    await scheduler.reconcileOnLaunch();

    expect(notif.cancelledTaskIds, contains(taskId));
    expect(notif.scheduledRequests, isEmpty);
  });
}
