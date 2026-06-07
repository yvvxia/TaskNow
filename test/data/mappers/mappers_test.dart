import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/project.dart';
import 'package:plan_list/core/models/recurrence_rule.dart';
import 'package:plan_list/core/models/reminder.dart';
import 'package:plan_list/core/models/tag.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/data/mappers/project_mapper.dart';
import 'package:plan_list/data/mappers/recurrence_rule_mapper.dart';
import 'package:plan_list/data/mappers/reminder_mapper.dart';
import 'package:plan_list/data/mappers/tag_mapper.dart';
import 'package:plan_list/data/mappers/task_mapper.dart';

void main() {
  group('TaskMapper', () {
    test('entity -> row -> entity round-trip preserves fields', () {
      final task = Task(
        id: 't1',
        title: 'Write report',
        notes: 'quarterly',
        projectId: 'p1',
        startDate: DateTime.utc(2026, 6, 1, 9),
        dueDate: DateTime.utc(2026, 6, 5, 17),
        createdAt: DateTime.utc(2026, 5, 30),
        completedAt: DateTime.utc(2026, 6, 6),
        priority: Priority.high,
        status: TaskStatus.complete,
        sortOrder: 7,
        recurrenceRuleId: 'rr1',
        recurrenceParent: 'series1',
        autoCompleteOnSubtasks: true,
        updatedAt: DateTime.utc(2026, 6, 2),
        deletedAt: DateTime.utc(2026, 6, 7),
        syncVersion: 3,
        deviceId: 'dev-1',
      );

      final back = TaskMapper.toEntity(
        TaskMapper.toRow(task),
        tagIds: const ['a', 'b'],
      );

      expect(back.copyWith(tagIds: const []), task);
      expect(back.tagIds, const ['a', 'b']);
    });

    test('incomplete status maps to is_completed = false and back', () {
      final task = Task(
        id: 't2',
        title: 'Open task',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      final row = TaskMapper.toRow(task);
      expect(row.isCompleted, isFalse);
      expect(TaskMapper.toEntity(row).status, TaskStatus.incomplete);
    });

    test('overdue status persists as not-completed (derived at read time)', () {
      final task = Task(
        id: 't3',
        title: 'Late',
        status: TaskStatus.overdue,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      final row = TaskMapper.toRow(task);
      expect(row.isCompleted, isFalse);
      expect(TaskMapper.toEntity(row).status, TaskStatus.incomplete);
    });

    test('fromDraft assigns id and stamps timestamps in UTC', () {
      const draft = TaskDraft(title: 'New', priority: Priority.low);
      final now = DateTime.utc(2026, 6, 7, 12);
      final task = TaskMapper.fromDraft(draft, id: 'gen', now: now);
      expect(task.id, 'gen');
      expect(task.title, 'New');
      expect(task.priority, Priority.low);
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
      expect(task.createdAt!.isUtc, isTrue);
    });
  });

  group('ProjectMapper', () {
    test('round-trip preserves fields', () {
      final project = Project(
        id: 'p1',
        name: 'Work',
        color: '#1976D2',
        sortOrder: 2,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
        deletedAt: DateTime.utc(2026, 1, 3),
        syncVersion: 5,
        deviceId: 'dev',
      );
      expect(ProjectMapper.toEntity(ProjectMapper.toRow(project)), project);
    });
  });

  group('TagMapper', () {
    test('round-trip preserves fields', () {
      const tag = Tag(id: 't', name: 'urgent', color: '#E53935');
      expect(TagMapper.toEntity(TagMapper.toRow(tag)), tag);
    });
  });

  group('ReminderMapper', () {
    test('round-trip preserves fields', () {
      final reminder = Reminder(
        id: 'r1',
        taskId: 'task1',
        triggerAt: DateTime.utc(2026, 6, 1, 8, 45),
        type: ReminderType.beforeDue,
        isFired: true,
        offsetMin: 15,
        notifId: 42,
      );
      expect(ReminderMapper.toEntity(ReminderMapper.toRow(reminder)), reminder);
    });
  });

  group('RecurrenceRuleMapper', () {
    test('round-trip preserves weekly rule with byWeekday', () {
      final rule = RecurrenceRule(
        id: 'rr1',
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        byWeekday: const [1, 3, 5],
        endDate: DateTime.utc(2026, 12, 31),
        count: 10,
      );
      expect(
        RecurrenceRuleMapper.toEntity(RecurrenceRuleMapper.toRow(rule)),
        rule,
      );
    });

    test('round-trip preserves monthly rule with empty byWeekday', () {
      final rule = RecurrenceRule(
        id: 'rr2',
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        byMonthDay: 15,
      );
      final row = RecurrenceRuleMapper.toRow(rule);
      expect(row.byweekday, isNull);
      expect(RecurrenceRuleMapper.toEntity(row), rule);
    });
  });
}
