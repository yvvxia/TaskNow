import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/clock.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/task_query.dart';
import '../domain/gantt_layout.dart';
import '../domain/task_bar.dart';
import 'calendar_view_state_notifier.dart';

part 'calendar_providers.g.dart';

/// Active bar-color strategy. Defaults to [BarColorMode.priority]; a future
/// settings field can drive this without touching consumers.
@riverpod
BarColorMode barColorMode(Ref ref) => BarColorMode.priority;

/// Streams the laid-out task bars for the current visible range. Watches the
/// calendar window and re-queries via [TaskQuery.rangeOverlap] so only tasks
/// intersecting the window are loaded.
@riverpod
Stream<List<TaskBar>> visibleBars(Ref ref) {
  final view = ref.watch(calendarViewStateProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final colorMode = ref.watch(barColorModeProvider);
  final now = ref.watch(clockProvider)();

  return repo.watch(TaskQuery.rangeOverlap(view.visibleRange)).map(
        (tasks) => GanttLayout.assign(
          tasks,
          range: view.visibleRange,
          now: now,
          colorMode: colorMode,
        ),
      );
}
