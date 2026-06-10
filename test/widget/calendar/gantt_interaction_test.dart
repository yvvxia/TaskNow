import 'package:flutter/gestures.dart';
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
import 'package:liveline/features/task/presentation/add_task_sheet.dart';
import 'package:liveline/features/task/task_providers.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  Future<ProviderContainer> makeContainer(FakeTaskRepository repo) async {
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
    return container;
  }

  Future<void> pumpGantt(
    WidgetTester tester,
    ProviderContainer container,
    FakeTaskRepository repo,
  ) async {
    container
        .read(calendarViewStateProvider.notifier)
        .switchView(CalendarViewType.gantt);
    final start = container.read(calendarViewStateProvider).visibleRange.start;
    repo.seed([
      Task(
        id: 'x',
        title: 'Task X',
        startDate: start.add(const Duration(days: 3)),
        dueDate: start.add(const Duration(days: 5)),
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
  }

  testWidgets('desktop secondary tap on Gantt bar shows edit/delete menu', (
    tester,
  ) async {
    final repo = FakeTaskRepository();
    final container = await makeContainer(repo);
    await pumpGantt(tester, container, repo);

    await tester.tap(
      find.byKey(const Key('gantt-bar-x')),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('desktop tap on blank Gantt timeline opens add task sheet', (
    tester,
  ) async {
    final repo = FakeTaskRepository();
    final container = await makeContainer(repo);
    await pumpGantt(tester, container, repo);

    final barRect = tester.getRect(find.byKey(const Key('gantt-bar-x')));
    await tester.tapAt(Offset(barRect.left - 30, barRect.center.dy));
    await tester.pumpAndSettle();

    expect(find.byType(AddTaskSheet), findsOneWidget);
  });
}
