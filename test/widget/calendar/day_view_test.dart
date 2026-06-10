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
import 'package:liveline/features/calendar/presentation/views/day_view.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  final frozen = DateTime.utc(2026, 6, 10, 10);

  setUp(() => repo = FakeTaskRepository());
  tearDown(() => repo.dispose());

  Widget harness({required DateTime anchor, required Widget child}) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWith(
          (ref) =>
              () => frozen,
        ),
        calendarViewStateProvider.overrideWithValue(
          CalendarViewState(
            type: CalendarViewType.day,
            anchor: anchor,
            visibleRange: CalendarWindow.rangeFor(CalendarViewType.day, anchor),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: SizedBox(width: 400, height: 600, child: child)),
      ),
    );
  }

  testWidgets('overlapping timed tasks render side by side', (tester) async {
    final day = DateTime(2026, 6, 10);
    repo.seed([
      Task(
        id: 'a',
        title: 'Morning standup',
        priority: Priority.high,
        startDate: day.add(const Duration(hours: 9)),
        dueDate: day.add(const Duration(hours: 10)),
      ),
      Task(
        id: 'b',
        title: 'Client call',
        priority: Priority.medium,
        startDate: day.add(const Duration(hours: 9, minutes: 30)),
        dueDate: day.add(const Duration(hours: 10, minutes: 30)),
      ),
    ]);

    await tester.pumpWidget(
      harness(
        anchor: day,
        child: const DayView(onSelect: _noop),
      ),
    );
    await tester.pumpAndSettle();

    final blockA = tester.getTopLeft(find.byKey(const Key('timed-block-a')));
    final blockB = tester.getTopLeft(find.byKey(const Key('timed-block-b')));

    expect(blockA.dx, lessThan(blockB.dx));
    expect(find.text('Morning standup'), findsOneWidget);
    expect(find.text('Client call'), findsOneWidget);
  });

  testWidgets('completed task title is struck through', (tester) async {
    final day = DateTime(2026, 6, 10);
    repo.seed([
      Task(
        id: 'done',
        title: 'Ship release',
        priority: Priority.low,
        status: TaskStatus.complete,
        startDate: day.add(const Duration(hours: 14)),
        dueDate: day.add(const Duration(hours: 15)),
      ),
    ]);

    await tester.pumpWidget(
      harness(
        anchor: day,
        child: const DayView(onSelect: _noop),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.text('Ship release'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });
}

void _noop(String? _) {}
