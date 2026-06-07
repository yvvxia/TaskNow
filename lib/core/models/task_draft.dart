import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';
import 'recurrence_rule.dart';
import 'subtask_draft.dart';

part 'task_draft.freezed.dart';

/// Input value object used to create a new [Task]. Has no id because the id is
/// assigned by the repository on creation.
@freezed
abstract class TaskDraft with _$TaskDraft {
  const factory TaskDraft({
    required String title,
    String? notes,
    String? projectId,
    DateTime? startDate,
    DateTime? dueDate,
    @Default(Priority.medium) Priority priority,
    @Default(<String>[]) List<String> tagIds,
    @Default(<SubtaskDraft>[]) List<SubtaskDraft> subtasks,
    RecurrenceRule? recurrence,
    @Default(false) bool autoCompleteOnSubtasks,
  }) = _TaskDraft;
}
