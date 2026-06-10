import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/calendar/domain/gantt_interaction_controller.dart';
import 'package:liveline/features/calendar/presentation/calendar_providers.dart';
import 'package:liveline/features/notification/application/reminder_scheduler.dart';
import 'package:liveline/features/notification/domain/reminder_calculator.dart';
import 'package:liveline/features/task/domain/update_task_usecase.dart';
import 'package:liveline/features/task/task_providers.dart';

import '../../../fakes/fake_settings_store.dart';
import '../../../fakes/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late ProviderContainer container;

  setUp(() {
    repo = FakeTaskRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    final scheduler = ReminderScheduler(
      const ReminderCalculator(),
      FakeReminderRepository(),
      notif,
      settings,
      repo,
      FakeProjectRepository(),
    );
    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWith((ref) => () => DateTime(2026, 6, 15)),
        updateTaskUseCaseProvider.overrideWithValue(
          UpdateTaskUseCase(repo, scheduler),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  test('unscheduledTasks lists only tasks without dates', () async {
    repo.seed([
      const Task(id: 'undated', title: 'Undated'),
      Task(
        id: 'dated',
        title: 'Dated',
        startDate: DateTime(2026, 6, 16),
        dueDate: DateTime(2026, 6, 16),
      ),
    ]);

    final sub = container.listen(
      unscheduledTasksProvider(null),
      (_, _) {},
    );
    addTearDown(sub.close);

    final tasks = await container.read(unscheduledTasksProvider(null).future);
    expect(tasks.map((t) => t.id), ['undated']);
  });

  test('scheduleAt assigns start and due dates to an undated task', () async {
    repo.seed([const Task(id: 'u', title: 'Undated')]);

    final start = DateTime(2026, 6, 15, 9);
    await container
        .read(ganttInteractionControllerProvider.notifier)
        .scheduleAt('u', start, start.add(const Duration(hours: 1)));

    final saved = repo.items.single;
    expect(saved.startDate, start);
    expect(saved.dueDate, start.add(const Duration(hours: 1)));
  });
}
