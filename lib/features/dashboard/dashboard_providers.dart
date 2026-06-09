import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/enums/enums.dart';
import '../../core/models/task.dart';
import '../../core/models/task_query.dart';
import '../settings/settings_providers.dart';
import 'domain/dashboard_data.dart';
import 'domain/dashboard_usecase.dart';

/// Singleton pure use case.
final dashboardUseCaseProvider = Provider<DashboardUseCase>(
  (ref) => const DashboardUseCase(),
);

/// Live stream of every incomplete task across all projects (used to compute
/// the dashboard buckets).
final _incompleteTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watch(const TaskQuery(status: TaskStatus.incomplete));
});

/// Configurable "upcoming" window in days (default 7), reactive to settings.
final dashboardUpcomingDaysProvider = Provider<int>((ref) {
  return ref
      .watch(settingsNotifierProvider)
      .maybeWhen(data: (s) => s.dashboardUpcomingDays, orElse: () => 7);
});

/// Grouped dashboard data (Overdue / Today / Upcoming).
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final tasksAsync = ref.watch(_incompleteTasksProvider);
  final upcomingDays = ref.watch(dashboardUpcomingDaysProvider);
  final useCase = ref.watch(dashboardUseCaseProvider);
  return tasksAsync.whenData(
    (tasks) =>
        useCase.group(tasks, now: DateTime.now(), upcomingDays: upcomingDays),
  );
});
