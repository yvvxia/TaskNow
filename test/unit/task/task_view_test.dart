import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/subtask.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/task/presentation/task_view.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 6, 7, 12, 0);

  group('Task.statusAt', () {
    test('complete task → TaskStatus.complete', () {
      const task = Task(id: '1', title: 'T', status: TaskStatus.complete);
      expect(task.statusAt(fixedNow), TaskStatus.complete);
    });

    test('incomplete past dueDate → TaskStatus.overdue', () {
      final task = Task(id: '1', title: 'T', dueDate: DateTime.utc(2026, 6, 6));
      expect(task.statusAt(fixedNow), TaskStatus.overdue);
    });

    test('incomplete future dueDate → TaskStatus.incomplete', () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime.utc(2026, 6, 10),
      );
      expect(task.statusAt(fixedNow), TaskStatus.incomplete);
    });

    test('no dueDate → TaskStatus.incomplete', () {
      const task = Task(id: '1', title: 'T');
      expect(task.statusAt(fixedNow), TaskStatus.incomplete);
    });
  });

  group('Task.subtaskProgress', () {
    test('no subtasks → 0', () {
      const task = Task(id: '1', title: 'T');
      expect(task.subtaskProgress, 0);
    });

    test('all subtasks done → 1.0', () {
      final task = Task(
        id: '1',
        title: 'T',
        subtasks: const [
          Subtask(id: 'a', title: 'A', isDone: true),
          Subtask(id: 'b', title: 'B', isDone: true),
        ],
      );
      expect(task.subtaskProgress, 1.0);
    });

    test('half subtasks done → 0.5', () {
      final task = Task(
        id: '1',
        title: 'T',
        subtasks: const [
          Subtask(id: 'a', title: 'A', isDone: true),
          Subtask(id: 'b', title: 'B', isDone: false),
        ],
      );
      expect(task.subtaskProgress, 0.5);
    });
  });

  group('TaskView', () {
    test('isOverdue true when past dueDate', () {
      final task = Task(
        id: '1',
        title: 'Overdue',
        dueDate: DateTime.utc(2026, 6, 6),
      );
      final view = TaskView.from(task, fixedNow);
      expect(view.isOverdue, isTrue);
    });

    test('isOverdue false for completed task even if past due', () {
      final task = Task(
        id: '1',
        title: 'Done',
        status: TaskStatus.complete,
        dueDate: DateTime.utc(2026, 6, 6),
      );
      final view = TaskView.from(task, fixedNow);
      expect(view.isOverdue, isFalse);
    });

    test('subtaskBadge shows done/total', () {
      final task = Task(
        id: '1',
        title: 'T',
        subtasks: const [
          Subtask(id: 'a', title: 'A', isDone: true),
          Subtask(id: 'b', title: 'B', isDone: false),
          Subtask(id: 'c', title: 'C', isDone: true),
        ],
      );
      final view = TaskView.from(task, fixedNow);
      expect(view.subtaskBadge, '2/3');
    });

    test('subtaskBadge is empty when no subtasks', () {
      const task = Task(id: '1', title: 'T');
      final view = TaskView.from(task, fixedNow);
      expect(view.subtaskBadge, '');
    });

    test('dateRangeLabel shows only dueDate when no startDate', () {
      final task = Task(
        id: '1',
        title: 'T',
        dueDate: DateTime.utc(2026, 6, 15),
      );
      final view = TaskView.from(task, fixedNow);
      expect(view.dateRangeLabel, contains('6/15/2026'));
    });

    test('dateRangeLabel shows range when both dates present', () {
      final task = Task(
        id: '1',
        title: 'T',
        startDate: DateTime.utc(2026, 6, 10),
        dueDate: DateTime.utc(2026, 6, 15),
      );
      final view = TaskView.from(task, fixedNow);
      expect(view.dateRangeLabel, contains('–'));
    });

    test('dateRangeLabel empty when no dates', () {
      const task = Task(id: '1', title: 'T');
      final view = TaskView.from(task, fixedNow);
      expect(view.dateRangeLabel, '');
    });

    test('statusLabel for overdue shows "Overdue"', () {
      final task = Task(id: '1', title: 'T', dueDate: DateTime.utc(2026, 6, 1));
      final view = TaskView.from(task, fixedNow);
      expect(view.statusLabel, 'Overdue');
    });

    test('statusLabel for complete shows "Completed"', () {
      const task = Task(id: '1', title: 'T', status: TaskStatus.complete);
      final view = TaskView.from(task, fixedNow);
      expect(view.statusLabel, 'Completed');
    });
  });
}
