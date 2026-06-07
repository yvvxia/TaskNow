import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/task.dart';

/// Presentation-layer view-model that wraps [Task] and exposes computed
/// properties used by the UI (localized strings, derived flags, etc.).
class TaskView {
  const TaskView({required this.task, required this.now});

  final Task task;

  /// The point-in-time used to derive [isOverdue] and [statusLabel].
  final DateTime now;

  factory TaskView.from(Task task, DateTime now) =>
      TaskView(task: task, now: now);

  // ---- Delegated identity -------------------------------------------------

  String get id => task.id;
  String get title => task.title;
  String? get notes => task.notes;
  Priority get priority => task.priority;

  // ---- Derived properties -------------------------------------------------

  bool get isOverdue => task.statusAt(now) == TaskStatus.overdue;
  bool get isCompleted => task.status == TaskStatus.complete;

  /// Localized stub: returns the status enum name (e.g. "incomplete").
  String get statusLabel {
    switch (task.statusAt(now)) {
      case TaskStatus.complete:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
      case TaskStatus.incomplete:
        return 'Incomplete';
    }
  }

  /// E.g. "2/5" when 2 of 5 subtasks are done. Empty string when there are no
  /// subtasks.
  String get subtaskBadge {
    if (task.subtasks.isEmpty) return '';
    final done = task.subtasks.where((s) => s.isDone).length;
    return '$done/${task.subtasks.length}';
  }

  /// Formatted date range. Uses the due date only when there is no start date.
  String get dateRangeLabel {
    if (task.dueDate == null && task.startDate == null) return '';

    final fmt = DateFormat.yMd();
    if (task.startDate != null && task.dueDate != null) {
      return '${fmt.format(task.startDate!)} – ${fmt.format(task.dueDate!)}';
    }
    if (task.dueDate != null) return fmt.format(task.dueDate!);
    return fmt.format(task.startDate!);
  }
}
