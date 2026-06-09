import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/app_settings.dart';
import 'package:liveline/core/models/reminder.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/notification/domain/notification_settings.dart';
import 'package:liveline/features/notification/domain/reminder_calculator.dart';

void main() {
  const calc = ReminderCalculator();
  const settings = AppSettings(defaultReminderMinutes: 15);

  Task task({DateTime? start, DateTime? due, String id = 't1'}) =>
      Task(id: id, title: 'Test', startDate: start, dueDate: due);

  group('beforeDue', () {
    test('triggerAt is dueDate minus offsetMin', () {
      final due = DateTime.utc(2026, 6, 10, 12);
      final result = calc.compute(
        task(due: due),
        settings,
        configs: [
          Reminder(
            id: 'r1',
            taskId: 't1',
            triggerAt: due,
            type: ReminderType.beforeDue,
            offsetMin: 30,
          ),
        ],
      );
      expect(
        result.single.triggerAt,
        due.subtract(const Duration(minutes: 30)),
      );
    });

    test('uses defaultReminderMinutes when offsetMin is null', () {
      final due = DateTime.utc(2026, 6, 10, 12);
      final result = calc.compute(
        task(due: due),
        settings,
        configs: [
          Reminder(
            id: 'r1',
            taskId: 't1',
            triggerAt: due,
            type: ReminderType.beforeDue,
          ),
        ],
      );
      expect(
        result.single.triggerAt,
        due.subtract(const Duration(minutes: 15)),
      );
    });
  });

  group('atStart', () {
    test('triggerAt equals startDate', () {
      // Future-dated so the calculator's "drop past non-overdue triggers"
      // filter (relative to DateTime.now()) keeps it regardless of run date.
      final start = DateTime.utc(2027, 6, 8, 9);
      final result = calc.compute(
        task(start: start, due: DateTime.utc(2027, 6, 10)),
        settings,
        configs: [
          Reminder(
            id: 'r1',
            taskId: 't1',
            triggerAt: start,
            type: ReminderType.atStart,
          ),
        ],
      );
      expect(result.single.triggerAt, start);
    });
  });

  group('custom', () {
    test('keeps user absolute triggerAt', () {
      final custom = DateTime.utc(2026, 12, 9, 8);
      final result = calc.compute(
        task(due: DateTime.utc(2026, 6, 10)),
        settings,
        configs: [
          Reminder(
            id: 'r1',
            taskId: 't1',
            triggerAt: custom,
            type: ReminderType.custom,
          ),
        ],
      );
      expect(result.single.triggerAt, custom);
    });
  });

  group('overdue', () {
    test('first triggerAt equals dueDate', () {
      final due = DateTime.utc(2026, 6, 10, 12);
      final result = calc.compute(
        task(due: due),
        settings,
        configs: [
          Reminder(
            id: 'r1',
            taskId: 't1',
            triggerAt: due,
            type: ReminderType.overdue,
          ),
        ],
      );
      expect(result.single.triggerAt, due);
    });
  });

  test('filters past non-overdue triggers', () {
    final due = DateTime.now().toUtc().add(const Duration(days: 7));
    final result = calc.compute(
      task(due: due),
      settings,
      configs: [
        Reminder(
          id: 'past',
          taskId: 't1',
          triggerAt: due,
          type: ReminderType.beforeDue,
          offsetMin: 60 * 24 * 10,
        ),
        Reminder(
          id: 'future',
          taskId: 't1',
          triggerAt: due,
          type: ReminderType.beforeDue,
          offsetMin: 30,
        ),
      ],
    );
    expect(result.map((r) => r.id), ['future']);
  });

  test('keeps past overdue triggers', () {
    final pastDue = DateTime.utc(2020, 1, 1);
    final result = calc.compute(
      task(due: pastDue),
      settings,
      configs: [
        Reminder(
          id: 'od',
          taskId: 't1',
          triggerAt: pastDue,
          type: ReminderType.overdue,
        ),
      ],
    );
    expect(result, hasLength(1));
  });

  test('nextOverdue adds repeat interval hours', () {
    const ns = NotificationSettings(
      notificationsEnabled: true,
      defaultAdvanceMin: 15,
      overdueRepeatHours: 24,
      dndEnabled: false,
      dndStartMinutes: 0,
      dndEndMinutes: 0,
    );
    final last = DateTime.utc(2026, 6, 1, 12);
    expect(calc.nextOverdue(last, ns), last.add(const Duration(hours: 24)));
  });

  test('nextOverdue returns null when repeat disabled', () {
    const ns = NotificationSettings(
      notificationsEnabled: true,
      defaultAdvanceMin: 15,
      overdueRepeatHours: 0,
      dndEnabled: false,
      dndStartMinutes: 0,
      dndEndMinutes: 0,
    );
    expect(calc.nextOverdue(DateTime.utc(2026, 6, 1), ns), isNull);
  });
}
