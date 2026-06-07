import 'package:drift/drift.dart';

import '../../core/enums/enums.dart';
import '../../core/enums/status_filter.dart';
import '../../core/models/date_filter.dart';
import '../../core/models/task_query.dart';
import '../search/fts_tokenizer.dart';
import 'app_database.dart';
import 'tables.dart';
import 'task_dao.dart';

/// Compiles a [TaskQuery] into a Drift [Selectable] over [Tasks].
///
/// Used by module 04 search. Legacy [TaskDao.buildQuery] remains for module 02
/// list scopes until a later consolidation.
class TaskQueryCompiler {
  TaskQueryCompiler(this._db) : _dao = _db.taskDao;

  final AppDatabase _db;
  final TaskDao _dao;

  /// One-shot query with optional FTS pre-filter ids (from [ftsTaskIds]).
  Future<List<TaskRow>> query(
    TaskQuery q, {
    required int nowMs,
    Set<String>? ftsTaskIds,
  }) async {
    final ids = ftsTaskIds ?? await _maybeFtsTaskIds(q);
    return _buildSelectable(q, nowMs: nowMs, ftsTaskIds: ids).get();
  }

  /// Reactive query stream for search UI.
  Stream<List<TaskRow>> watch(
    TaskQuery q, {
    required int nowMs,
    Set<String>? ftsTaskIds,
  }) async* {
    final ids = ftsTaskIds ?? await _maybeFtsTaskIds(q);
    yield* _buildSelectable(q, nowMs: nowMs, ftsTaskIds: ids).watch();
  }

  /// Returns task ids matching the keyword via FTS, with CJK fallback.
  Future<Set<String>?> ftsTaskIds(TaskQuery q) async {
    final keyword = q.effectiveKeyword;
    if (keyword == null) return null;
    final match = buildFtsMatch(keyword);
    final rows = await _dao.searchFts(match);
    if (rows.isNotEmpty) {
      return rows.map((r) => r.id).toSet();
    }
    return _cjkFallbackIds(keyword);
  }

  Future<Set<String>> _cjkFallbackIds(String keyword) async {
    final rows = await (_db.select(_db.tasks)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    return rows
        .where((row) => _rowMatchesCjk(row.title, row.notes, keyword))
        .map((r) => r.id)
        .toSet();
  }

  bool _rowMatchesCjk(String title, String? notes, String keyword) {
    final haystack = '$title ${notes ?? ''}';
    for (final segment in splitByScript(keyword)) {
      if (!segment.isCjk) {
        if (!haystack.toLowerCase().contains(segment.text.toLowerCase())) {
          return false;
        }
        continue;
      }
      if (segment.text.length == 1) {
        if (!haystack.contains(segment.text)) return false;
        continue;
      }
      for (var i = 0; i < segment.text.length - 1; i++) {
        if (!haystack.contains(segment.text.substring(i, i + 2))) {
          return false;
        }
      }
    }
    return true;
  }

  Future<Set<String>?> _maybeFtsTaskIds(TaskQuery q) => ftsTaskIds(q);

  Selectable<TaskRow> _buildSelectable(
    TaskQuery q, {
    required int nowMs,
    Set<String>? ftsTaskIds,
  }) {
    final query = _db.select(_db.tasks);

    if (!q.includeDeleted) {
      query.where((t) => t.deletedAt.isNull());
    }

    switch (q.effectiveStatusFilter) {
      case StatusFilter.incomplete:
        query.where((t) => t.isCompleted.equals(false));
      case StatusFilter.complete:
        query.where((t) => t.isCompleted.equals(true));
      case StatusFilter.overdue:
        query.where((t) =>
            t.isCompleted.equals(false) &
            t.dueDate.isNotNull() &
            t.dueDate.isSmallerThanValue(nowMs));
      case StatusFilter.all:
        if (!q.includeCompleted) {
          query.where((t) => t.isCompleted.equals(false));
        }
    }

    final priorities = q.effectivePriorities;
    if (priorities != null && priorities.isNotEmpty) {
      query.where(
        (t) => t.priority.isIn(priorities.map((p) => p.index)),
      );
    }

    final projectIds = q.effectiveProjectIds;
    if (projectIds.isNotEmpty) {
      query.where((t) => t.projectId.isIn(projectIds));
    }

    final tagIds = q.effectiveTagIds;
    if (tagIds.isNotEmpty) {
      final tagSub = _db.selectOnly(_db.taskTags)
        ..addColumns([_db.taskTags.taskId])
        ..where(_db.taskTags.tagId.isIn(tagIds.toList()));
      query.where((t) => t.id.isInQuery(tagSub));
    }

    _applyDateFilter(query, q);

    if (ftsTaskIds != null) {
      if (ftsTaskIds.isEmpty) {
        query.where((t) => t.id.equals('__no_fts_match__'));
      } else {
        query.where((t) => t.id.isIn(ftsTaskIds));
      }
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
          (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
        ]);
      case TaskSort.manual:
        query.orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    }

    return query;
  }

  void _applyDateFilter(
    SimpleSelectStatement<$TasksTable, TaskRow> query,
    TaskQuery q,
  ) {
    final filter = q.dateFilter;
    if (filter == null) return;

    switch (filter) {
      case DateOn(:final day):
        final startMs =
            DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch;
        final endMs = DateTime.utc(day.year, day.month, day.day, 23, 59, 59, 999)
            .millisecondsSinceEpoch;
        query.where((t) =>
            (t.dueDate.isBiggerOrEqualValue(startMs) &
                t.dueDate.isSmallerOrEqualValue(endMs)) |
            (t.startDate.isBiggerOrEqualValue(startMs) &
                t.startDate.isSmallerOrEqualValue(endMs)));
      case DateRange(:final range):
        final fromMs = range.start.toUtc().millisecondsSinceEpoch;
        final toMs = range.end.toUtc().millisecondsSinceEpoch;
        query.where((t) =>
            t.dueDate.isNotNull() &
            t.dueDate.isBiggerOrEqualValue(fromMs) &
            t.dueDate.isSmallerOrEqualValue(toMs));
      case DateOverlap(:final range):
        final fromMs = range.start.toUtc().millisecondsSinceEpoch;
        final toMs = range.end.toUtc().millisecondsSinceEpoch;
        query.where((t) {
          final effStart = coalesce([t.startDate, t.dueDate]);
          final effEnd = coalesce([t.dueDate, t.startDate]);
          return effStart.isNotNull() &
              effEnd.isNotNull() &
              effStart.isSmallerOrEqualValue(toMs) &
              effEnd.isBiggerOrEqualValue(fromMs);
        });
    }
  }
}
