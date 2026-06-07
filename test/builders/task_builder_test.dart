import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';

import 'builders.dart';

void main() {
  setUp(resetTaskSeq);

  test('aTask provides sensible defaults', () {
    final t = aTask();
    expect(t.id, 'task-0');
    expect(t.title, 'Test task');
    expect(t.status, TaskStatus.incomplete);
    expect(t.priority, Priority.medium);
    expect(t.completedAt, isNull);
    expect(t.createdAt, DateTime.utc(2026, 6, 1));
  });

  test('ids auto-increment across calls', () {
    expect(aTask().id, 'task-0');
    expect(aTask().id, 'task-1');
    expect(aTask().id, 'task-2');
  });

  test('completed flag flips status and completedAt', () {
    final t = aTask(completed: true);
    expect(t.status, TaskStatus.complete);
    expect(t.completedAt, isNotNull);
  });

  test('overrides are applied', () {
    final due = DateTime.utc(2026, 7, 1, 12);
    final t = aTask(
      id: 'custom',
      title: 'Custom',
      due: due,
      priority: Priority.high,
      tagIds: const ['a', 'b'],
    );
    expect(t.id, 'custom');
    expect(t.title, 'Custom');
    expect(t.dueDate, due);
    expect(t.priority, Priority.high);
    expect(t.tagIds, ['a', 'b']);
  });

  test('aProject / aTag / aReminder defaults', () {
    resetProjectSeq();
    resetTagSeq();
    resetReminderSeq();
    expect(aProject().id, 'project-0');
    expect(aProject().name, 'Test project');
    expect(aTag().id, 'tag-0');
    final r = aReminder();
    expect(r.id, 'reminder-0');
    expect(r.type, ReminderType.beforeDue);
    expect(r.isFired, isFalse);
  });
}
