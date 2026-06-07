import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/subtask.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/task/domain/complete_task_usecase.dart';
import 'package:plan_list/features/task/domain/recurrence_engine.dart';
import 'package:plan_list/features/task/domain/toggle_subtask_usecase.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';
import '../../helpers/notification_test_helpers.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late CompleteTaskUseCase completeUseCase;
  late ToggleSubtaskUseCase toggleUseCase;

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    completeUseCase = CompleteTaskUseCase(
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
    toggleUseCase = ToggleSubtaskUseCase(repo, completeUseCase);
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  test('toggling a subtask flips isDone', () async {
    repo.seed([
      Task(
        id: 'task-1',
        title: 'Task with subtask',
        subtasks: const [
          Subtask(id: 'sub-1', title: 'Step 1', isDone: false),
        ],
      ),
    ]);

    await toggleUseCase('task-1', 'sub-1');

    final updated = repo.items.first;
    expect(updated.subtasks.first.isDone, isTrue);
  });

  test('toggling back sets isDone to false', () async {
    repo.seed([
      Task(
        id: 'task-1',
        title: 'Task',
        subtasks: const [
          Subtask(id: 'sub-1', title: 'Step', isDone: true),
        ],
      ),
    ]);

    await toggleUseCase('task-1', 'sub-1');

    final updated = repo.items.first;
    expect(updated.subtasks.first.isDone, isFalse);
  });

  test(
    'all subtasks done with autoComplete=true → parent completed',
    () async {
      repo.seed([
        Task(
          id: 'task-1',
          title: 'Auto task',
          autoCompleteOnSubtasks: true,
          subtasks: const [
            Subtask(id: 'sub-1', title: 'A', isDone: true),
            Subtask(id: 'sub-2', title: 'B', isDone: false),
          ],
        ),
      ]);

      // Toggle the last remaining incomplete subtask.
      await toggleUseCase(
        'task-1',
        'sub-2',
        at: DateTime.utc(2026, 6, 7),
      );

      final parent = repo.items.first;
      expect(parent.status, TaskStatus.complete);
      expect(notif.cancelledTaskIds, contains('task-1'));
    },
  );

  test(
    'all subtasks done but autoComplete=false → parent NOT completed',
    () async {
      repo.seed([
        Task(
          id: 'task-1',
          title: 'Manual task',
          autoCompleteOnSubtasks: false,
          subtasks: const [
            Subtask(id: 'sub-1', title: 'A', isDone: true),
            Subtask(id: 'sub-2', title: 'B', isDone: false),
          ],
        ),
      ]);

      await toggleUseCase('task-1', 'sub-2');

      final parent = repo.items.first;
      expect(parent.status, TaskStatus.incomplete);
    },
  );

  test('toggling unknown subtask returns NotFoundException', () async {
    repo.seed([const Task(id: 'task-1', title: 'Task', subtasks: [])]);

    final result = await toggleUseCase('task-1', 'nonexistent-sub');
    expect(result.isErr, isTrue);
  });
}
