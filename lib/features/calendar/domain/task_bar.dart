import 'package:flutter/material.dart' show Color;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/task.dart';

part 'task_bar.freezed.dart';

/// How task-bar colors are resolved in calendar / Gantt views.
enum BarColorMode {
  /// Color encodes the task priority (default).
  priority,

  /// Color is derived from the owning project.
  project,
}

/// A single laid-out task bar for the Gantt / timeline views.
///
/// [barStart] and [barEnd] are normalized dates: `startDate ?? dueDate` and
/// `dueDate ?? startDate` respectively, so a task with only one date renders as
/// a single-day bar (proposal §3.2.2). [rowIndex] is the lane assigned by
/// [GanttLayout] to avoid overlaps.
@freezed
abstract class TaskBar with _$TaskBar {
  const factory TaskBar({
    required Task task,
    required DateTime barStart,
    required DateTime barEnd,
    required int rowIndex,
    required bool isOverdue,
    required Color color,
  }) = _TaskBar;
}
