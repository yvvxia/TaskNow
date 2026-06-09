import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';

void main() {
  test('Priority order matches proposal (HIGH = 0)', () {
    expect(Priority.values, <Priority>[
      Priority.high,
      Priority.medium,
      Priority.low,
    ]);
    expect(Priority.high.index, 0);
    expect(Priority.medium.index, 1);
    expect(Priority.low.index, 2);
  });

  test('TaskStatus order matches proposal', () {
    expect(TaskStatus.values, <TaskStatus>[
      TaskStatus.incomplete,
      TaskStatus.complete,
      TaskStatus.overdue,
    ]);
    expect(TaskStatus.overdue.index, 2);
  });

  test('ReminderType order matches proposal', () {
    expect(ReminderType.values, <ReminderType>[
      ReminderType.beforeDue,
      ReminderType.atStart,
      ReminderType.custom,
      ReminderType.overdue,
    ]);
    expect(ReminderType.overdue.index, 3);
  });

  test('RecurrenceFrequency order matches proposal', () {
    expect(RecurrenceFrequency.values, <RecurrenceFrequency>[
      RecurrenceFrequency.daily,
      RecurrenceFrequency.weekly,
      RecurrenceFrequency.monthly,
      RecurrenceFrequency.custom,
    ]);
  });

  test('CalendarViewType has day/week/month/gantt', () {
    expect(CalendarViewType.values, <CalendarViewType>[
      CalendarViewType.day,
      CalendarViewType.week,
      CalendarViewType.month,
      CalendarViewType.gantt,
    ]);
  });

  test('TaskSort includes legacy and module 04 values', () {
    expect(TaskSort.values, contains(TaskSort.dueDate));
    expect(TaskSort.values, contains(TaskSort.dueAsc));
    expect(TaskSort.values, contains(TaskSort.dueDesc));
    expect(TaskSort.values, contains(TaskSort.priorityDesc));
    expect(TaskSort.values, contains(TaskSort.createdDesc));
    expect(TaskSort.values, contains(TaskSort.manual));
  });

  test('ProjectDeleteMode values', () {
    expect(ProjectDeleteMode.values, <ProjectDeleteMode>[
      ProjectDeleteMode.deleteTasks,
      ProjectDeleteMode.moveToInbox,
    ]);
  });

  test('SyncStatus values', () {
    expect(SyncStatus.values, <SyncStatus>[
      SyncStatus.idle,
      SyncStatus.syncing,
      SyncStatus.success,
      SyncStatus.error,
    ]);
  });
}
