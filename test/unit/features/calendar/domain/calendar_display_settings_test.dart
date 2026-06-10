import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/features/calendar/domain/calendar_display_settings.dart';
import 'package:liveline/features/calendar/domain/task_bar.dart';

void main() {
  group('CalendarDisplaySettings', () {
    test('defaults show completed, priority color, no filters', () {
      const s = CalendarDisplaySettings();
      expect(s.showCompleted, isTrue);
      expect(s.colorMode, BarColorMode.priority);
      expect(s.hasFilters, isFalse);
    });

    test('hasFilters reflects project or tag filters', () {
      expect(
        const CalendarDisplaySettings(projectIds: {'p1'}).hasFilters,
        isTrue,
      );
      expect(
        const CalendarDisplaySettings(tagIds: {'t1'}).hasFilters,
        isTrue,
      );
    });

    test('copyWith overrides only the given fields', () {
      const base = CalendarDisplaySettings();
      final next = base.copyWith(
        showCompleted: false,
        colorMode: BarColorMode.project,
        projectIds: {'p1'},
      );
      expect(next.showCompleted, isFalse);
      expect(next.colorMode, BarColorMode.project);
      expect(next.projectIds, {'p1'});
      expect(next.tagIds, isEmpty);
    });

    test('value equality ignores set ordering', () {
      const a = CalendarDisplaySettings(projectIds: {'p1', 'p2'});
      const b = CalendarDisplaySettings(projectIds: {'p2', 'p1'});
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
