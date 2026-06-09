import 'package:flutter/material.dart' show DateTimeRange;

import '../../../core/enums/enums.dart';

/// Pure date-window math shared by the view-state notifier and tests.
///
/// Ranges are half-open-ish inclusive: `start` is local midnight and `end` is
/// the last millisecond of the window so overlap queries behave intuitively.
class CalendarWindow {
  const CalendarWindow._();

  /// Computes the visible range for [type] anchored on [anchor].
  static DateTimeRange rangeFor(CalendarViewType type, DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    switch (type) {
      case CalendarViewType.day:
        return DateTimeRange(
          start: day,
          end: _endOf(day.add(const Duration(days: 1))),
        );
      case CalendarViewType.week:
        final start = day.subtract(Duration(days: day.weekday - 1));
        return DateTimeRange(
          start: start,
          end: _endOf(start.add(const Duration(days: 7))),
        );
      case CalendarViewType.month:
        final start = DateTime(anchor.year, anchor.month, 1);
        final nextMonth = DateTime(anchor.year, anchor.month + 1, 1);
        return DateTimeRange(start: start, end: _endOf(nextMonth));
      case CalendarViewType.gantt:
        // Four-week window beginning on the Monday of the anchor's week.
        final start = day.subtract(Duration(days: day.weekday - 1));
        return DateTimeRange(
          start: start,
          end: _endOf(start.add(const Duration(days: 28))),
        );
    }
  }

  /// Shifts [anchor] by one window in [dir] (`+1` next, `-1` prev).
  static DateTime shiftAnchor(CalendarViewType type, DateTime anchor, int dir) {
    switch (type) {
      case CalendarViewType.day:
        return anchor.add(Duration(days: dir));
      case CalendarViewType.week:
        return anchor.add(Duration(days: 7 * dir));
      case CalendarViewType.gantt:
        return anchor.add(Duration(days: 28 * dir));
      case CalendarViewType.month:
        return DateTime(anchor.year, anchor.month + dir, anchor.day);
    }
  }

  static DateTime _endOf(DateTime exclusiveEnd) =>
      exclusiveEnd.subtract(const Duration(milliseconds: 1));
}
