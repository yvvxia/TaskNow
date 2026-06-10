import 'task_bar.dart';

/// Horizontal date-axis bounds for the Gantt view.
///
/// Spans from the earliest task start through the latest task end (inclusive),
/// padded on both sides and clamped to a minimum span so the axis stays usable
/// even with a single-day task.
class GanttAxisWindow {
  const GanttAxisWindow({required this.origin, required this.dayCount});

  /// Local midnight at the left edge of the axis.
  final DateTime origin;

  /// Number of whole-day columns on the axis (inclusive of [origin]).
  final int dayCount;

  /// Total horizontal width in pixels for this axis at [pxPerDay].
  double widthPx(double pxPerDay) => dayCount * pxPerDay;

  /// Computes axis bounds from [bars], always including [now] as a reference
  /// day so "today" stays visible even when all tasks lie in the future/past.
  static GanttAxisWindow fromBars(
    List<TaskBar> bars, {
    required DateTime now,
    int padDays = 3,
    int minSpanDays = 14,
  }) {
    final today = DateTime(now.year, now.month, now.day);

    if (bars.isEmpty) {
      final origin = today.subtract(Duration(days: padDays));
      return GanttAxisWindow(
        origin: origin,
        dayCount: minSpanDays + padDays * 2,
      );
    }

    var earliest = bars.first.barStart;
    var latest = bars.first.barEnd;
    for (final bar in bars.skip(1)) {
      if (bar.barStart.isBefore(earliest)) earliest = bar.barStart;
      if (bar.barEnd.isAfter(latest)) latest = bar.barEnd;
    }

    // Include today so the user always has a temporal anchor.
    if (today.isBefore(earliest)) earliest = today;
    if (today.isAfter(latest)) latest = today;

    final startDay = DateTime(earliest.year, earliest.month, earliest.day);
    final endDay = DateTime(latest.year, latest.month, latest.day);
    final spanDays = endDay.difference(startDay).inDays + 1;
    final totalSpan = spanDays < minSpanDays ? minSpanDays : spanDays;

    final origin = startDay.subtract(Duration(days: padDays));
    return GanttAxisWindow(origin: origin, dayCount: totalSpan + padDays * 2);
  }
}
