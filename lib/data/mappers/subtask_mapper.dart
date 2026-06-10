import '../../core/models/subtask.dart';
import '../db/app_database.dart';

/// Pure, bidirectional mapping between [SubtaskRow] (persistence) and
/// [Subtask] (domain entity).
abstract final class SubtaskMapper {
  /// Maps a persistence row to a domain entity.
  static Subtask toEntity(SubtaskRow row) {
    return Subtask(
      id: row.id,
      title: row.title,
      isDone: row.isDone,
      sortOrder: row.sortOrder,
    );
  }

  /// Maps a domain entity to a persistence row for [taskId].
  static SubtaskRow toRow(Subtask subtask, {required String taskId}) {
    return SubtaskRow(
      id: subtask.id,
      taskId: taskId,
      title: subtask.title,
      isDone: subtask.isDone,
      sortOrder: subtask.sortOrder,
    );
  }

  /// Maps a list of domain subtasks to persistence rows.
  static List<SubtaskRow> toRows(
    List<Subtask> subtasks, {
    required String taskId,
  }) {
    return subtasks
        .map((s) => toRow(s, taskId: taskId))
        .toList(growable: false);
  }
}
