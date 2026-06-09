import '../../../core/enums/enums.dart';
import '../../../core/models/task.dart';
import 'dashboard_data.dart';

/// Pure grouping of tasks into Overdue / Today / Upcoming buckets for the
/// dashboard. Completed and dateless tasks are ignored. The three buckets are
/// mutually exclusive.
final class DashboardUseCase {
  const DashboardUseCase();

  DashboardData group(
    List<Task> tasks, {
    required DateTime now,
    required int upcomingDays,
  }) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final upcomingEnd = startOfToday.add(Duration(days: upcomingDays + 1));

    final overdue = <Task>[];
    final today = <Task>[];
    final upcoming = <Task>[];

    for (final task in tasks) {
      if (task.status == TaskStatus.complete) continue;

      final due = task.dueDate?.toLocal();
      final start = task.startDate?.toLocal();
      final effStart = start ?? due;
      final effEnd = due ?? start;
      if (effStart == null || effEnd == null) continue;

      final isOverdue = due != null && due.isBefore(startOfToday);
      if (isOverdue) {
        overdue.add(task);
        continue;
      }

      final activeToday =
          !effStart.isAfter(endOfToday) && !effEnd.isBefore(startOfToday);
      if (activeToday) {
        today.add(task);
        continue;
      }

      if (due != null && due.isAfter(endOfToday) && due.isBefore(upcomingEnd)) {
        upcoming.add(task);
      }
    }

    int byDue(Task a, Task b) {
      final da = a.dueDate ?? a.startDate;
      final db = b.dueDate ?? b.startDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    }

    overdue.sort(byDue);
    today.sort(byDue);
    upcoming.sort(byDue);

    return DashboardData(overdue: overdue, today: today, upcoming: upcoming);
  }
}
