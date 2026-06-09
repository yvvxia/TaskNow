import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/features/calendar/domain/time_axis.dart';

/// Regression tests for the Gantt/week "extra day" bug: a task carrying a
/// time-of-day component must still align to whole-day columns instead of
/// spilling into the next day.
void main() {
  final origin = DateTime(2026, 6, 8); // local Monday, window start
  const pxPerDay = 48.0;
  final axis = TimeAxis(origin: origin, pxPerDay: pxPerDay);

  group('day-column snapping', () {
    test('date-only task occupies exactly one day cell', () {
      final day = DateTime(2026, 6, 10).toUtc(); // as the DB round-trips it
      expect(axis.dayStartDx(day), closeTo(2 * pxPerDay, 0.001));
      expect(axis.dayEndDx(day), closeTo(3 * pxPerDay, 0.001));
    });

    test('timed task does NOT spill past its day boundary', () {
      // Local June 10, 14:00 (has a time component).
      final timed = DateTime(2026, 6, 10, 14, 0).toUtc();
      // Left snaps to the start of June 10; right ends at the start of June 11.
      expect(axis.dayStartDx(timed), closeTo(2 * pxPerDay, 0.001));
      expect(axis.dayEndDx(timed), closeTo(3 * pxPerDay, 0.001));
    });

    test('late-evening timed task still ends on the same day', () {
      final late = DateTime(2026, 6, 10, 23, 30).toUtc();
      expect(axis.dayEndDx(late), closeTo(3 * pxPerDay, 0.001));
    });

    test('multi-day inclusive range spans the right number of cells', () {
      final start = DateTime(2026, 6, 10).toUtc();
      final end = DateTime(2026, 6, 12, 9, 0).toUtc(); // due with a time
      final width = axis.dayEndDx(end) - axis.dayStartDx(start);
      expect(width, closeTo(3 * pxPerDay, 0.001)); // June 10, 11, 12
    });
  });
}
