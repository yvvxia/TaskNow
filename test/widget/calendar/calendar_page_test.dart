import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/di/clock.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/calendar/calendar_page.dart';
import 'package:plan_list/features/calendar/domain/calendar_view_state.dart';
import 'package:plan_list/features/calendar/domain/calendar_window.dart';
import 'package:plan_list/features/calendar/domain/gantt_interaction_controller.dart';
import 'package:plan_list/features/calendar/presentation/calendar_view_state_notifier.dart';
import 'package:plan_list/features/calendar/presentation/views/gantt_view.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late FakeProjectRepository projects;

  final frozen = DateTime.utc(2026, 6, 7);

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    projects = FakeProjectRepository();
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  List<Override> baseOverrides() => [
        taskRepositoryProvider.overrideWithValue(repo),
        reminderRepositoryProvider.overrideWithValue(reminders),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(settings),
        projectRepositoryProvider.overrideWithValue(projects),
        clockProvider.overrideWith((ref) => () => frozen),
      ];

  Widget wrap(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [...baseOverrides(), ...overrides],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('renders the calendar page with view tabs', (tester) async {
    await tester.pumpWidget(wrap(const CalendarPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-page')), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Gantt'), findsOneWidget);
    expect(find.byKey(const Key('calendar-today')), findsOneWidget);
  });

  testWidgets('switching to Gantt renders a bar for a dated task',
      (tester) async {
    repo.seed([
      Task(
        id: 'g1',
        title: 'Gantt task',
        startDate: DateTime.utc(2026, 6, 8),
        dueDate: DateTime.utc(2026, 6, 10),
      ),
    ]);

    await tester.pumpWidget(wrap(const CalendarPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gantt'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gantt-bar-g1')), findsOneWidget);
  });

  testWidgets('tapping the next button advances the window', (tester) async {
    await tester.pumpWidget(wrap(const CalendarPage()));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('calendar-page'))),
    );
    final before = container.read(calendarViewStateProvider).anchor;

    await tester.tap(find.byKey(const Key('calendar-next')));
    await tester.pumpAndSettle();

    final after = container.read(calendarViewStateProvider).anchor;
    expect(after.isAfter(before), isTrue);
  });

  testWidgets('drag on empty Gantt space creates a task', (tester) async {
    final anchor = DateTime.utc(2026, 6, 1);
    final range = DateTimeRange(
      start: DateTime.utc(2026, 6, 1),
      end: DateTime.utc(2026, 6, 4).subtract(const Duration(milliseconds: 1)),
    );

    await tester.pumpWidget(
      wrap(
        const Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GanttView(onSelect: _noop),
          ),
        ),
        overrides: [
          calendarViewStateProvider.overrideWithValue(
            CalendarViewState(
              type: CalendarViewType.gantt,
              anchor: anchor,
              visibleRange: range,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);

    // Vertical-safe horizontal drag on empty timeline body (header is 28px).
    await tester.dragFrom(const Offset(50, 45), const Offset(50, 0));
    await tester.pumpAndSettle();

    expect(repo.items, hasLength(1));
    expect(repo.items.first.title, 'New task');
  });

  test('CalendarWindow week range spans 7 days', () {
    final range = CalendarWindow.rangeFor(
      CalendarViewType.week,
      DateTime(2026, 6, 7),
    );
    expect(range.end.difference(range.start).inDays, 6);
  });

  // Reference the controller provider so the import is exercised even when the
  // drag path short-circuits in a constrained environment.
  test('gantt interaction provider resolves', () {
    final container = ProviderContainer(overrides: baseOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(ganttInteractionControllerProvider.notifier),
      isNotNull,
    );
  });
}

void _noop(String? _) {}
