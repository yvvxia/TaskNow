import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/clock.dart';
import '../../../core/di/providers.dart';
import '../domain/delete_task_usecase.dart';
import '../domain/task_list_scope.dart';
import '../task_providers.dart';
import 'task_view.dart';

part 'task_list_notifier.g.dart';

/// Riverpod-backed list notifier. Streams [TaskView] items for a given
/// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
///
/// Batch-select state (long-press → multi-select) is tracked via
/// [selectedIds]; an empty set means no selection mode is active.
///
/// Kept alive so navigating between shell destinations does not dispose and
/// re-subscribe the underlying database stream (which caused an empty-list
/// flash and perceptible jank on every tab switch).
@Riverpod(keepAlive: true)
class TaskListNotifier extends _$TaskListNotifier {
  final Set<String> _selectedIds = {};

  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  @override
  Stream<List<TaskView>> build(TaskListScope scope) {
    final repo = ref.watch(taskRepositoryProvider);
    final clock = ref.watch(clockProvider);
    return repo
        .watch(scope.toQuery())
        .map((tasks) => tasks.map((t) => TaskView.from(t, clock())).toList());
  }

  Future<void> complete(String id) async {
    await ref.read(completeTaskUseCaseProvider).call(id);
  }

  Future<void> uncomplete(String id) async {
    await ref.read(uncompleteTaskUseCaseProvider).call(id);
  }

  /// Flips a task between complete and incomplete based on its current state,
  /// so tapping the checkbox of a finished task re-opens it.
  Future<void> toggleComplete(TaskView task) async {
    if (task.isCompleted) {
      await uncomplete(task.id);
    } else {
      await complete(task.id);
    }
  }

  Future<void> toggleSubtask(String taskId, String subId) async {
    await ref.read(toggleSubtaskUseCaseProvider).call(taskId, subId);
  }

  Future<void> delete(String id, DeleteScope scope) async {
    await ref.read(deleteTaskUseCaseProvider).call(id, scope);
  }

  // --- Batch select ----------------------------------------------------------

  void toggleSelect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
  }

  void clearSelection() => _selectedIds.clear();

  Future<void> completeSelected() async {
    for (final id in Set<String>.from(_selectedIds)) {
      await complete(id);
    }
    _selectedIds.clear();
  }

  Future<void> deleteSelected() async {
    for (final id in Set<String>.from(_selectedIds)) {
      await delete(id, DeleteScope.thisOnly);
    }
    _selectedIds.clear();
  }
}
