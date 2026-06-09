import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/recurrence_rule.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/task/domain/complete_task_usecase.dart';
import 'package:liveline/features/task/domain/recurrence_engine.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';
import '../../helpers/notification_test_helpers.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late CompleteTaskUseCase useCase;

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    useCase = CompleteTaskUseCase(
      repo,
      reminders,
      makeTestReminderScheduler(
        repo: repo,
        reminders: reminders,
        notif: notif,
        settings: settings,
      ),
      const RecurrenceEngine(),
    );
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  test('completing a task marks it complete in repo', () async {
    repo.seed([const Task(id: 'task-1', title: 'Test')]);

    final result = await useCase('task-1', at: DateTime.utc(2026, 6, 7));

    expect(result.isOk, isTrue);
    expect(repo.items.first.status, TaskStatus.complete);
    expect(repo.items.first.completedAt, isNotNull);
  });

  test('completing cancels notifications for the task', () async {
    repo.seed([const Task(id: 'task-1', title: 'Test')]);

    await useCase('task-1', at: DateTime.utc(2026, 6, 7));

    expect(notif.cancelledTaskIds, contains('task-1'));
  });

  test('completing a recurring task generates next instance', () async {
    final rule = RecurrenceRule(
      id: 'rule1',
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      byWeekday: [7], // Sunday
    );
    final task = Task(
      id: 'task-1',
      title: 'Weekly review',
      dueDate: DateTime.utc(2026, 6, 7), // Sunday
      recurrence: rule,
    );
    repo.seed([task]);

    await useCase('task-1', at: DateTime.utc(2026, 6, 7));

    // Original task should be completed, new instance should exist.
    final completed = repo.items.firstWhere((t) => t.id == 'task-1');
    expect(completed.status, TaskStatus.complete);

    final nextInstances = repo.items.where((t) => t.id != 'task-1').toList();
    expect(nextInstances, hasLength(1));
    expect(nextInstances.first.title, 'Weekly review');
    expect(nextInstances.first.status, TaskStatus.incomplete);
  });

  test('completing non-recurring task does not create next instance', () async {
    repo.seed([const Task(id: 'task-1', title: 'One-off')]);

    await useCase('task-1');

    expect(repo.items, hasLength(1));
  });

  test('completing unknown task returns NotFoundException', () async {
    final result = await useCase('nonexistent');
    expect(result.isErr, isTrue);
  });
}
