import '../../../core/contracts/i_task_repository.dart';
import '../../../core/enums/enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';

/// Reverts a completed task back to the incomplete state and re-schedules its
/// reminders. The inverse of [CompleteTaskUseCase] for a single instance; it
/// does not touch any recurrence instances that completion may have spawned.
final class UncompleteTaskUseCase {
  const UncompleteTaskUseCase(this._tasks, this._scheduler);

  final ITaskRepository _tasks;
  final ReminderScheduler _scheduler;

  Future<Result<void>> call(String taskId) async {
    final found = await _tasks.findById(taskId);
    if (found case Err(:final error)) return Err(error);
    if (found case Ok(:final value) when value == null) {
      return const Err(NotFoundException());
    }

    final task = (found as Ok).value!;
    final reopened = task.copyWith(
      status: TaskStatus.incomplete,
      completedAt: null,
    );

    final saved = await _tasks.update(reopened);
    if (saved case Err(:final error)) return Err(error);

    await _scheduler.sync(reopened);
    return const Ok(null);
  }
}
