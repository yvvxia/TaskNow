import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/clock.dart';
import '../../../core/di/providers.dart';
import '../../../core/models/setting_keys.dart';
import '../../../core/models/task.dart';
import '../../settings/settings_providers.dart';
import '../../../core/models/task_query.dart';
import '../../project/project_providers.dart';
import '../domain/gantt_layout.dart';
import '../domain/reorder_gantt_usecase.dart';
import '../domain/task_bar.dart';
import 'calendar_display_settings_notifier.dart';
import 'calendar_view_state_notifier.dart';

part 'calendar_providers.g.dart';

/// Active bar-color strategy. Defaults to [BarColorMode.priority]; a future
/// settings field can drive this without touching consumers.
@riverpod
BarColorMode barColorMode(Ref ref) {
  ref.watch(settingsNotifierProvider);
  try {
    final mode = ref.read(settingsStoreProvider).get(SettingKeys.barColorMode);
    return mode == 'project' ? BarColorMode.project : BarColorMode.priority;
  } catch (_) {
    return BarColorMode.priority;
  }
}

/// Map of project id → stored color string, used to color the global calendar
/// by project.
@riverpod
Map<String, String?> projectColors(Ref ref) {
  final projects = ref.watch(projectListProvider).asData?.value ?? const [];
  return {for (final p in projects) p.id: p.color};
}

/// Streams the laid-out task bars for the current visible range, optionally
/// scoped to a single [projectId] (null = all projects / global calendar).
///
/// When scoped to a project, bars are colored by priority; on the global
/// calendar they are colored by project hue with priority saturation.
@riverpod
Stream<List<TaskBar>> visibleBars(Ref ref, String? projectId) {
  final view = ref.watch(calendarViewStateProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final colors = ref.watch(projectColorsProvider);
  final display = ref.watch(calendarDisplaySettingsProvider);

  var query = projectId == null
      ? TaskQuery.rangeOverlap(view.visibleRange)
      : TaskQuery.rangeOverlap(
          view.visibleRange,
        ).copyWith(projectId: projectId);
  query = query.copyWith(
    includeCompleted: display.showCompleted,
    tagIds: display.tagIds.toList(),
    // List filter only applies to the global calendar; a project-scoped
    // calendar is already constrained to its own project.
    projectIds: projectId == null ? display.projectIds : const <String>{},
  );

  return repo
      .watch(query)
      .map(
        (tasks) => GanttLayout.assign(
          tasks,
          range: view.visibleRange,
          now: now,
          colorMode: display.colorMode,
          projectColors: colors,
        ),
      );
}

/// Streams one-task-per-row Gantt bars for all dated tasks in scope,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time. The horizontal axis is derived from
/// the task date span in [GanttView], not from [calendarViewStateProvider].
@riverpod
Stream<List<TaskBar>> ganttBars(Ref ref, String? projectId) {
  final repo = ref.watch(taskRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final colors = ref.watch(projectColorsProvider);
  final display = ref.watch(calendarDisplaySettingsProvider);

  final query = TaskQuery(
    includeCompleted: display.showCompleted,
    projectId: projectId,
    tagIds: display.tagIds.toList(),
    projectIds: projectId == null ? display.projectIds : const <String>{},
  );

  return repo
      .watch(query)
      .map(
        (tasks) => GanttLayout.assignOneRowPerTask(
          tasks,
          now: now,
          colorMode: display.colorMode,
          projectColors: colors,
        ),
      );
}

/// Streams undated ("unscheduled") tasks — those with neither a start nor a
/// due date — for the quick-arrange panel. Excludes completed tasks.
@riverpod
Stream<List<Task>> unscheduledTasks(Ref ref, String? projectId) {
  final repo = ref.watch(taskRepositoryProvider);
  final query = TaskQuery(includeCompleted: false, projectId: projectId);
  return repo
      .watch(query)
      .map(
        (tasks) => tasks
            .where((t) => t.startDate == null && t.dueDate == null)
            .toList(),
      );
}

/// Use case that persists Gantt-row reordering.
@riverpod
ReorderGanttUseCase reorderGanttUseCase(Ref ref) =>
    ReorderGanttUseCase(ref.watch(taskRepositoryProvider));
