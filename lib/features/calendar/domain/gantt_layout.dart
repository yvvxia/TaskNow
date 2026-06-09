import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../core/models/task.dart';
import 'task_bar.dart';

/// Greedy lane-assignment layout for task bars.
///
/// Tasks are normalized (`startDate ?? dueDate` .. `dueDate ?? startDate`),
/// sorted by start, then packed into the first non-conflicting lane so that
/// overlapping tasks land on distinct [TaskBar.rowIndex] values.
class GanttLayout {
  const GanttLayout._();

  static List<TaskBar> assign(
    List<Task> tasks, {
    required DateTimeRange range,
    required DateTime now,
    required BarColorMode colorMode,
    Map<String, String?> projectColors = const {},
  }) {
    final normalized = <_NormalizedTask>[];
    for (final task in tasks) {
      final start = task.startDate ?? task.dueDate;
      final end = task.dueDate ?? task.startDate;
      if (start == null || end == null) continue; // no dates → not on calendar
      normalized.add(_NormalizedTask(task, start, end));
    }
    normalized.sort((a, b) => a.start.compareTo(b.start));

    final laneEnds = <DateTime>[]; // current end time occupying each lane
    final bars = <TaskBar>[];
    for (final n in normalized) {
      var lane = laneEnds.indexWhere((end) => !n.start.isBefore(end));
      if (lane == -1) {
        lane = laneEnds.length;
        laneEnds.add(n.end);
      } else {
        laneEnds[lane] = n.end;
      }
      bars.add(
        TaskBar(
          task: n.task,
          barStart: n.start,
          barEnd: n.end,
          rowIndex: lane,
          isOverdue: n.task.statusAt(now) == TaskStatus.overdue,
          color: resolveColor(n.task, colorMode, projectColors: projectColors),
        ),
      );
    }
    return bars;
  }

  /// One-task-per-row layout for the Gantt view. Each task gets a dedicated
  /// row (no lane packing), ordered by manual [Task.ganttOrder] when present,
  /// otherwise by creation time. The resulting [TaskBar.rowIndex] is the task's
  /// position in that order.
  static List<TaskBar> assignOneRowPerTask(
    List<Task> tasks, {
    required DateTime now,
    required BarColorMode colorMode,
    Map<String, String?> projectColors = const {},
  }) {
    final dated = <_NormalizedTask>[];
    for (final task in tasks) {
      final start = task.startDate ?? task.dueDate;
      final end = task.dueDate ?? task.startDate;
      if (start == null || end == null) continue;
      dated.add(_NormalizedTask(task, start, end));
    }
    dated.sort(_byManualThenCreated);

    final bars = <TaskBar>[];
    for (var i = 0; i < dated.length; i++) {
      final n = dated[i];
      bars.add(
        TaskBar(
          task: n.task,
          barStart: n.start,
          barEnd: n.end,
          rowIndex: i,
          isOverdue: n.task.statusAt(now) == TaskStatus.overdue,
          color: resolveColor(n.task, colorMode, projectColors: projectColors),
        ),
      );
    }
    return bars;
  }

  /// Orders tasks by manual [Task.ganttOrder] (nulls last) then creation time.
  static int _byManualThenCreated(_NormalizedTask a, _NormalizedTask b) {
    final ga = a.task.ganttOrder;
    final gb = b.task.ganttOrder;
    if (ga != null && gb != null && ga != gb) return ga.compareTo(gb);
    if (ga != null && gb == null) return -1;
    if (ga == null && gb != null) return 1;
    final ca = a.task.createdAt;
    final cb = b.task.createdAt;
    if (ca == null && cb == null) return 0;
    if (ca == null) return 1;
    if (cb == null) return -1;
    return ca.compareTo(cb);
  }

  /// Number of lanes required to render [bars] (max rowIndex + 1).
  static int laneCount(List<TaskBar> bars) => bars.isEmpty
      ? 0
      : bars.map((b) => b.rowIndex).reduce((a, b) => a > b ? a : b) + 1;

  /// Resolves the bar color for [task] under [mode].
  ///
  /// In [BarColorMode.project] the hue comes from the owning project (its
  /// user-chosen [projectColors] entry, or a deterministic hue when unset) and
  /// the saturation encodes priority (high = vivid, low = muted) so the global
  /// calendar shows project by hue and priority by saturation.
  static Color resolveColor(
    Task task,
    BarColorMode mode, {
    Map<String, String?> projectColors = const {},
  }) {
    switch (mode) {
      case BarColorMode.priority:
        return priorityColor(task.priority);
      case BarColorMode.project:
        final projectId = task.projectId;
        if (projectId == null) return priorityColor(task.priority);
        final base = projectColors.containsKey(projectId)
            ? parseColor(projectColors[projectId]) ?? projectColor(projectId)
            : projectColor(projectId);
        return applyPrioritySaturation(base, task.priority);
    }
  }

  static Color priorityColor(Priority priority) =>
      SemanticColors.colorForPriority(priority);

  /// Deterministic color derived from a project id (stable hue per project).
  static Color projectColor(String projectId) {
    final hue = (projectId.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
  }

  /// Re-saturates [base] according to [priority]: high stays vivid, low is
  /// muted. Hue and lightness are preserved so the project stays recognizable.
  static Color applyPrioritySaturation(Color base, Priority priority) {
    final hsl = HSLColor.fromColor(base);
    final saturation = switch (priority) {
      Priority.high => 0.85,
      Priority.medium => 0.55,
      Priority.low => 0.28,
    };
    return hsl.withSaturation(saturation.clamp(0.0, 1.0)).toColor();
  }

  /// Parses a stored project color string. Accepts `#RRGGBB`, `#AARRGGBB`, or a
  /// raw ARGB integer string. Returns null when unparseable.
  static Color? parseColor(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }
}

class _NormalizedTask {
  const _NormalizedTask(this.task, this.start, this.end);

  final Task task;
  final DateTime start;
  final DateTime end;
}
