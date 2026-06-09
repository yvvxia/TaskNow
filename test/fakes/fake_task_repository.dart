import 'dart:async';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:plan_list/core/contracts/i_task_repository.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/core/models/task_query.dart';
import 'package:plan_list/core/utils/result.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// In-memory [ITaskRepository] for tests. Emits on every mutation so
/// `watch()` subscribers behave like the real Drift-backed stream.
class FakeTaskRepository implements ITaskRepository {
  final List<Task> _items = [];
  final _controller = StreamController<List<Task>>.broadcast();

  List<Task> get items => List.unmodifiable(_items);

  /// Seed tasks without triggering stream events.
  void seed(List<Task> tasks) {
    _items
      ..clear()
      ..addAll(tasks);
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<Result<Task>> create(TaskDraft draft) async {
    final now = DateTime.now().toUtc();
    final task = Task(
      id: _uuid.v4(),
      title: draft.title,
      notes: draft.notes,
      projectId: draft.projectId,
      startDate: draft.startDate,
      dueDate: draft.dueDate,
      priority: draft.priority,
      tagIds: draft.tagIds,
      subtasks: const [],
      recurrence: draft.recurrence,
      autoCompleteOnSubtasks: draft.autoCompleteOnSubtasks,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(task);
    _emit();
    return Ok(task);
  }

  @override
  Future<Result<Task>> update(Task task) async {
    final idx = _items.indexWhere((t) => t.id == task.id);
    if (idx == -1) return const Err(NotFoundException());
    _items[idx] = task;
    _emit();
    return Ok(task);
  }

  @override
  Future<Result<void>> delete(String id, {required bool entireSeries}) async {
    _items.removeWhere((t) {
      if (t.id == id) return true;
      if (entireSeries && t.recurrenceParent == id) return true;
      return false;
    });
    _emit();
    return const Ok(null);
  }

  @override
  Future<Result<Task?>> findById(String id) async {
    final found = _items.cast<Task?>().firstWhere(
      (t) => t?.id == id,
      orElse: () => null,
    );
    return Ok(found);
  }

  @override
  Future<Result<List<Task>>> findInRange(
    DateTimeRange range, {
    TaskQuery? query,
  }) async {
    final result = _items.where((t) {
      final effective = t.dueDate ?? t.startDate;
      if (effective == null) return false;
      return !effective.isBefore(range.start) && !effective.isAfter(range.end);
    }).toList();
    return Ok(result);
  }

  @override
  Future<Result<List<Task>>> query(TaskQuery query) async {
    return Ok(_applyQuery(_items, query));
  }

  @override
  Stream<List<Task>> watch(TaskQuery query) {
    // Emit the current snapshot immediately on subscription, then
    // continue with future mutation events.
    return Stream<List<Task>>.multi((controller) {
      controller.add(_applyQuery(_items, query));
      final sub = _controller.stream.listen(
        (tasks) {
          if (!controller.isClosed) {
            controller.add(_applyQuery(tasks, query));
          }
        },
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Future<Result<void>> setGanttOrder(Map<String, int> orderByTaskId) async {
    for (final entry in orderByTaskId.entries) {
      final idx = _items.indexWhere((t) => t.id == entry.key);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(ganttOrder: entry.value);
      }
    }
    _emit();
    return const Ok<void>(null);
  }

  List<Task> _applyQuery(List<Task> tasks, TaskQuery query) {
    return tasks.where((t) {
      if (query.status != null && t.status != query.status) return false;
      if (query.projectId != null && t.projectId != query.projectId) {
        return false;
      }
      if (query.tagIds.isNotEmpty &&
          !query.tagIds.any((id) => t.tagIds.contains(id))) {
        return false;
      }
      return true;
    }).toList();
  }

  void dispose() => _controller.close();
}
