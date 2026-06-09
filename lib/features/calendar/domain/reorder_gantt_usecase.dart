import '../../../core/contracts/i_task_repository.dart';
import '../../../core/utils/result.dart';

/// Persists a new top-to-bottom ordering of Gantt rows by assigning each task
/// its index in [orderedTaskIds] as its `ganttOrder`.
final class ReorderGanttUseCase {
  const ReorderGanttUseCase(this._tasks);

  final ITaskRepository _tasks;

  Future<Result<void>> call(List<String> orderedTaskIds) {
    final orderByTaskId = <String, int>{
      for (var i = 0; i < orderedTaskIds.length; i++) orderedTaskIds[i]: i,
    };
    return _tasks.setGanttOrder(orderByTaskId);
  }
}
