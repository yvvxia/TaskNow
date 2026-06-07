import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
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
          color: resolveColor(n.task, colorMode),
        ),
      );
    }
    return bars;
  }

  /// Number of lanes required to render [bars] (max rowIndex + 1).
  static int laneCount(List<TaskBar> bars) =>
      bars.isEmpty ? 0 : bars.map((b) => b.rowIndex).reduce((a, b) => a > b ? a : b) + 1;

  /// Resolves the bar color for [task] under [mode], falling back to priority
  /// color when project mode has no project to derive from.
  static Color resolveColor(Task task, BarColorMode mode) {
    switch (mode) {
      case BarColorMode.priority:
        return priorityColor(task.priority);
      case BarColorMode.project:
        final projectId = task.projectId;
        if (projectId == null) return priorityColor(task.priority);
        return projectColor(projectId);
    }
  }

  static Color priorityColor(Priority priority) => switch (priority) {
        Priority.high => const Color(0xFFE53935),
        Priority.medium => const Color(0xFFFB8C00),
        Priority.low => const Color(0xFF43A047),
      };

  /// Deterministic color derived from a project id (stable hue per project).
  static Color projectColor(String projectId) {
    final hue = (projectId.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.5).toColor();
  }
}

class _NormalizedTask {
  const _NormalizedTask(this.task, this.start, this.end);

  final Task task;
  final DateTime start;
  final DateTime end;
}
