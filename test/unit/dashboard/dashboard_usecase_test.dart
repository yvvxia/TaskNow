import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/dashboard/domain/dashboard_usecase.dart';

void main() {
  const useCase = DashboardUseCase();
  // Local (non-UTC) "now" so toLocal() in the use case is identity and the
  // buckets are independent of the host timezone.
  final now = DateTime(2026, 6, 15, 10);

  Task t(
    String id, {
    DateTime? start,
    DateTime? due,
    TaskStatus status = TaskStatus.incomplete,
  }) => Task(id: id, title: id, startDate: start, dueDate: due, status: status);

  group('DashboardUseCase.group', () {
    test('splits tasks into overdue / today / upcoming buckets', () {
      final data = useCase.group(
        [
          t('overdue', due: DateTime(2026, 6, 14)),
          t('today', due: DateTime(2026, 6, 15, 12)),
          t('upcoming', due: DateTime(2026, 6, 18)),
          t('beyond', due: DateTime(2026, 6, 25)),
        ],
        now: now,
        upcomingDays: 7,
      );

      expect(data.overdue.map((x) => x.id), ['overdue']);
      expect(data.today.map((x) => x.id), ['today']);
      expect(data.upcoming.map((x) => x.id), ['upcoming']);
      expect(data.isEmpty, isFalse);
    });

    test('a task spanning today counts as today, not upcoming', () {
      final data = useCase.group(
        [t('span', start: DateTime(2026, 6, 10), due: DateTime(2026, 6, 20))],
        now: now,
        upcomingDays: 7,
      );

      expect(data.today.map((x) => x.id), ['span']);
      expect(data.upcoming, isEmpty);
    });

    test('completed and dateless tasks are ignored', () {
      final data = useCase.group(
        [
          t('done', due: DateTime(2026, 6, 15), status: TaskStatus.complete),
          t('nodate'),
        ],
        now: now,
        upcomingDays: 7,
      );

      expect(data.isEmpty, isTrue);
    });

    test('upcomingDays widens or narrows the upcoming window', () {
      final tasks = [t('d20', due: DateTime(2026, 6, 20))];

      final narrow = useCase.group(tasks, now: now, upcomingDays: 3);
      final wide = useCase.group(tasks, now: now, upcomingDays: 7);

      expect(narrow.upcoming, isEmpty);
      expect(wide.upcoming.map((x) => x.id), ['d20']);
    });

    test('each bucket is sorted by due date ascending', () {
      final data = useCase.group(
        [
          t('o2', due: DateTime(2026, 6, 13)),
          t('o1', due: DateTime(2026, 6, 10)),
          t('u2', due: DateTime(2026, 6, 19)),
          t('u1', due: DateTime(2026, 6, 17)),
        ],
        now: now,
        upcomingDays: 7,
      );

      expect(data.overdue.map((x) => x.id), ['o1', 'o2']);
      expect(data.upcoming.map((x) => x.id), ['u1', 'u2']);
    });
  });
}
