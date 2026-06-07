import '../../../core/contracts/i_task_repository.dart';
import '../../../core/models/task.dart';
import '../../../core/models/task_draft.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';
import 'task_validator.dart';

/// Updates an existing task: validates, persists, and re-schedules reminders.
final class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._tasks, this._scheduler);

  final ITaskRepository _tasks;
  final ReminderScheduler _scheduler;

  Future<Result<Task>> call(Task task) async {
    final draft = TaskDraft(
      title: task.title,
      startDate: task.startDate,
      dueDate: task.dueDate,
    );
    final validation = const TaskValidator().validate(draft);
    if (validation case Err(:final error)) return Err(error);

    final updated = await _tasks.update(task);
    if (updated case Err(:final error)) return Err(error);

    final saved = (updated as Ok<Task>).value;
    await _scheduler.sync(saved);
    return Ok(saved);
  }
}
