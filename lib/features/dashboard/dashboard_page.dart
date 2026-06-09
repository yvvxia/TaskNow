import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/project.dart';
import '../../core/models/task.dart';
import '../../core/widgets/shell_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../project/project_providers.dart';
import '../task/presentation/task_list_row.dart';
import '../task/presentation/task_view.dart';
import 'dashboard_providers.dart';

/// Home dashboard: today's and upcoming tasks across all projects, grouped
/// into Overdue / Today / Upcoming sections. This is the app's landing screen.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }
    return Scaffold(
      key: const Key('dashboard-page'),
      body: hasScope ? const _DashboardBody() : const SizedBox.shrink(),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(dashboardDataProvider);
    final upcomingDays = ref.watch(dashboardUpcomingDaysProvider);
    final projects = ref.watch(projectListProvider).asData?.value ?? const [];
    final projectsById = {for (final p in projects) p.id: p};

    return SafeArea(
      child: dataAsync.when(
        // Local DB resolves near-instantly; a static placeholder (rather than a
        // spinning indicator) avoids a ticker on the first frame, matching the
        // task list's loading convention.
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                l10n?.dashboardEmpty ?? 'Nothing due. You are clear!',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionHeader(
                title: l10n?.dashboardOverdue ?? 'Overdue',
                count: data.overdue.length,
                color: Theme.of(context).colorScheme.error,
              ),
              ..._taskTiles(context, ref, data.overdue, projectsById),
              _SectionHeader(
                title: l10n?.dashboardToday ?? 'Today',
                count: data.today.length,
                color: Theme.of(context).colorScheme.primary,
              ),
              ..._taskTiles(context, ref, data.today, projectsById),
              _SectionHeader(
                title:
                    l10n?.dashboardUpcoming(upcomingDays) ??
                    'Upcoming ($upcomingDays days)',
                count: data.upcoming.length,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              ..._taskTiles(context, ref, data.upcoming, projectsById),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _taskTiles(
    BuildContext context,
    WidgetRef ref,
    List<Task> tasks,
    Map<String, Project> projectsById,
  ) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context);
    if (tasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
          child: Text(
            l10n?.dashboardSectionEmpty ?? 'Nothing here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ];
    }
    return [
      for (final task in tasks)
        TaskListRow(
          key: Key('dashboard-task-${task.id}'),
          task: TaskView.from(task, now),
          onTap: () => openTaskDetail(context, ref, task.id),
        ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
