import '../../../core/errors/app_exception.dart';
import '../../../core/models/task_draft.dart';
import '../../../core/utils/result.dart';

/// Domain-layer validator for task input.
///
/// Returns [Ok(null)] when the draft passes all rules,
/// or [Err(ValidationException)] on the first failure.
final class TaskValidator {
  const TaskValidator();

  Result<void> validate(TaskDraft draft) {
    if (draft.title.trim().isEmpty) {
      return const Err(
        ValidationException(
          code: 'emptyTitle',
          messageKey: 'error.emptyTitle',
        ),
      );
    }

    if (draft.dueDate != null &&
        draft.startDate != null &&
        draft.dueDate!.isBefore(draft.startDate!)) {
      return const Err(
        ValidationException(
          code: 'dueBeforeStart',
          messageKey: 'error.dueBeforeStart',
        ),
      );
    }

    return const Ok(null);
  }
}
