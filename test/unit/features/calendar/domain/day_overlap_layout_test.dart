import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/features/calendar/domain/day_overlap_layout.dart';

void main() {
  group('DayOverlapLayout', () {
    test('no overlap assigns single column', () {
      final placements = DayOverlapLayout.assign([
        const TimedBarSegment(id: 'a', startMin: 60, endMin: 120),
        const TimedBarSegment(id: 'b', startMin: 180, endMin: 240),
      ]);

      expect(placements['a']!.column, 0);
      expect(placements['a']!.columns, 1);
      expect(placements['b']!.column, 0);
      expect(placements['b']!.columns, 1);
    });

    test('two overlapping bars get two columns', () {
      final placements = DayOverlapLayout.assign([
        const TimedBarSegment(id: 'a', startMin: 60, endMin: 180),
        const TimedBarSegment(id: 'b', startMin: 120, endMin: 240),
      ]);

      expect(placements['a']!.column, 0);
      expect(placements['a']!.columns, 2);
      expect(placements['b']!.column, 1);
      expect(placements['b']!.columns, 2);
    });

    test('chained overlaps share cluster column count', () {
      final placements = DayOverlapLayout.assign([
        const TimedBarSegment(id: 'a', startMin: 60, endMin: 180),
        const TimedBarSegment(id: 'b', startMin: 120, endMin: 240),
        const TimedBarSegment(id: 'c', startMin: 200, endMin: 300),
      ]);

      expect(placements['a']!.column, 0);
      expect(placements['a']!.columns, 2);
      expect(placements['b']!.column, 1);
      expect(placements['b']!.columns, 2);
      expect(placements['c']!.column, 0);
      expect(placements['c']!.columns, 2);
    });

    test('identical times get distinct columns', () {
      final placements = DayOverlapLayout.assign([
        const TimedBarSegment(id: 'a', startMin: 90, endMin: 150),
        const TimedBarSegment(id: 'b', startMin: 90, endMin: 150),
      ]);

      expect(placements['a']!.column, 0);
      expect(placements['a']!.columns, 2);
      expect(placements['b']!.column, 1);
      expect(placements['b']!.columns, 2);
    });

    test('separate clusters get independent column counts', () {
      final placements = DayOverlapLayout.assign([
        const TimedBarSegment(id: 'a', startMin: 60, endMin: 120),
        const TimedBarSegment(id: 'b', startMin: 90, endMin: 150),
        const TimedBarSegment(id: 'c', startMin: 300, endMin: 360),
        const TimedBarSegment(id: 'd', startMin: 330, endMin: 390),
      ]);

      expect(placements['a']!.column, 0);
      expect(placements['a']!.columns, 2);
      expect(placements['b']!.column, 1);
      expect(placements['b']!.columns, 2);
      expect(placements['c']!.column, 0);
      expect(placements['c']!.columns, 2);
      expect(placements['d']!.column, 1);
      expect(placements['d']!.columns, 2);
    });
  });
}
