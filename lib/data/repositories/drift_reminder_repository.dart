import '../../core/contracts/i_reminder_repository.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/reminder.dart';
import '../../core/utils/result.dart';
import '../db/app_database.dart';
import '../db/reminder_dao.dart';
import '../mappers/reminder_mapper.dart';
import '../mappers/time_mapper.dart';

/// Drift-backed implementation of [IReminderRepository].
class DriftReminderRepository implements IReminderRepository {
  DriftReminderRepository(AppDatabase db) : _dao = db.reminderDao;

  final ReminderDao _dao;

  @override
  Future<Result<List<Reminder>>> getByTask(String taskId) async {
    try {
      final rows = await _dao.getByTask(taskId);
      return Ok(rows.map(ReminderMapper.toEntity).toList());
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<void>> replaceForTask(
    String taskId,
    List<Reminder> reminders,
  ) async {
    try {
      await _dao.replaceForTask(
        taskId,
        reminders.map(ReminderMapper.toRow).toList(),
      );
      return const Ok<void>(null);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<List<Reminder>>> dueBefore(DateTime cutoff) async {
    try {
      final rows = await _dao.dueBefore(cutoff.msUtc);
      return Ok(rows.map(ReminderMapper.toEntity).toList());
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<void>> markFired(String reminderId) async {
    try {
      await _dao.markFired(reminderId);
      return const Ok<void>(null);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }
}
