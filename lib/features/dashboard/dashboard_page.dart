import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/project.dart';
import '../../core/models/task.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/domain/gantt_layout.dart';
import '../project/project_providers.dart';
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
        _DashboardTaskTile(task: task, project: projectsById[task.projectId]),
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

class _DashboardTaskTile extends StatelessWidget {
  const _DashboardTaskTile({required this.task, required this.project});

  final Task task;
  final Project? project;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final due = task.dueDate?.toLocal();
    final dueLabel = due == null
        ? null
        : DateFormat.MMMEd(l10n?.localeName).add_jm().format(due);
    final projectName = project?.name;
    final dotColor = project == null
        ? Theme.of(context).colorScheme.outline
        : (GanttLayout.parseColor(project!.color) ??
              GanttLayout.projectColor(task.projectId ?? ''));

    return ListTile(
      key: Key('dashboard-task-${task.id}'),
      dense: true,
      leading: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [?projectName, ?dueLabel].join('  ·  '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.go('/task/${task.id}'),
    );
  }
}
