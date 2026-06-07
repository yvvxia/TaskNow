import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/app_settings.dart';
import 'package:plan_list/core/models/notification_action.dart';
import 'package:plan_list/core/models/notification_request.dart';
import 'package:plan_list/core/models/project.dart';
import 'package:plan_list/core/models/reminder.dart';
import 'package:plan_list/core/models/tag.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/core/models/task_query.dart';

void main() {
  test('Task has defaults, copyWith and json round-trip', () {
    const t = Task(id: '1', title: 'A');
    expect(t.priority, Priority.medium);
    expect(t.status, TaskStatus.incomplete);

    final t2 = t.copyWith(title: 'B', priority: Priority.high);
    expect(t2.title, 'B');
    expect(t2.priority, Priority.high);
    expect(t2.id, '1');

    expect(Task.fromJson(t.toJson()), t);
  });

  test('Task json round-trip preserves dates and status', () {
    final t = Task(
      id: '2',
      title: 'X',
      notes: 'n',
      projectId: 'p',
      startDate: DateTime.utc(2026, 6, 1),
      dueDate: DateTime.utc(2026, 6, 5),
      createdAt: DateTime.utc(2026, 5, 30),
      completedAt: DateTime.utc(2026, 6, 6),
      status: TaskStatus.complete,
    );
    expect(Task.fromJson(t.toJson()), t);
  });

  test('TaskDraft defaults and copyWith', () {
    const d = TaskDraft(title: 'New');
    expect(d.priority, Priority.medium);
    expect(d.copyWith(title: 'N2').title, 'N2');
  });

  test('Project json round-trip and copyWith', () {
    const p = Project(id: 'p1', name: 'Work', color: '#ffffff', sortOrder: 3);
    expect(Project.fromJson(p.toJson()), p);
    expect(p.copyWith(name: 'Life').name, 'Life');
  });

  test('Tag json round-trip', () {
    const tag = Tag(id: 't1', name: 'urgent', color: '#E53935');
    expect(Tag.fromJson(tag.toJson()), tag);
  });

  test('Reminder json round-trip', () {
    final r = Reminder(
      id: 'r1',
      taskId: 'task1',
      triggerAt: DateTime.utc(2026, 1, 1, 9),
      type: ReminderType.atStart,
      isFired: true,
    );
    expect(Reminder.fromJson(r.toJson()), r);
  });

  test('TaskQuery defaults and copyWith', () {
    const q = TaskQuery();
    expect(q.sort, TaskSort.dueDate);
    expect(q.tagIds, isEmpty);

    final q2 = q.copyWith(
      text: 'foo',
      status: TaskStatus.overdue,
      priority: Priority.high,
      projectId: 'p',
      tagIds: <String>['a', 'b'],
      sort: TaskSort.priority,
    );
    expect(q2.text, 'foo');
    expect(q2.status, TaskStatus.overdue);
    expect(q2.priority, Priority.high);
    expect(q2.tagIds, <String>['a', 'b']);
    expect(q2.sort, TaskSort.priority);
  });

  test('NotificationRequest holds values and copyWith', () {
    final n = NotificationRequest(
      id: 1,
      taskId: 't',
      title: 'T',
      body: 'B',
      scheduledAt: DateTime.utc(2026),
    );
    expect(n.id, 1);
    expect(n.taskId, 't');
    expect(n.copyWith(title: 'T2').title, 'T2');
  });

  test('NotificationAction holds values and copyWith', () {
    const a = NotificationAction(taskId: 't', actionId: 'done');
    expect(a.actionId, 'done');
    expect(a.copyWith(actionId: 'snooze').actionId, 'snooze');
  });

  test('AppSettings defaults, copyWith and json round-trip', () {
    const s = AppSettings();
    expect(s.notificationsEnabled, isTrue);
    expect(s.defaultReminderMinutes, 15);
    expect(s.themeMode, 'system');
    expect(s.locale, 'en');
    expect(AppSettings.fromJson(s.toJson()), s);
    expect(s.copyWith(themeMode: 'dark').themeMode, 'dark');
  });
}
