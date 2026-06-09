import '../../../core/models/task.dart';

/// Grouped view of the tasks shown on the home dashboard.
///
/// The three buckets are mutually exclusive (a task appears in at most one).
class DashboardData {
  const DashboardData({
    this.overdue = const [],
    this.today = const [],
    this.upcoming = const [],
  });

  /// Incomplete tasks whose due date is before today.
  final List<Task> overdue;

  /// Incomplete tasks active today (due today or spanning today).
  final List<Task> today;

  /// Incomplete tasks due within the configured upcoming window (but not
  /// active today).
  final List<Task> upcoming;

  bool get isEmpty => overdue.isEmpty && today.isEmpty && upcoming.isEmpty;
}
