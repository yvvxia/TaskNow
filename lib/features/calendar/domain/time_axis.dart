/// Maps between pixel positions and dates along a horizontal timeline.
///
/// Used by the Gantt and week views to lay out bars and to translate drag
/// gestures back into dates.
class TimeAxis {
  const TimeAxis({required this.origin, required this.pxPerDay});

  /// The date at `dx == 0` (left edge of the timeline).
  final DateTime origin;

  /// Horizontal pixels per calendar day (changes with zoom level).
  final double pxPerDay;

  /// Horizontal offset (in pixels) for [d] relative to [origin].
  double dateToDx(DateTime d) =>
      d.difference(origin).inMinutes / 1440 * pxPerDay;

  /// Date at horizontal offset [dx], rounded to the nearest minute.
  DateTime dxToDate(double dx) =>
      origin.add(Duration(minutes: (dx / pxPerDay * 1440).round()));

  /// Snaps [d] down to its day boundary (local midnight).
  DateTime snapToDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Pixel x of the left edge of the whole-day column that contains [d].
  ///
  /// Day-granularity views (Gantt, week) must align bars to whole-day cells.
  /// Without this, a task carrying a time-of-day component (e.g. due 14:00)
  /// would render past its day boundary and visually spill into the next
  /// column — looking like an extra day. Flooring to the day fixes that while
  /// leaving date-only tasks (already at midnight) unchanged.
  double dayStartDx(DateTime d) => (dateToDx(d) / pxPerDay).floor() * pxPerDay;

  /// Pixel x of the right edge (exclusive) of the whole-day column containing
  /// [d] — i.e. the start of the following day. Use for the right edge of an
  /// inclusive day-range bar so the bar covers exactly through [d]'s day.
  double dayEndDx(DateTime d) => dayStartDx(d) + pxPerDay;
}
