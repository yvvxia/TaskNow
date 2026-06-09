import '../../core/enums/enums.dart';
import '../../core/models/task.dart';
import '../../core/models/task_draft.dart';
import '../db/app_database.dart';
import 'time_mapper.dart';

/// Pure, bidirectional mapping between [TaskRow] (persistence) and [Task]
/// (domain entity). The database persists a boolean `is_completed`; the
/// OVERDUE status is derived elsewhere, so a row only ever maps back to
/// [TaskStatus.complete] or [TaskStatus.incomplete].
abstract final class TaskMapper {
  /// Maps a persistence row (plus its linked [tagIds]) to a domain entity.
  static Task toEntity(TaskRow row, {List<String> tagIds = const <String>[]}) {
    return Task(
      id: row.id,
      title: row.title,
      notes: row.notes,
      projectId: row.projectId,
      startDate: dateTimeFromUtcMsOrNull(row.startDate),
      dueDate: dateTimeFromUtcMsOrNull(row.dueDate),
      createdAt: dateTimeFromUtcMs(row.createdAt),
      completedAt: dateTimeFromUtcMsOrNull(row.completedAt),
      priority: _priorityFromIndex(row.priority),
      status: row.isCompleted ? TaskStatus.complete : TaskStatus.incomplete,
      sortOrder: row.sortOrder,
      ganttOrder: row.ganttOrder,
      recurrenceRuleId: row.recurrenceRuleId,
      recurrenceParent: row.recurrenceParent,
      autoCompleteOnSubtasks: row.autoCompleteOnSubtasks,
      tagIds: List<String>.unmodifiable(tagIds),
      updatedAt: dateTimeFromUtcMs(row.updatedAt),
      deletedAt: dateTimeFromUtcMsOrNull(row.deletedAt),
      syncVersion: row.syncVersion,
      deviceId: row.deviceId,
    );
  }

  /// Maps a domain entity to a persistence row. `createdAt`/`updatedAt` must be
  /// populated by the caller (the repository) before mapping; if absent they
  /// fall back to the epoch so the mapper stays pure.
  static TaskRow toRow(Task task) {
    return TaskRow(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      notes: task.notes,
      startDate: task.startDate.msUtcOrNull,
      dueDate: task.dueDate.msUtcOrNull,
      createdAt: task.createdAt?.msUtc ?? 0,
      completedAt: task.completedAt.msUtcOrNull,
      priority: task.priority.index,
      isCompleted: task.status == TaskStatus.complete,
      sortOrder: task.sortOrder,
      ganttOrder: task.ganttOrder,
      recurrenceRuleId: task.recurrenceRuleId,
      recurrenceParent: task.recurrenceParent,
      autoCompleteOnSubtasks: task.autoCompleteOnSubtasks,
      updatedAt: task.updatedAt?.msUtc ?? task.createdAt?.msUtc ?? 0,
      deletedAt: task.deletedAt.msUtcOrNull,
      syncVersion: task.syncVersion,
      deviceId: task.deviceId,
    );
  }

  /// Builds a fresh [Task] entity from a [TaskDraft], assigning [id] and
  /// stamping [now] onto created/updated timestamps.
  static Task fromDraft(
    TaskDraft draft, {
    required String id,
    required DateTime now,
  }) {
    final nowUtc = now.toUtc();
    return Task(
      id: id,
      title: draft.title,
      notes: draft.notes,
      projectId: draft.projectId,
      startDate: draft.startDate?.toUtc(),
      dueDate: draft.dueDate?.toUtc(),
      createdAt: nowUtc,
      updatedAt: nowUtc,
      priority: draft.priority,
      tagIds: List<String>.unmodifiable(draft.tagIds),
      autoCompleteOnSubtasks: draft.autoCompleteOnSubtasks,
      recurrence: draft.recurrence,
    );
  }

  static Priority _priorityFromIndex(int index) {
    final i = index.clamp(0, Priority.values.length - 1);
    return Priority.values[i];
  }
}
