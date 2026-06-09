import 'package:flutter/material.dart' show DateTimeRange;

import '../models/task.dart';
import '../models/task_draft.dart';
import '../models/task_query.dart';
import '../utils/result.dart';

/// Task repository contract. Implemented by the data layer (module 01) and
/// consumed by domain/presentation. See `design/00-architecture-overview.md` §5.
abstract interface class ITaskRepository {
  Future<Result<Task>> create(TaskDraft draft);

  Future<Result<Task>> update(Task task);

  Future<Result<void>> delete(String id, {required bool entireSeries});

  Future<Result<Task?>> findById(String id);

  /// Range query for calendar & Gantt.
  Future<Result<List<Task>>> findInRange(
    DateTimeRange range, {
    TaskQuery? query,
  });

  /// Arbitrary query for list & search.
  Future<Result<List<Task>>> query(TaskQuery query);

  /// Reactive stream so the UI auto-refreshes after writes.
  Stream<List<Task>> watch(TaskQuery query);

  /// Persists manual Gantt-row ordering: maps each task id to its new row
  /// index. Used by the per-project Gantt view's drag-to-reorder.
  Future<Result<void>> setGanttOrder(Map<String, int> orderByTaskId);
}
