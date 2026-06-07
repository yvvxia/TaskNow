import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/recurrence_rule.dart';
import 'package:plan_list/core/models/subtask.dart';
import 'package:plan_list/core/models/task.dart';

int _seq = 0;

/// Resets the auto-increment id counter (call in `setUp` for stable ids).
void resetTaskSeq() => _seq = 0;

/// Builds a [Task] with sensible test defaults, overriding only what a given
/// test cares about (`design/07-testing-strategy.md` §5).
Task aTask({
  String? id,
  String title = 'Test task',
  String? notes,
  String? projectId,
  bool completed = false,
  DateTime? start,
  DateTime? due,
  Priority priority = Priority.medium,
  int sortOrder = 0,
  List<String> tagIds = const [],
  List<Subtask> subtasks = const [],
  RecurrenceRule? recurrence,
  String? recurrenceParent,
  bool autoCompleteOnSubtasks = false,
  DateTime? createdAt,
}) {
  return Task(
    id: id ?? 'task-${_seq++}',
    title: title,
    notes: notes,
    projectId: projectId,
    startDate: start,
    dueDate: due,
    createdAt: createdAt ?? DateTime.utc(2026, 6, 1),
    completedAt: completed ? DateTime.utc(2026, 6, 1) : null,
    priority: priority,
    status: completed ? TaskStatus.complete : TaskStatus.incomplete,
    sortOrder: sortOrder,
    tagIds: tagIds,
    subtasks: subtasks,
    recurrence: recurrence,
    recurrenceParent: recurrenceParent,
    autoCompleteOnSubtasks: autoCompleteOnSubtasks,
  );
}
