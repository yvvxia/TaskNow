import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/features/calendar/domain/time_axis.dart';

void main() {
  final origin = DateTime.utc(2026, 6, 1);
  const pxPerDay = 48.0;
  final axis = TimeAxis(origin: origin, pxPerDay: pxPerDay);

  group('TimeAxis', () {
    test('dateToDx is 0 at the origin', () {
      expect(axis.dateToDx(origin), 0);
    });

    test('dateToDx scales by pxPerDay per day', () {
      expect(axis.dateToDx(origin.add(const Duration(days: 1))), pxPerDay);
      expect(axis.dateToDx(origin.add(const Duration(days: 3))), pxPerDay * 3);
    });

    test('dx → date → dx roundtrip is stable on day boundaries', () {
      for (var day = 0; day < 10; day++) {
        final dx = day * pxPerDay;
        final back = axis.dateToDx(axis.dxToDate(dx));
        expect(back, closeTo(dx, 0.5));
      }
    });

    test('date → dx → date roundtrip preserves the date (minute rounding)', () {
      final d = origin.add(const Duration(days: 4));
      final round = axis.dxToDate(axis.dateToDx(d));
      expect(round, d);
    });

    test('snapToDay drops the time component', () {
      final d = DateTime(2026, 6, 7, 14, 35, 12);
      expect(axis.snapToDay(d), DateTime(2026, 6, 7));
    });

    test('snapToDay is idempotent', () {
      final snapped = axis.snapToDay(DateTime(2026, 6, 7, 9));
      expect(axis.snapToDay(snapped), snapped);
    });
  });
}
