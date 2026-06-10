import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/calendar/domain/gantt_axis_window.dart';
import 'package:liveline/features/calendar/domain/task_bar.dart';

TaskBar _bar(String id, DateTime start, DateTime end) => TaskBar(
  task: Task(id: id, title: id, startDate: start, dueDate: end),
  barStart: start,
  barEnd: end,
  rowIndex: 0,
  isOverdue: false,
  color: Colors.blue,
);

void main() {
  group('GanttAxisWindow.fromBars', () {
    test('empty bars yields padded window around today', () {
      final now = DateTime(2026, 6, 15);
      final window = GanttAxisWindow.fromBars([], now: now);

      expect(window.origin, DateTime(2026, 6, 12));
      expect(window.dayCount, 20); // minSpan 14 + pad 3 each side
    });

    test('spans earliest bar start through latest bar end with padding', () {
      final now = DateTime(2026, 6, 15);
      final bars = [
        _bar('a', DateTime(2026, 6, 1), DateTime(2026, 6, 5)),
        _bar('b', DateTime(2026, 6, 10), DateTime(2026, 6, 20)),
      ];
      final window = GanttAxisWindow.fromBars(bars, now: now);

      expect(window.origin, DateTime(2026, 5, 29)); // Jun 1 - 3 pad
      // Jun 1 .. Jun 20 = 20 days + 6 pad = 26
      expect(window.dayCount, 26);
    });

    test('extends to include today when tasks are all in the future', () {
      final now = DateTime(2026, 6, 1);
      final bars = [_bar('a', DateTime(2026, 6, 10), DateTime(2026, 6, 12))];
      final window = GanttAxisWindow.fromBars(bars, now: now);

      expect(window.origin.isBefore(DateTime(2026, 6, 1)), isTrue);
      final lastDay = window.origin.add(Duration(days: window.dayCount - 1));
      expect(lastDay.isAfter(DateTime(2026, 6, 12)), isTrue);
      expect(
        lastDay.difference(DateTime(2026, 6, 1)).inDays,
        greaterThanOrEqualTo(13),
      );
    });

    test('enforces minimum span for a single-day task', () {
      final now = DateTime(2026, 6, 15);
      final bars = [_bar('a', DateTime(2026, 6, 15), DateTime(2026, 6, 15))];
      final window = GanttAxisWindow.fromBars(bars, now: now, minSpanDays: 14);

      expect(window.dayCount, 20); // 14 + 3 + 3
    });

    test('widthPx is dayCount times pxPerDay', () {
      final window = GanttAxisWindow(
        origin: DateTime(2026, 6, 1),
        dayCount: 10,
      );
      expect(window.widthPx(48), 480);
    });
  });
}
