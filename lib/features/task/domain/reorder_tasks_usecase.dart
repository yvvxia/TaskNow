import '../../../core/contracts/i_task_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/result.dart';

/// Updates the [sortOrder] of each task according to the provided ordered list
/// of ids. The first id gets sortOrder 0, the second gets 1, and so on.
final class ReorderTasksUseCase {
  const ReorderTasksUseCase(this._tasks);

  final ITaskRepository _tasks;

  Future<Result<void>> call(List<String> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      final found = await _tasks.findById(orderedIds[i]);
      switch (found) {
        case Err(:final error):
          return Err(error);
        case Ok(:final value) when value == null:
          return Err(
            NotFoundException(
              code: 'not_found_${orderedIds[i]}',
              messageKey: 'error.notFound',
            ),
          );
        case Ok(:final value):
          final updated = await _tasks.update(value!.copyWith(sortOrder: i));
          if (updated case Err(:final error)) return Err(error);
      }
    }
    return const Ok(null);
  }
}
