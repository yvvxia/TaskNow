import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/clock.dart';
import '../../../core/enums/enums.dart';
import '../domain/calendar_view_state.dart';
import '../domain/calendar_window.dart';

part 'calendar_view_state_notifier.g.dart';

/// Owns the shared calendar window: view type, anchor date, derived visible
/// range, and the currently selected task. Switching the view preserves the
/// [CalendarViewState.anchor] so the time window stays consistent (design §7).
@Riverpod(keepAlive: true)
class CalendarViewStateNotifier extends _$CalendarViewStateNotifier {
  @override
  CalendarViewState build() {
    final now = ref.watch(clockProvider)();
    const type = CalendarViewType.week;
    return CalendarViewState(
      type: type,
      anchor: now,
      visibleRange: CalendarWindow.rangeFor(type, now),
    );
  }

  /// Switches to [type] while keeping [anchor]; recomputes the visible range.
  void switchView(CalendarViewType type) {
    state = state.copyWith(
      type: type,
      visibleRange: CalendarWindow.rangeFor(type, state.anchor),
    );
  }

  /// Opens the day view anchored on [day] (used when a calendar cell is
  /// tapped). Anchors on local midnight of the tapped day.
  void openDay(DateTime day) {
    final anchor = DateTime(day.year, day.month, day.day);
    state = state.copyWith(
      type: CalendarViewType.day,
      anchor: anchor,
      visibleRange: CalendarWindow.rangeFor(CalendarViewType.day, anchor),
    );
  }

  /// Advances to the next day/week/month/window.
  void next() => _shift(1);

  /// Steps back to the previous day/week/month/window.
  void prev() => _shift(-1);

  /// Resets the anchor to today (keeps the current view type).
  void goToToday() {
    final now = ref.read(clockProvider)();
    state = state.copyWith(
      anchor: now,
      visibleRange: CalendarWindow.rangeFor(state.type, now),
    );
  }

  /// Selects (or clears, when [id] is null) the highlighted task.
  void selectTask(String? id) => state = state.copyWith(selectedTaskId: id);

  void _shift(int dir) {
    final anchor = CalendarWindow.shiftAnchor(state.type, state.anchor, dir);
    state = state.copyWith(
      anchor: anchor,
      visibleRange: CalendarWindow.rangeFor(state.type, anchor),
    );
  }
}
