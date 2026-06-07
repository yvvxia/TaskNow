import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/data/mappers/time_mapper.dart';

void main() {
  group('time_mapper', () {
    test('dateTimeFromUtcMs builds a UTC DateTime', () {
      final dt = dateTimeFromUtcMs(0);
      expect(dt.isUtc, isTrue);
      expect(dt, DateTime.utc(1970));
    });

    test('round-trips an arbitrary instant', () {
      final original = DateTime.utc(2026, 6, 7, 14, 30, 15, 250);
      final ms = original.msUtc;
      expect(dateTimeFromUtcMs(ms), original);
    });

    test('msUtc normalizes local DateTime to UTC', () {
      final local = DateTime(2026, 1, 1, 12);
      expect(local.msUtc, local.toUtc().millisecondsSinceEpoch);
    });

    test('nullable helpers pass null through', () {
      expect(dateTimeFromUtcMsOrNull(null), isNull);
      const DateTime? nothing = null;
      expect(nothing.msUtcOrNull, isNull);
      expect(dateTimeFromUtcMsOrNull(1000), DateTime.utc(1970, 1, 1, 0, 0, 1));
    });
  });
}
