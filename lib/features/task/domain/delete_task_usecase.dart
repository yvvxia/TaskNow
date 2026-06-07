import '../../../core/contracts/i_task_repository.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';

/// Controls how much of a recurrence series is deleted.
enum DeleteScope {
  /// Delete only the selected task instance.
  thisOnly,

  /// Delete the selected instance and all other instances in the series.
  entireSeries,
}

/// Soft-deletes a task (and optionally its entire recurrence series), then
/// cancels related notifications.
final class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._tasks, this._scheduler);

  final ITaskRepository _tasks;
  final ReminderScheduler _scheduler;

  Future<Result<void>> call(String taskId, DeleteScope scope) async {
    final result = await _tasks.delete(
      taskId,
      entireSeries: scope == DeleteScope.entireSeries,
    );
    if (result case Err(:final error)) return Err(error);

    await _scheduler.cancel(taskId);
    return const Ok(null);
  }
}
