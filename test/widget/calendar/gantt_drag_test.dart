import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/calendar/presentation/calendar_view_state_notifier.dart';
import 'package:liveline/features/calendar/presentation/views/gantt_view.dart';
import 'package:liveline/features/notification/application/reminder_scheduler.dart';
import 'package:liveline/features/notification/domain/reminder_calculator.dart';
import 'package:liveline/features/task/domain/create_task_usecase.dart';
import 'package:liveline/features/task/domain/update_task_usecase.dart';
import 'package:liveline/features/task/task_providers.dart';

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
        clockProvider.overrideWith(
          (ref) =>
              () => DateTime(2026, 6, 15),
        ),
        createTaskUseCaseProvider.overrideWithValue(
          CreateTaskUseCase(repo, scheduler),
        ),
        updateTaskUseCaseProvider.overrideWithValue(
          UpdateTaskUseCase(repo, scheduler),
        ),
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

    tester.view.physicalSize = const Size(1400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: GanttView(onSelect: (_) {})),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // One row per task; row 0 holds Task X spanning 3 day-columns. The day
    // columns are fit to the available width, so derive pixels-per-day from the
    // rendered bar and drag its centre (the move zone, not an edge handle) two
    // days to the right.
    final rect = tester.getRect(find.byKey(const Key('gantt-bar-x')));
    final pxPerDay = (rect.width + 2) / 3;
    await tester.dragFrom(rect.center, Offset(pxPerDay * 2, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final moved = repo.items.single;
    expect(moved.startDate, start.add(const Duration(days: 2)));
    expect(moved.dueDate, start.add(const Duration(days: 4)));
  });

  testWidgets('dragging a Gantt bar end edge resizes the due date', (
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
        clockProvider.overrideWith(
          (ref) =>
              () => DateTime(2026, 6, 15),
        ),
        createTaskUseCaseProvider.overrideWithValue(
          CreateTaskUseCase(repo, scheduler),
        ),
        updateTaskUseCaseProvider.overrideWithValue(
          UpdateTaskUseCase(repo, scheduler),
        ),
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

    tester.view.physicalSize = const Size(1400, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: GanttView(onSelect: (_) {})),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Grab inside the bar's right-edge handle zone and drag one day to extend
    // the due date. Pixels-per-day is derived from the rendered 3-day bar.
    final rect = tester.getRect(find.byKey(const Key('gantt-bar-x')));
    final pxPerDay = (rect.width + 2) / 3;
    final endGrab = Offset(rect.right - 4, rect.center.dy);
    await tester.dragFrom(endGrab, Offset(pxPerDay, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final resized = repo.items.single;
    expect(resized.startDate, start, reason: 'start date unchanged');
    expect(resized.dueDate, start.add(const Duration(days: 3)));
  });
}
