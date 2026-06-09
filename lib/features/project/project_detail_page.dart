import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/calendar_page.dart';
import '../calendar/presentation/calendar_view_state_notifier.dart';
import '../task/domain/task_list_scope.dart';
import '../task/task_list_page.dart';
import 'project_providers.dart';

/// A single project: List / Calendar / Gantt tabs, all scoped to the project.
class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    final notifier = ref.read(calendarViewStateProvider.notifier);
    final type = ref.read(calendarViewStateProvider).type;
    if (_tabs.index == 2) {
      notifier.switchView(CalendarViewType.gantt);
    } else if (_tabs.index == 1 && type == CalendarViewType.gantt) {
      notifier.switchView(CalendarViewType.month);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final project = ref.watch(projectByIdProvider(widget.projectId));
    final name = project?.name ?? (l10n?.navProjects ?? 'Project');

    return Scaffold(
      key: const Key('project-detail-page'),
      appBar: AppBar(
        title: Text(name),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n?.projectTabList ?? 'List'),
            Tab(text: l10n?.projectTabCalendar ?? 'Calendar'),
            Tab(text: l10n?.projectTabGantt ?? 'Gantt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          TaskListPage(
            embedded: true,
            scope: ProjectScope(widget.projectId, name: name),
          ),
          CalendarPage(
            projectId: widget.projectId,
            embedded: true,
            showGanttSegment: false,
          ),
          CalendarPage(
            projectId: widget.projectId,
            embedded: true,
            forceGantt: true,
          ),
        ],
      ),
    );
  }
}
