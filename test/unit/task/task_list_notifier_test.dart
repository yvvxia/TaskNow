import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/di/clock.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/features/task/domain/task_list_scope.dart';
import 'package:plan_list/features/task/presentation/task_list_notifier.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
  });

  ProviderContainer makeContainer({DateTime? frozenClock}) {
    final clock = frozenClock ?? DateTime.utc(2026, 6, 7);
    return ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        reminderRepositoryProvider.overrideWithValue(reminders),
        notificationServiceProvider.overrideWithValue(notif),
        clockProvider.overrideWith(
          (ref) =>
              () => clock,
        ),
      ],
    );
  }

  test('emits TaskView list from repository stream', () async {
    repo.seed([
      const Task(id: 't1', title: 'Task One'),
      const Task(id: 't2', title: 'Task Two'),
    ]);

    final container = makeContainer();
    addTearDown(container.dispose);

    final sub = container.listen(taskListProvider(const AllScope()), (_, _) {});

    // Wait for stream to emit.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(taskListProvider(const AllScope()));
    expect(
      state.value?.map((v) => v.title),
      containsAll(['Task One', 'Task Two']),
    );

    sub.close();
  });

  test('isOverdue derived correctly when clock is past dueDate', () async {
    final overdueClock = DateTime.utc(2026, 6, 15);
    repo.seed([
      Task(id: 't1', title: 'Overdue task', dueDate: DateTime.utc(2026, 6, 10)),
    ]);

    final container = makeContainer(frozenClock: overdueClock);
    addTearDown(container.dispose);

    container.listen(taskListProvider(const AllScope()), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(taskListProvider(const AllScope()));
    expect(state.value?.first.isOverdue, isTrue);
  });

  test('isOverdue false when clock is before dueDate', () async {
    final earlyNow = DateTime.utc(2026, 6, 5);
    repo.seed([
      Task(id: 't1', title: 'Future task', dueDate: DateTime.utc(2026, 6, 10)),
    ]);

    final container = makeContainer(frozenClock: earlyNow);
    addTearDown(container.dispose);

    container.listen(taskListProvider(const AllScope()), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(taskListProvider(const AllScope()));
    expect(state.value?.first.isOverdue, isFalse);
  });

  test('stream emits when task is created', () async {
    final container = makeContainer();
    addTearDown(container.dispose);

    final emitted = <int>[];
    final sub = container.listen(taskListProvider(const AllScope()), (_, next) {
      if (next.value != null) emitted.add(next.value!.length);
    });

    await repo.create(const TaskDraft(title: 'Seed'));
    repo.seed([const Task(id: 't1', title: 'Seeded')]);
    // seed() doesn't emit; trigger a stream event via update:
    await repo.update(const Task(id: 't1', title: 'Seeded'));

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emitted, isNotEmpty);

    sub.close();
  });

  test('completed scope only shows completed tasks', () async {
    repo.seed([
      const Task(id: 't1', title: 'Done', status: TaskStatus.complete),
      const Task(id: 't2', title: 'Pending'),
    ]);

    final container = makeContainer();
    addTearDown(container.dispose);

    container.listen(taskListProvider(const CompletedScope()), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final state = container.read(taskListProvider(const CompletedScope()));
    final tasks = state.value ?? [];
    expect(tasks.every((v) => v.isCompleted), isTrue);
  });
}
