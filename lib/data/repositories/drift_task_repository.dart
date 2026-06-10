import 'package:flutter/material.dart' show DateTimeRange;

import '../../core/contracts/i_task_repository.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/task.dart';
import '../../core/models/task_draft.dart';
import '../../core/models/task_query.dart';
import '../../core/utils/result.dart';
import '../db/app_database.dart';
import '../db/task_dao.dart';
import '../mappers/subtask_mapper.dart';
import '../mappers/task_mapper.dart';
import '../mappers/time_mapper.dart';

/// Drift-backed implementation of [ITaskRepository]. Wraps all failures in a
/// [Result]/[AppException]; no raw exceptions escape.
class DriftTaskRepository implements ITaskRepository {
  DriftTaskRepository(AppDatabase db, {DateTime Function()? now})
    : _dao = db.taskDao,
      _now = now ?? DateTime.now;

  final TaskDao _dao;
  final DateTime Function() _now;

  @override
  Future<Result<Task>> create(TaskDraft draft) async {
    try {
      final entity = TaskMapper.fromDraft(draft, id: kUuid.v4(), now: _now());
      await _dao.upsertTask(
        TaskMapper.toRow(entity),
        entity.tagIds,
        subtasks: SubtaskMapper.toRows(entity.subtasks, taskId: entity.id),
      );
      return Ok(entity);
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Future<Result<Task>> update(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: _now().toUtc());
      await _dao.upsertTask(
        TaskMapper.toRow(updated),
        updated.tagIds,
        subtasks: SubtaskMapper.toRows(updated.subtasks, taskId: updated.id),
      );
      return Ok(updated);
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Future<Result<void>> delete(String id, {required bool entireSeries}) async {
    try {
      final existing = await _dao.findByIdIncludingDeleted(id);
      if (existing == null) {
        return const Err(NotFoundException());
      }
      final nowMs = _now().msUtc;
      await _dao.softDelete(id, nowMs);
      final parent = existing.recurrenceParent ?? existing.id;
      if (entireSeries) {
        await _dao.softDeleteSeries(parent, nowMs);
      }
      return const Ok<void>(null);
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Future<Result<Task?>> findById(String id) async {
    try {
      final row = await _dao.findById(id);
      if (row == null) return const Ok<Task?>(null);
      return Ok(await _composeOne(row));
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Future<Result<List<Task>>> findInRange(
    DateTimeRange range, {
    TaskQuery? query,
  }) async {
    try {
      final rows = await _dao.getInRange(range.start.msUtc, range.end.msUtc);
      return Ok(await _composeAll(rows));
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Future<Result<List<Task>>> query(TaskQuery query) async {
    try {
      final rows = query.text != null && query.text!.trim().isNotEmpty
          ? await _dao.searchFts(_ftsMatch(query.text!))
          : await _dao.buildQuery(query, nowMs: _now().msUtc).get();
      return Ok(await _composeAll(rows));
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  @override
  Stream<List<Task>> watch(TaskQuery query) {
    return _dao
        .buildQuery(query, nowMs: _now().msUtc)
        .watch()
        .asyncMap(_composeAll);
  }

  @override
  Future<Result<void>> setGanttOrder(Map<String, int> orderByTaskId) async {
    try {
      await _dao.setGanttOrders(orderByTaskId, _now().msUtc);
      return const Ok<void>(null);
    } on Object catch (e) {
      return Err(_persistence(e));
    }
  }

  Future<Task> _composeOne(TaskRow row) async {
    final composed = await _composeAll([row]);
    return composed.first;
  }

  Future<List<Task>> _composeAll(List<TaskRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList(growable: false);
    final tagsByTask = await _dao.tagIdsForTasks(ids);
    final subtasksByTask = await _dao.subtasksForTasks(ids);
    return rows
        .map(
          (row) => TaskMapper.toEntity(
            row,
            tagIds: tagsByTask[row.id] ?? const [],
            subtasks: (subtasksByTask[row.id] ?? const [])
                .map(SubtaskMapper.toEntity)
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  /// Builds a simple FTS5 MATCH expression: prefix-match each whitespace token.
  static String _ftsMatch(String text) {
    final tokens = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '${t.replaceAll('"', '')}*');
    return tokens.join(' ');
  }

  static PersistenceException _persistence(Object e) =>
      const PersistenceException();
}
