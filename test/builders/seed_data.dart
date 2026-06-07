import 'package:plan_list/core/contracts/i_task_repository.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task_draft.dart';

/// Generates [count] deterministic [TaskDraft]s spread across consecutive days
/// starting at [start]. Used by the performance/regression suite to populate a
/// realistically sized dataset (`design/07-testing-strategy.md` §8).
List<TaskDraft> generateTaskDrafts({int count = 1000, DateTime? start}) {
  final base = start ?? DateTime.utc(2026, 1, 1, 9);
  final priorities = Priority.values;
  return List<TaskDraft>.generate(count, (i) {
    final day = base.add(Duration(hours: i * 6));
    return TaskDraft(
      title: 'Seed task #$i',
      notes: 'Auto-generated seed task number $i',
      startDate: day,
      dueDate: day.add(const Duration(hours: 4)),
      priority: priorities[i % priorities.length],
    );
  });
}

/// Seeds [count] tasks into [repo] and returns once they are all persisted.
Future<void> seedTasks(
  ITaskRepository repo, {
  int count = 1000,
  DateTime? start,
}) async {
  for (final draft in generateTaskDrafts(count: count, start: start)) {
    await repo.create(draft);
  }
}
