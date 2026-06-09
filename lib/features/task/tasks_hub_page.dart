import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../calendar/domain/gantt_layout.dart';
import '../project/project_providers.dart';
import '../tag/tag_providers.dart';

/// Mobile/tablet "Tasks hub": overview + expandable project folder listing
/// every project. Desktop users see the same tree in the sidebar instead.
class TasksHubPage extends ConsumerWidget {
  const TasksHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }
    if (!hasScope) {
      return const Scaffold(key: Key('tasks-page'), body: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final projectsAsync = ref.watch(projectListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      key: const Key('tasks-page'),
      body: ListView(
        children: [
          ListTile(
            key: const Key('tasks-hub-overview'),
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(l10n?.navDashboard ?? 'Dashboard'),
            onTap: () => context.go('/dashboard'),
          ),
          projectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ListTile(title: Text('$e')),
            data: (projects) => ExpansionTile(
              key: const Key('tasks-hub-projects'),
              initiallyExpanded: true,
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n?.navProjects ?? 'Projects'),
              children: [
                if (projects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      l10n?.projectsEmpty ?? 'No projects yet',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  for (final p in projects)
                    ListTile(
                      key: Key('tasks-hub-project-${p.id}'),
                      contentPadding: const EdgeInsets.only(
                        left: 32,
                        right: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            GanttLayout.parseColor(p.color) ??
                            GanttLayout.projectColor(p.id),
                      ),
                      title: Text(p.name),
                      onTap: () => context.go('/projects/${p.id}'),
                    ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n?.navTags ?? 'Tags',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          tagsAsync.when(
            loading: () => const ListTile(title: Text('…')),
            error: (e, _) => ListTile(title: Text('$e')),
            data: (tags) {
              if (tags.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n?.tagsEmpty ?? 'No tags yet',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return Column(
                children: [
                  for (final tag in tags)
                    ListTile(
                      key: Key('tasks-hub-tag-${tag.id}'),
                      leading: const Icon(Icons.label_outline),
                      title: Text(tag.name),
                      onTap: () => context.go('/tasks/tag/${tag.id}'),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n?.navFilters ?? 'Filters',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          ListTile(
            key: const Key('tasks-hub-filter-today'),
            leading: const Icon(Icons.today_outlined),
            title: Text(l10n?.filterToday ?? 'Today'),
            onTap: () => context.go('/tasks/today'),
          ),
          ListTile(
            key: const Key('tasks-hub-filter-overdue'),
            leading: const Icon(Icons.warning_amber_outlined),
            title: Text(l10n?.filterOverdue ?? 'Overdue'),
            onTap: () => context.go('/tasks/overdue'),
          ),
          ListTile(
            key: const Key('tasks-hub-filter-completed'),
            leading: const Icon(Icons.check_circle_outline),
            title: Text(l10n?.filterCompleted ?? 'Completed'),
            onTap: () => context.go('/tasks/completed'),
          ),
        ],
      ),
    );
  }
}
