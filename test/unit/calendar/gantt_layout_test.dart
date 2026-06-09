import 'package:flutter/material.dart' show Color, DateTimeRange, HSLColor;
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/calendar/domain/gantt_layout.dart';
import 'package:plan_list/features/calendar/domain/task_bar.dart';

void main() {
  final june = DateTimeRange(
    start: DateTime.utc(2026, 6, 1),
    end: DateTime.utc(2026, 6, 30),
  );
  final now = DateTime.utc(2026, 6, 7);

  List<TaskBar> layout(List<Task> tasks, {DateTime? clock}) =>
      GanttLayout.assign(
        tasks,
        range: june,
        now: clock ?? now,
        colorMode: BarColorMode.priority,
      );

  group('GanttLayout.assign', () {
    test('overlapping tasks get distinct lanes', () {
      final a = Task(
        id: 'a',
        title: 'A',
        startDate: DateTime.utc(2026, 6, 1),
        dueDate: DateTime.utc(2026, 6, 5),
      );
      final b = Task(
        id: 'b',
        title: 'B',
        startDate: DateTime.utc(2026, 6, 3),
        dueDate: DateTime.utc(2026, 6, 10),
      );

      final bars = layout([a, b]);

      expect(bars.map((x) => x.rowIndex).toSet(), {0, 1});
    });

    test('non-overlapping tasks reuse the same lane', () {
      final a = Task(
        id: 'a',
        title: 'A',
        startDate: DateTime.utc(2026, 6, 1),
        dueDate: DateTime.utc(2026, 6, 5),
      );
      final c = Task(
        id: 'c',
        title: 'C',
        startDate: DateTime.utc(2026, 6, 6),
        dueDate: DateTime.utc(2026, 6, 10),
      );

      final bars = layout([a, c]);

      expect(bars.every((x) => x.rowIndex == 0), isTrue);
    });

    test(
      'single-day fallback: dueDate only → barStart == barEnd == dueDate',
      () {
        final due = DateTime.utc(2026, 6, 8);
        final t = Task(id: 't', title: 'Due only', dueDate: due);

        final bars = layout([t]);

        expect(bars, hasLength(1));
        expect(bars.first.barStart, due);
        expect(bars.first.barEnd, due);
      },
    );

    test(
      'single-day fallback: startDate only → barStart == barEnd == startDate',
      () {
        final start = DateTime.utc(2026, 6, 9);
        final t = Task(id: 't', title: 'Start only', startDate: start);

        final bars = layout([t]);

        expect(bars.first.barStart, start);
        expect(bars.first.barEnd, start);
      },
    );

    test('task with neither start nor due is dropped', () {
      final t = const Task(id: 't', title: 'No dates');
      expect(layout([t]), isEmpty);
    });

    test('color is resolved by priority', () {
      final high = Task(
        id: 'h',
        title: 'High',
        priority: Priority.high,
        dueDate: DateTime.utc(2026, 6, 8),
      );
      final low = Task(
        id: 'l',
        title: 'Low',
        priority: Priority.low,
        dueDate: DateTime.utc(2026, 6, 8),
      );

      final bars = layout([high, low]);
      final byId = {for (final b in bars) b.task.id: b};

      expect(byId['h']!.color, const Color(0xFFDC2626));
      expect(byId['l']!.color, const Color(0xFF16A34A));
    });

    test('isOverdue is true when due date is before now', () {
      final overdue = Task(
        id: 'o',
        title: 'Overdue',
        dueDate: DateTime.utc(2026, 6, 5),
      );

      final bars = layout([overdue], clock: DateTime.utc(2026, 6, 10));

      expect(bars.first.isOverdue, isTrue);
    });

    test('bars are sorted/packed by start date', () {
      final later = Task(
        id: 'later',
        title: 'Later',
        startDate: DateTime.utc(2026, 6, 20),
        dueDate: DateTime.utc(2026, 6, 22),
      );
      final earlier = Task(
        id: 'earlier',
        title: 'Earlier',
        startDate: DateTime.utc(2026, 6, 2),
        dueDate: DateTime.utc(2026, 6, 4),
      );

      final bars = layout([later, earlier]);

      // Both fit in lane 0 (non-overlapping) regardless of input order.
      expect(bars.every((b) => b.rowIndex == 0), isTrue);
    });
  });

  group('GanttLayout.assignOneRowPerTask', () {
    List<TaskBar> oneRow(List<Task> tasks) => GanttLayout.assignOneRowPerTask(
      tasks,
      now: now,
      colorMode: BarColorMode.priority,
    );

    test('every dated task gets its own consecutive row', () {
      final bars = oneRow([
        Task(
          id: 'a',
          title: 'A',
          createdAt: DateTime.utc(2026, 6, 1),
          dueDate: DateTime.utc(2026, 6, 5),
        ),
        Task(
          id: 'b',
          title: 'B',
          createdAt: DateTime.utc(2026, 6, 2),
          dueDate: DateTime.utc(2026, 6, 5),
        ),
      ]);

      expect(bars.map((b) => b.rowIndex).toList(), [0, 1]);
    });

    test('manual ganttOrder takes priority over creation time', () {
      final bars = oneRow([
        Task(
          id: 'first-created',
          title: 'first',
          createdAt: DateTime.utc(2026, 6, 1),
          dueDate: DateTime.utc(2026, 6, 5),
          ganttOrder: 1,
        ),
        Task(
          id: 'later-created',
          title: 'later',
          createdAt: DateTime.utc(2026, 6, 9),
          dueDate: DateTime.utc(2026, 6, 5),
          ganttOrder: 0,
        ),
      ]);

      expect(bars.map((b) => b.task.id).toList(), [
        'later-created',
        'first-created',
      ]);
    });

    test('manually ordered rows sort before unordered ones', () {
      final bars = oneRow([
        Task(
          id: 'unordered',
          title: 'u',
          createdAt: DateTime.utc(2026, 6, 1),
          dueDate: DateTime.utc(2026, 6, 5),
        ),
        Task(
          id: 'ordered',
          title: 'o',
          createdAt: DateTime.utc(2026, 6, 9),
          dueDate: DateTime.utc(2026, 6, 5),
          ganttOrder: 0,
        ),
      ]);

      expect(bars.first.task.id, 'ordered');
    });

    test('dateless tasks are dropped', () {
      final bars = oneRow([const Task(id: 'x', title: 'No dates')]);
      expect(bars, isEmpty);
    });
  });

  group('color helpers', () {
    test('parseColor accepts #RRGGBB, #AARRGGBB and raw hex', () {
      expect(GanttLayout.parseColor('#FF0000'), const Color(0xFFFF0000));
      expect(GanttLayout.parseColor('#80FF0000'), const Color(0x80FF0000));
      expect(GanttLayout.parseColor('00FF00'), const Color(0xFF00FF00));
    });

    test('parseColor returns null for null/empty/garbage', () {
      expect(GanttLayout.parseColor(null), isNull);
      expect(GanttLayout.parseColor('   '), isNull);
      expect(GanttLayout.parseColor('nope'), isNull);
    });

    test('project color mode uses the project hue, saturation by priority', () {
      final high = Task(
        id: 'h',
        title: 'H',
        projectId: 'p1',
        priority: Priority.high,
        dueDate: DateTime.utc(2026, 6, 8),
      );
      final low = high.copyWith(id: 'l', priority: Priority.low);

      final bars = GanttLayout.assignOneRowPerTask(
        [high, low],
        now: now,
        colorMode: BarColorMode.project,
        projectColors: const {'p1': '#3366CC'},
      );
      final byId = {for (final b in bars) b.task.id: b.color};

      // Same project → same hue; differing priority → differing saturation.
      final hHsl = HSLColor.fromColor(byId['h']!);
      final lHsl = HSLColor.fromColor(byId['l']!);
      expect(hHsl.hue, closeTo(lHsl.hue, 0.5));
      expect(hHsl.saturation, greaterThan(lHsl.saturation));
    });

    test('project mode without dates/color falls back deterministically', () {
      final t = Task(
        id: 't',
        title: 'T',
        projectId: 'pX',
        dueDate: DateTime.utc(2026, 6, 8),
      );

      final a = GanttLayout.resolveColor(t, BarColorMode.project);
      final b = GanttLayout.resolveColor(t, BarColorMode.project);
      expect(a, b); // stable per project id
    });
  });
}
