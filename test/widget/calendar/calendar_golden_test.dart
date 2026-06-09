import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/calendar/domain/calendar_view_state.dart';
import 'package:liveline/features/calendar/domain/calendar_window.dart';
import 'package:liveline/features/calendar/presentation/calendar_view_state_notifier.dart';
import 'package:liveline/features/calendar/presentation/views/gantt_view.dart';
import 'package:liveline/features/calendar/presentation/views/week_view.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  final frozen = DateTime.utc(2026, 6, 10);

  setUp(() => repo = FakeTaskRepository());
  tearDown(() => repo.dispose());

  CalendarViewState stateFor(CalendarViewType type, DateTime anchor) =>
      CalendarViewState(
        type: type,
        anchor: anchor,
        visibleRange: CalendarWindow.rangeFor(type, anchor),
      );

  Widget harness({
    required CalendarViewType type,
    required DateTime anchor,
    required Widget child,
    required double width,
    required double height,
  }) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWith(
          (ref) =>
              () => frozen,
        ),
        calendarViewStateProvider.overrideWithValue(stateFor(type, anchor)),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, height: height, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('week view golden', (tester) async {
    final anchor = DateTime(2026, 6, 10);
    final range = CalendarWindow.rangeFor(CalendarViewType.week, anchor);
    repo.seed([
      Task(
        id: 'w1',
        title: 'Spec review',
        priority: Priority.high,
        startDate: range.start,
        dueDate: range.start.add(const Duration(days: 2)),
      ),
      Task(
        id: 'w2',
        title: 'Design sync',
        priority: Priority.medium,
        startDate: range.start.add(const Duration(days: 1)),
        dueDate: range.start.add(const Duration(days: 4)),
      ),
    ]);

    await tester.pumpWidget(
      harness(
        type: CalendarViewType.week,
        anchor: anchor,
        width: 700,
        height: 320,
        child: const WeekView(onSelect: _noop),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(WeekView),
      matchesGoldenFile('goldens/week_view.png'),
    );
  });

  testWidgets('gantt view golden', (tester) async {
    final anchor = DateTime(2026, 6, 10);
    final range = CalendarWindow.rangeFor(CalendarViewType.gantt, anchor);
    repo.seed([
      Task(
        id: 'g1',
        title: 'Phase one',
        priority: Priority.high,
        startDate: range.start.add(const Duration(days: 1)),
        dueDate: range.start.add(const Duration(days: 5)),
      ),
      Task(
        id: 'g2',
        title: 'Phase two',
        priority: Priority.low,
        startDate: range.start.add(const Duration(days: 3)),
        dueDate: range.start.add(const Duration(days: 9)),
      ),
    ]);

    await tester.pumpWidget(
      harness(
        type: CalendarViewType.gantt,
        anchor: anchor,
        width: 800,
        height: 320,
        child: const GanttView(onSelect: _noop),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GanttView),
      matchesGoldenFile('goldens/gantt_view.png'),
    );
  });
}

void _noop(String? _) {}
