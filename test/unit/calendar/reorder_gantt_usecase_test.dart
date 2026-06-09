import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/calendar/domain/reorder_gantt_usecase.dart';

import '../../fakes/fake_task_repository.dart';

void main() {
  test('persists each task id at its index in the new order', () async {
    final repo = FakeTaskRepository();
    addTearDown(repo.dispose);
    repo.seed([
      Task(id: 'a', title: 'A', dueDate: DateTime.utc(2026, 6, 1)),
      Task(id: 'b', title: 'B', dueDate: DateTime.utc(2026, 6, 2)),
      Task(id: 'c', title: 'C', dueDate: DateTime.utc(2026, 6, 3)),
    ]);

    final result = await ReorderGanttUseCase(repo)(['c', 'a', 'b']);

    expect(result.isOk, isTrue);
    final byId = {for (final t in repo.items) t.id: t.ganttOrder};
    expect(byId, {'c': 0, 'a': 1, 'b': 2});
  });
}
