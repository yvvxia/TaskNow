import '../../../core/contracts/i_task_repository.dart';
import '../../../core/models/task.dart';
import '../../../core/models/task_draft.dart';
import '../../../core/utils/result.dart';
import '../../notification/application/reminder_scheduler.dart';
import 'task_validator.dart';

/// Creates a new task after validating the draft, persisting it, and
/// scheduling reminders via [ReminderScheduler].
final class CreateTaskUseCase {
  const CreateTaskUseCase(this._tasks, this._scheduler);

  final ITaskRepository _tasks;
  final ReminderScheduler _scheduler;

  Future<Result<Task>> call(TaskDraft draft) async {
    final validation = const TaskValidator().validate(draft);
    if (validation case Err(:final error)) return Err(error);

    final created = await _tasks.create(draft);
    if (created case Err(:final error)) return Err(error);

    final task = (created as Ok<Task>).value;
    await _scheduler.sync(task);
    return Ok(task);
  }
}
