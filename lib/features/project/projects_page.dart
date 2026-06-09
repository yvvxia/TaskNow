import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/enums.dart';
import '../../core/models/project.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/domain/gantt_layout.dart';
import 'presentation/project_edit_dialog.dart';
import 'project_providers.dart';

/// The default Inbox project id (seeded by the data layer). It cannot be
/// deleted from the UI.
const String kInboxProjectIdUi = 'inbox';

/// Lists all projects. Tapping a project opens its detail page (List / Calendar
/// / Gantt). New projects are created here; tasks are created inside a project.
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }
    if (!hasScope) {
      return const Scaffold(key: Key('projects-page'), body: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      key: const Key('projects-page'),
      appBar: AppBar(title: Text(l10n?.navProjects ?? 'Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Text(l10n?.projectsEmpty ?? 'No projects yet'),
            );
          }
          return ListView(
            children: [
              for (final p in projects)
                _ProjectTile(
                  project: p,
                  onOpen: () => context.go('/projects/${p.id}'),
                  onEdit: () => _edit(context, ref, p),
                  onDelete: p.id == kInboxProjectIdUi
                      ? null
                      : () => _delete(context, ref, p),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showProjectEditDialog(context);
    if (result == null) return;
    await ref
        .read(createProjectUseCaseProvider)
        .call(result.name, color: result.color);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final result = await showProjectEditDialog(
      context,
      initialName: project.name,
      initialColor: project.color,
    );
    if (result == null) return;
    await ref
        .read(updateProjectUseCaseProvider)
        .call(project.copyWith(name: result.name, color: result.color));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final l10n = AppLocalizations.of(context);
    final mode = await showDialog<ProjectDeleteMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.projectDeleteTitle ?? 'Delete project?'),
        content: Text(
          l10n?.projectDeleteMessage(project.name) ??
              'What should happen to the tasks in "${project.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(ProjectDeleteMode.moveToInbox),
            child: Text(l10n?.projectDeleteMoveInbox ?? 'Move to Inbox'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(ProjectDeleteMode.deleteTasks),
            child: Text(l10n?.projectDeleteWithTasks ?? 'Delete tasks'),
          ),
        ],
      ),
    );
    if (mode == null) return;
    await ref.read(deleteProjectUseCaseProvider).call(project.id, mode: mode);
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.onOpen,
    required this.onEdit,
    this.onDelete,
  });

  final Project project;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color =
        GanttLayout.parseColor(project.color) ??
        GanttLayout.projectColor(project.id);
    return ListTile(
      key: Key('project-tile-${project.id}'),
      leading: CircleAvatar(backgroundColor: color, radius: 10),
      title: Text(project.name),
      onTap: onOpen,
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') onEdit();
          if (v == 'delete') onDelete?.call();
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l10n?.actionEdit ?? 'Edit')),
          if (onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n?.actionDelete ?? 'Delete'),
            ),
        ],
      ),
    );
  }
}
