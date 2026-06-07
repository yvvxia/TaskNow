import '../../../core/contracts/i_reminder_repository.dart';
import '../../../core/contracts/i_task_repository.dart';
import '../../../core/enums/enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';
import 'recurrence_engine.dart';

/// Marks a task as complete, cancels its notifications, and – for recurring
/// tasks – generates the next instance.
final class CompleteTaskUseCase {
  const CompleteTaskUseCase(
    this._tasks,
    this._reminders,
    this._scheduler,
    this._engine,
  );

  final ITaskRepository _tasks;
  final IReminderRepository _reminders;
  final ReminderScheduler _scheduler;
  final RecurrenceEngine _engine;

  Future<Result<void>> call(String taskId, {DateTime? at}) async {
    final found = await _tasks.findById(taskId);
    if (found case Err(:final error)) return Err(error);
    if (found case Ok(:final value) when value == null) {
      return const Err(NotFoundException());
    }

    final task = (found as Ok).value!;
    final now = (at ?? DateTime.now()).toUtc();
    final completed = task.copyWith(
      status: TaskStatus.complete,
      completedAt: now,
    );

    final saved = await _tasks.update(completed);
    if (saved case Err(:final error)) return Err(error);

    await _scheduler.cancel(taskId);

    if (task.isRecurring) {
      final next = _engine.nextInstance(task, after: now);
      if (next != null) {
        final createResult = await _tasks.create(next);
        if (createResult.isOk) {
          final newTask = createResult.valueOrNull!;
          final reminders = await _reminders.getByTask(taskId);
          if (reminders case Ok(:final value) when value.isNotEmpty) {
            await _reminders.replaceForTask(
              newTask.id,
              value.map((r) => r.copyWith(taskId: newTask.id)).toList(),
            );
          }
          await _scheduler.sync(newTask);
        }
      }
    }

    return const Ok(null);
  }
}
