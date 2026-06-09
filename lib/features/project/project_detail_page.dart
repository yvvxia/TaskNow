import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../task/domain/task_list_scope.dart';
import '../task/task_list_page.dart';
import 'project_providers.dart';

/// A single project's task list.
///
/// The per-project Calendar and Gantt tabs were temporarily removed; the
/// previous tabbed implementation is preserved verbatim in
/// `doc/backup/project_detail_page.dart.bak` for potential future use.
class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }
    if (!hasScope) {
      return const Scaffold(
        key: Key('project-detail-page'),
        body: SizedBox.shrink(),
      );
    }

    final l10n = AppLocalizations.of(context);
    final project = ref.watch(projectByIdProvider(projectId));
    final name = project?.name ?? (l10n?.navProjects ?? 'Project');

    return Scaffold(
      key: const Key('project-detail-page'),
      appBar: AppBar(title: Text(name)),
      body: TaskListPage(
        embedded: true,
        scope: ProjectScope(projectId, name: name),
      ),
    );
  }
}
