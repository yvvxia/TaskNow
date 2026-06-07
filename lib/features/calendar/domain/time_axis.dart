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
}
