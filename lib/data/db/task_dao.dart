import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../core/models/task_query.dart';
import 'app_database.dart';
import 'tables.dart';

part 'task_dao.g.dart';

/// Data-access object for tasks and their immediate relations. Encapsulates the
/// non-trivial SQL (range overlap, dynamic filtering, FTS) so it can be unit
/// tested in isolation from the repository mapping layer.
@DriftAccessor(tables: [Tasks, Subtasks, TaskTags, Tags, Reminders])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Range-overlap predicate: a (non-deleted) task intersects `[fromMs, toMs]`
  /// when its effective start `<= toMs` and its effective end `>= fromMs`,
  /// where a missing start defaults to the due date and vice versa. Tasks with
  /// neither date are excluded.
  Expression<bool> _inRange(Tasks t, int fromMs, int toMs) {
    final effStart = coalesce([t.startDate, t.dueDate]);
    final effEnd = coalesce([t.dueDate, t.startDate]);
    return t.deletedAt.isNull() &
        effStart.isSmallerOrEqualValue(toMs) &
        effEnd.isBiggerOrEqualValue(fromMs);
  }

  /// Reactive range query for calendar & Gantt.
  Stream<List<TaskRow>> watchInRange(int fromMs, int toMs) {
    return (select(tasks)
          ..where((t) => _inRange(t, fromMs, toMs))
          ..orderBy([(t) => OrderingTerm(expression: t.startDate)]))
        .watch();
  }

  /// One-shot range query.
  Future<List<TaskRow>> getInRange(int fromMs, int toMs) {
    return (select(tasks)
          ..where((t) => _inRange(t, fromMs, toMs))
          ..orderBy([(t) => OrderingTerm(expression: t.startDate)]))
        .get();
  }

  /// Builds a dynamic query from a [TaskQuery]. Always excludes soft-deleted
  /// rows. `nowMs` is used to evaluate the derived OVERDUE status.
  Selectable<TaskRow> buildQuery(TaskQuery q, {required int nowMs}) {
    final query = select(tasks)..where((t) => t.deletedAt.isNull());

    switch (q.status) {
      case TaskStatus.complete:
        query.where((t) => t.isCompleted.equals(true));
      case TaskStatus.incomplete:
        query.where((t) => t.isCompleted.equals(false));
      case TaskStatus.overdue:
        query.where(
          (t) =>
              t.isCompleted.equals(false) &
              t.dueDate.isNotNull() &
              t.dueDate.isSmallerThanValue(nowMs),
        );
      case null:
        break;
    }

    if (q.priority != null) {
      query.where((t) => t.priority.equals(q.priority!.index));
    }
    if (q.projectId != null) {
      query.where((t) => t.projectId.equals(q.projectId!));
    }
    if (q.tagIds.isNotEmpty) {
      final tagSub = selectOnly(taskTags)
        ..addColumns([taskTags.taskId])
        ..where(taskTags.tagId.isIn(q.tagIds));
      query.where((t) => t.id.isInQuery(tagSub));
    }

    switch (q.sort) {
      case TaskSort.dueDate:
      case TaskSort.dueAsc:
        query.orderBy([(t) => OrderingTerm(expression: t.dueDate)]);
      case TaskSort.dueDesc:
        query.orderBy([
          (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
        ]);
      case TaskSort.priority:
      case TaskSort.priorityDesc:
        query.orderBy([(t) => OrderingTerm(expression: t.priority)]);
      case TaskSort.createdAt:
      case TaskSort.createdDesc:
        query.orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      case TaskSort.manual:
        query.orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    }
    return query;
  }

  /// Full-text search over `title + notes`, excluding soft-deleted rows,
  /// ordered by FTS `rank`.
  Future<List<TaskRow>> searchFts(String matchExpr) {
    return customSelect(
      'SELECT t.* FROM tasks t '
      'JOIN tasks_fts f ON f.rowid = t.rowid '
      'WHERE tasks_fts MATCH ?1 AND t.deleted_at IS NULL '
      'ORDER BY rank',
      variables: [Variable.withString(matchExpr)],
      readsFrom: {tasks},
    ).map((row) => tasks.map(row.data)).get();
  }

  /// Inserts or updates a task and replaces its tag links atomically.
  Future<void> upsertTask(TaskRow row, List<String> tagIds) async {
    await transaction(() async {
      await into(tasks).insertOnConflictUpdate(row);
      await (delete(taskTags)..where((tt) => tt.taskId.equals(row.id))).go();
      if (tagIds.isNotEmpty) {
        await batch((b) {
          b.insertAll(
            taskTags,
            tagIds
                .map((tagId) => TaskTagRow(taskId: row.id, tagId: tagId))
                .toList(),
          );
        });
      }
    });
  }

  /// Finds a non-deleted task by id.
  Future<TaskRow?> findById(String id) {
    return (select(
      tasks,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// Finds a task by id regardless of soft-delete state.
  Future<TaskRow?> findByIdIncludingDeleted(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Persists manual Gantt-row ordering for a set of tasks. Each entry maps a
  /// task id to its new [Tasks.ganttOrder] index. Applied atomically.
  Future<void> setGanttOrders(Map<String, int> orderByTaskId, int nowMs) async {
    if (orderByTaskId.isEmpty) return;
    await transaction(() async {
      for (final entry in orderByTaskId.entries) {
        await (update(tasks)..where((t) => t.id.equals(entry.key))).write(
          TasksCompanion(
            ganttOrder: Value(entry.value),
            updatedAt: Value(nowMs),
          ),
        );
      }
    });
  }

  /// Soft-deletes a single task (writes `deleted_at`/`updated_at`).
  Future<int> softDelete(String id, int nowMs) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
    );
  }

  /// Soft-deletes every task in a recurrence series (matching parent id).
  Future<int> softDeleteSeries(String parentId, int nowMs) {
    return (update(
      tasks,
    )..where((t) => t.recurrenceParent.equals(parentId))).write(
      TasksCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
    );
  }

  /// Returns the tag ids linked to [taskId].
  Future<List<String>> tagIdsFor(String taskId) async {
    final query = selectOnly(taskTags)
      ..addColumns([taskTags.tagId])
      ..where(taskTags.taskId.equals(taskId));
    final rows = await query.get();
    return rows.map((r) => r.read(taskTags.tagId)!).toList();
  }
}
