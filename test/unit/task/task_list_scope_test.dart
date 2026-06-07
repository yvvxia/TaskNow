import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/features/task/domain/task_list_scope.dart';

void main() {
  group('TaskListScope.toQuery', () {
    test('ProjectScope returns query with projectId', () {
      final q = const ProjectScope('proj-1').toQuery();
      expect(q.projectId, 'proj-1');
      expect(q.status, isNull);
    });

    test('TagScope returns query with tagIds containing the id', () {
      final q = const TagScope('tag-1').toQuery();
      expect(q.tagIds, contains('tag-1'));
      expect(q.projectId, isNull);
    });

    test('TodayScope returns query sorted by dueDate', () {
      final q = const TodayScope().toQuery();
      expect(q.sort, TaskSort.dueDate);
      expect(q.status, isNull);
    });

    test('OverdueScope returns query with status=overdue', () {
      final q = const OverdueScope().toQuery();
      expect(q.status, TaskStatus.overdue);
    });

    test('CompletedScope returns query with status=complete', () {
      final q = const CompletedScope().toQuery();
      expect(q.status, TaskStatus.complete);
    });

    test('InboxScope returns query without projectId filter', () {
      final q = const InboxScope().toQuery();
      expect(q.projectId, isNull);
    });

    test('AllScope returns empty query', () {
      final q = const AllScope().toQuery();
      expect(q.status, isNull);
      expect(q.projectId, isNull);
      expect(q.tagIds, isEmpty);
    });
  });

  group('TaskListScope equality', () {
    test('same ProjectScope instances are equal', () {
      expect(
        const ProjectScope('p1'),
        equals(const ProjectScope('p1')),
      );
    });

    test('different ProjectScope projectIds are not equal', () {
      expect(
        const ProjectScope('p1'),
        isNot(equals(const ProjectScope('p2'))),
      );
    });

    test('same TagScope instances are equal', () {
      expect(const TagScope('t1'), equals(const TagScope('t1')));
    });

    test('singleton scopes equal themselves', () {
      expect(const TodayScope(), equals(const TodayScope()));
      expect(const OverdueScope(), equals(const OverdueScope()));
      expect(const CompletedScope(), equals(const CompletedScope()));
      expect(const InboxScope(), equals(const InboxScope()));
      expect(const AllScope(), equals(const AllScope()));
    });
  });

  group('TaskListScope.label', () {
    test('TodayScope label is "Today"', () {
      expect(const TodayScope().label, 'Today');
    });

    test('OverdueScope label is "Overdue"', () {
      expect(const OverdueScope().label, 'Overdue');
    });

    test('AllScope label is "All Tasks"', () {
      expect(const AllScope().label, 'All Tasks');
    });

    test('CompletedScope label is "Completed"', () {
      expect(const CompletedScope().label, 'Completed');
    });

    test('InboxScope label is "Inbox"', () {
      expect(const InboxScope().label, 'Inbox');
    });

    test('ProjectScope uses provided name', () {
      expect(const ProjectScope('p', name: 'Work').label, 'Work');
    });
  });
}
