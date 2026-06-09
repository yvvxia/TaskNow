import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/features/calendar/presentation/calendar_view_state_notifier.dart';

void main() {
  final frozen = DateTime.utc(2026, 6, 7);

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWith(
          (ref) =>
              () => frozen,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CalendarViewStateNotifier', () {
    test('initial state is week anchored on today', () {
      final container = makeContainer();
      final state = container.read(calendarViewStateProvider);
      expect(state.type, CalendarViewType.week);
      expect(state.anchor, frozen);
    });

    test('switchView keeps the anchor and recomputes the range', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);
      final before = container.read(calendarViewStateProvider).anchor;

      notifier.switchView(CalendarViewType.week);
      final after = container.read(calendarViewStateProvider);

      expect(after.type, CalendarViewType.week);
      expect(after.anchor, before);
      // Week window spans 7 days.
      expect(
        after.visibleRange.end.difference(after.visibleRange.start).inDays,
        6,
      );
    });

    test('switching across all views preserves the anchor', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);
      final anchor = container.read(calendarViewStateProvider).anchor;

      for (final type in CalendarViewType.values) {
        notifier.switchView(type);
        expect(container.read(calendarViewStateProvider).anchor, anchor);
      }
    });

    test('next() advances the week anchor', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);

      final before = container.read(calendarViewStateProvider).anchor;
      notifier.next();
      final after = container.read(calendarViewStateProvider).anchor;
      expect(after.difference(before).inDays, 7);
    });

    test('prev() steps the week anchor back', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);

      final before = container.read(calendarViewStateProvider).anchor;
      notifier.prev();
      final after = container.read(calendarViewStateProvider).anchor;
      expect(before.difference(after).inDays, 7);
    });

    test('next() in week view shifts by 7 days', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);

      notifier.switchView(CalendarViewType.week);
      final before = container.read(calendarViewStateProvider).anchor;
      notifier.next();
      final after = container.read(calendarViewStateProvider).anchor;

      expect(after.difference(before).inDays, 7);
    });

    test('goToToday resets the anchor', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);

      notifier.next();
      notifier.next();
      notifier.goToToday();

      expect(container.read(calendarViewStateProvider).anchor, frozen);
    });

    test('selectTask updates the selected id', () {
      final container = makeContainer();
      final notifier = container.read(calendarViewStateProvider.notifier);

      notifier.selectTask('task-1');
      expect(
        container.read(calendarViewStateProvider).selectedTaskId,
        'task-1',
      );

      notifier.selectTask(null);
      expect(container.read(calendarViewStateProvider).selectedTaskId, isNull);
    });
  });
}
