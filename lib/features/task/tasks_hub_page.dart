import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../calendar/domain/gantt_layout.dart';
import '../project/project_providers.dart';

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

    return Scaffold(
      key: const Key('tasks-page'),
      appBar: AppBar(title: Text(l10n?.navTasks ?? 'Tasks')),
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
        ],
      ),
    );
  }
}
