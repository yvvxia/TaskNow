import '../../../core/contracts/i_task_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/subtask.dart';
import '../../../core/utils/result.dart';
import 'complete_task_usecase.dart';

/// Toggles a subtask's [isDone] flag. When all subtasks are done **and**
/// [Task.autoCompleteOnSubtasks] is true, completes the parent task.
final class ToggleSubtaskUseCase {
  const ToggleSubtaskUseCase(
    this._tasks,
    this._completeTaskUseCase,
  );

  final ITaskRepository _tasks;
  final CompleteTaskUseCase _completeTaskUseCase;

  Future<Result<void>> call(
    String taskId,
    String subtaskId, {
    DateTime? at,
  }) async {
    final found = await _tasks.findById(taskId);
    if (found case Err(:final error)) return Err(error);
    if (found case Ok(:final value) when value == null) {
      return const Err(NotFoundException());
    }

    final task = (found as Ok).value!;
    final subtaskIndex = task.subtasks.indexWhere((s) => s.id == subtaskId);
    if (subtaskIndex == -1) {
      return const Err(NotFoundException(
        code: 'subtask_not_found',
        messageKey: 'error.notFound',
      ));
    }

    final updatedSubtasks = <Subtask>[
      for (var i = 0; i < task.subtasks.length; i++)
        if (i == subtaskIndex)
          task.subtasks[i].copyWith(isDone: !task.subtasks[i].isDone)
        else
          task.subtasks[i],
    ];

    final updatedTask = task.copyWith(subtasks: updatedSubtasks);
    final saveResult = await _tasks.update(updatedTask);
    if (saveResult case Err(:final error)) return Err(error);

    // Auto-complete parent when all subtasks are done.
    final allDone = updatedSubtasks.every((s) => s.isDone);
    if (allDone && updatedTask.autoCompleteOnSubtasks) {
      return _completeTaskUseCase(taskId, at: at);
    }

    return const Ok(null);
  }
}
