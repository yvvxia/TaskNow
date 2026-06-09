import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';
import 'recurrence_rule.dart';
import 'subtask.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Task entity. Carries the persisted columns owned by the data layer
/// (module 01) plus the relational `tagIds`. Kept immutable per global
/// conventions. `status` is the user-facing lifecycle; the database persists a
/// boolean `is_completed` and derives `overdue` at read time.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? notes,
    String? projectId,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    @Default(Priority.medium) Priority priority,
    @Default(TaskStatus.incomplete) TaskStatus status,
    @Default(0) int sortOrder,

    /// Manual ordering of this task's row in the Gantt view, independent of
    /// [sortOrder]. Null means "not manually ordered" (falls back to creation
    /// time).
    int? ganttOrder,
    String? recurrenceRuleId,
    String? recurrenceParent,
    @Default(false) bool autoCompleteOnSubtasks,

    /// IDs of tags linked to this task (M2M via `task_tags`).
    @Default(<String>[]) List<String> tagIds,

    /// Subtasks (checklist items). Not persisted in M2; carried in-memory by
    /// use cases and the presentation layer.
    @Default(<Subtask>[]) List<Subtask> subtasks,

    /// Embedded recurrence rule. Not persisted via [recurrenceRuleId] column;
    /// use cases seed this directly when they need recurrence logic.
    RecurrenceRule? recurrence,

    // --- Sync-reserved fields (Phase 2). See proposal §4.4. ---
    DateTime? updatedAt,
    DateTime? deletedAt,
    @Default(0) int syncVersion,
    String? deviceId,
  }) = _Task;

  const Task._();

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// Derived status: OVERDUE is computed at call time, never persisted.
  TaskStatus statusAt(DateTime now) {
    if (status == TaskStatus.complete) return TaskStatus.complete;
    if (dueDate != null && now.isAfter(dueDate!)) return TaskStatus.overdue;
    return TaskStatus.incomplete;
  }

  /// Fraction of subtasks that are done. Returns 0 when there are no subtasks.
  double get subtaskProgress => subtasks.isEmpty
      ? 0
      : subtasks.where((s) => s.isDone).length / subtasks.length;

  /// True if this task belongs to a recurrence series.
  bool get isRecurring => recurrenceRuleId != null || recurrence != null;
}
