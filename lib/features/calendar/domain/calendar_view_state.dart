import 'package:flutter/material.dart' show DateTimeRange;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/enums/enums.dart';

part 'calendar_view_state.freezed.dart';

/// Shared window state for the calendar / Gantt screen.
///
/// [anchor] is the local reference date for the current window; [visibleRange]
/// is derived from [anchor] + [type] and is what range queries use. Switching
/// [type] keeps [anchor] stable (proposal §3.2.5) and only recomputes the
/// derived [visibleRange].
@freezed
abstract class CalendarViewState with _$CalendarViewState {
  const factory CalendarViewState({
    required CalendarViewType type,
    required DateTime anchor,
    required DateTimeRange visibleRange,
    String? selectedTaskId,
  }) = _CalendarViewState;
}
