import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/recurrence_rule.dart';
import 'package:plan_list/core/models/subtask.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/task/domain/recurrence_engine.dart';

void main() {
  const engine = RecurrenceEngine();

  group('RecurrenceEngine.nextDate', () {
    test('daily: adds interval days', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 6, 8));
    });

    test('daily: adds multiple days with interval > 1', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.daily,
        interval: 3,
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 6, 10));
    });

    test('weekly: finds next matching weekday', () {
      // From a Saturday (weekday=6), find next Monday (weekday=1).
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        byWeekday: [1], // Monday
      );
      final from = DateTime.utc(2026, 6, 6); // Saturday
      final next = engine.nextDate(rule, from);
      expect(next!.weekday, 1); // Monday
    });

    test('weekly: no byWeekday falls back to interval weeks', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        byWeekday: [],
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 6, 7 + 14));
    });

    test('monthly: adds interval months', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
      );
      final from = DateTime.utc(2026, 6, 15);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 7, 15));
    });

    test('monthly: end-of-month boundary Jan 31 → Feb 28', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        byMonthDay: 31,
      );
      final from = DateTime.utc(2026, 1, 31);
      final next = engine.nextDate(rule, from);
      // Feb 2026 has 28 days.
      expect(next, DateTime.utc(2026, 2, 28));
    });

    test('monthly: end-of-month boundary crossing to next year', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
      );
      final from = DateTime.utc(2026, 12, 15);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2027, 1, 15));
    });

    test('endDate cutoff: returns null when next date exceeds endDate', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime.utc(2026, 6, 7),
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, isNull);
    });

    test('endDate cutoff: returns date when within endDate', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime.utc(2026, 6, 10),
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 6, 8));
    });

    test('custom: acts like daily (placeholder)', () {
      final rule = RecurrenceRule(
        id: 'r',
        frequency: RecurrenceFrequency.custom,
        interval: 5,
      );
      final from = DateTime.utc(2026, 6, 7);
      final next = engine.nextDate(rule, from);
      expect(next, DateTime.utc(2026, 6, 12));
    });
  });

  group('RecurrenceEngine.nextInstance', () {
    final rule = RecurrenceRule(
      id: 'rule1',
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      byWeekday: [7], // Sunday
    );

    final weeklyTask = Task(
      id: 'task-1',
      title: 'Weekly review',
      notes: 'Review notes',
      projectId: 'proj-1',
      priority: Priority.high,
      dueDate: DateTime.utc(2026, 6, 7), // Sunday
      startDate: DateTime.utc(2026, 6, 6), // Saturday
      recurrence: rule,
      autoCompleteOnSubtasks: true,
      subtasks: [
        const Subtask(id: 's1', title: 'Sub 1', isDone: true),
        const Subtask(id: 's2', title: 'Sub 2', isDone: true),
      ],
    );

    test('returns draft with same title, notes, project, priority', () {
      final draft = engine.nextInstance(weeklyTask, after: DateTime.utc(2026, 6, 7));
      expect(draft, isNotNull);
      expect(draft!.title, 'Weekly review');
      expect(draft.notes, 'Review notes');
      expect(draft.projectId, 'proj-1');
      expect(draft.priority, Priority.high);
    });

    test('resets subtask isDone to false', () {
      final draft = engine.nextInstance(weeklyTask, after: DateTime.utc(2026, 6, 7));
      expect(draft!.subtasks.length, 2);
      expect(draft.subtasks.every((s) => !s.isDone), isTrue);
    });

    test('preserves recurrence rule and tag IDs', () {
      final taskWithTags = weeklyTask.copyWith(tagIds: ['tag-1', 'tag-2']);
      final draft = engine.nextInstance(taskWithTags, after: DateTime.utc(2026, 6, 7));
      expect(draft!.recurrence, rule);
      expect(draft.tagIds, ['tag-1', 'tag-2']);
    });

    test('returns null when series has ended', () {
      final endedRule = RecurrenceRule(
        id: 'rule-ended',
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        endDate: DateTime.utc(2026, 6, 7),
      );
      final task = weeklyTask.copyWith(
        dueDate: DateTime.utc(2026, 6, 7),
        recurrence: endedRule,
      );
      final draft = engine.nextInstance(task, after: DateTime.utc(2026, 6, 7));
      expect(draft, isNull);
    });

    test('returns null for non-recurring task', () {
      final plain = Task(id: 'p', title: 'Plain');
      final draft = engine.nextInstance(plain, after: DateTime.utc(2026, 6, 7));
      expect(draft, isNull);
    });

    test('preserves start→due delta', () {
      final draft = engine.nextInstance(weeklyTask, after: DateTime.utc(2026, 6, 7));
      if (draft!.startDate != null && draft.dueDate != null) {
        final delta = draft.dueDate!.difference(draft.startDate!);
        // Original: Sat→Sun = 1 day
        expect(delta.inDays, 1);
      }
    });
  });
}
