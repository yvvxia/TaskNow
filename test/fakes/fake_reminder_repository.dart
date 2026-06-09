import 'package:liveline/core/contracts/i_reminder_repository.dart';
import 'package:liveline/core/models/reminder.dart';
import 'package:liveline/core/utils/result.dart';

/// In-memory [IReminderRepository] keyed by task id.
class FakeReminderRepository implements IReminderRepository {
  final Map<String, List<Reminder>> _store = {};

  @override
  Future<Result<List<Reminder>>> getByTask(String taskId) async =>
      Ok(_store[taskId] ?? []);

  @override
  Future<Result<void>> replaceForTask(
    String taskId,
    List<Reminder> reminders,
  ) async {
    _store[taskId] = reminders;
    return const Ok(null);
  }

  @override
  Future<Result<List<Reminder>>> dueBefore(DateTime cutoff) async {
    final result = _store.values
        .expand((r) => r)
        .where((r) => r.triggerAt.isBefore(cutoff))
        .toList();
    return Ok(result);
  }

  @override
  Future<Result<void>> markFired(String reminderId) async {
    for (final list in _store.values) {
      final idx = list.indexWhere((r) => r.id == reminderId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isFired: true);
        return const Ok(null);
      }
    }
    return const Ok(null);
  }
}
