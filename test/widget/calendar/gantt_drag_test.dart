import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/di/clock.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/calendar/presentation/calendar_view_state_notifier.dart';
import 'package:plan_list/features/calendar/presentation/views/gantt_view.dart';
import 'package:plan_list/features/notification/application/reminder_scheduler.dart';
import 'package:plan_list/features/notification/domain/reminder_calculator.dart';
import 'package:plan_list/features/task/domain/create_task_usecase.dart';
import 'package:plan_list/features/task/domain/update_task_usecase.dart';
import 'package:plan_list/features/task/task_providers.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  testWidgets('dragging a Gantt bar horizontally moves the task', (
    tester,
  ) async {
    final repo = FakeTaskRepository();
    final reminders = FakeReminderRepository();
    final notif = SpyNotificationService();
    final settings = FakeSettingsStore();
    final scheduler = ReminderScheduler(
      const ReminderCalculator(),
      reminders,
      notif,
      settings,
      repo,
      FakeProjectRepository(),
    );
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWith((ref) => () => DateTime(2026, 6, 15)),
        createTaskUseCaseProvider
            .overrideWithValue(CreateTaskUseCase(repo, scheduler)),
        updateTaskUseCaseProvider
            .overrideWithValue(UpdateTaskUseCase(repo, scheduler)),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(repo.dispose);
    addTearDown(notif.dispose);
    addTearDown(settings.dispose);

    container
        .read(calendarViewStateProvider.notifier)
        .switchView(CalendarViewType.gantt);
    final start = container.read(calendarViewStateProvider).visibleRange.start;
    repo.seed([
      Task(
        id: 'x',
        title: 'Task X',
        startDate: start,
        dueDate: start.add(const Duration(days: 2)),
      ),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 700,
              height: 300,
              child: GanttView(onSelect: (_) {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The bar for the first task sits in lane 0 starting at the left edge.
    // Header is 28px tall; lane 0 center is ~18px into the body.
    // Drag two days to the right (2 * 48px per day).
    await tester.dragFrom(const Offset(60, 50), const Offset(96, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final moved = repo.items.single;
    expect(moved.startDate, start.add(const Duration(days: 2)));
    expect(moved.dueDate, start.add(const Duration(days: 4)));
  });
}
