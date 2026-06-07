import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/reminder.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/notification/application/reminder_scheduler.dart';
import 'package:plan_list/features/notification/domain/reminder_calculator.dart';
import 'package:plan_list/platform/settings/setting_keys.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository tasks;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late FakeProjectRepository projects;
  late ReminderScheduler scheduler;

  setUp(() {
    tasks = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    projects = FakeProjectRepository();
    scheduler = ReminderScheduler(
      const ReminderCalculator(),
      reminders,
      notif,
      settings,
      tasks,
      projects,
    );
  });

  tearDown(() {
    tasks.dispose();
    notif.dispose();
    settings.dispose();
  });

  Task futureTask() {
    final due = DateTime.now().toUtc().add(const Duration(days: 2));
    return Task(
      id: 'task-1',
      title: 'Future task',
      dueDate: due,
    );
  }

  test('sync cancels old notifications before scheduling', () async {
    final task = futureTask();
    await scheduler.sync(task);
    expect(notif.cancelledTaskIds, contains(task.id));
    expect(notif.scheduledRequests, isNotEmpty);
  });

  test('sync skips scheduling when notifications disabled', () async {
    await settings.set(SettingKeys.notificationsEnabled, false);
    await scheduler.sync(futureTask());
    expect(notif.scheduledRequests, isEmpty);
  });

  test('sync skips non-overdue reminders in DND window', () async {
    await settings.set(SettingKeys.dndEnabled, true);
    await settings.set(SettingKeys.dndStartMinutes, 0);
    await settings.set(SettingKeys.dndEndMinutes, 24 * 60);

    final due = DateTime.now().toUtc().add(const Duration(hours: 2));
    final task = Task(id: 'dnd-task', title: 'DND', dueDate: due);
    await reminders.replaceForTask(task.id, [
      Reminder(
        id: 'r1',
        taskId: task.id,
        triggerAt: due,
        type: ReminderType.beforeDue,
        offsetMin: 0,
      ),
    ]);

    await scheduler.sync(task);
    expect(notif.cancelledTaskIds, contains(task.id));
    expect(notif.scheduledRequests, isEmpty);
  });

  test('sync still schedules overdue reminders during DND', () async {
    await settings.set(SettingKeys.dndEnabled, true);
    await settings.set(SettingKeys.dndStartMinutes, 0);
    await settings.set(SettingKeys.dndEndMinutes, 24 * 60);

    final due = DateTime.utc(2020, 1, 1);
    final task = Task(id: 'od-task', title: 'Overdue', dueDate: due);
    await reminders.replaceForTask(task.id, [
      Reminder(
        id: 'od',
        taskId: task.id,
        triggerAt: due,
        type: ReminderType.overdue,
      ),
    ]);

    await scheduler.sync(task);
    expect(notif.scheduledRequests, isNotEmpty);
  });

  test('cancel delegates to notification service', () async {
    await scheduler.cancel('x');
    expect(notif.cancelledTaskIds, ['x']);
  });
}
