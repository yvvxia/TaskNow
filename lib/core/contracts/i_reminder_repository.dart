import '../models/reminder.dart';
import '../utils/result.dart';

/// Reminder repository contract (module 05).
abstract interface class IReminderRepository {
  Future<Result<List<Reminder>>> getByTask(String taskId);

  Future<Result<void>> replaceForTask(String taskId, List<Reminder> reminders);

  Future<Result<List<Reminder>>> dueBefore(DateTime cutoff);

  Future<Result<void>> markFired(String reminderId);
}
