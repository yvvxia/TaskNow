import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/setting_keys.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/semantic_colors.dart';
import '../../features/calendar/domain/gantt_layout.dart';
import '../../features/project/presentation/project_edit_dialog.dart';
import '../../features/project/project_providers.dart';
import '../../features/search/presentation/search_overlay.dart' as search_ui;
import '../../features/tag/presentation/tag_create_dialog.dart';
import '../../features/tag/tag_providers.dart';
import '../../features/task/presentation/add_task_sheet.dart';
import '../../features/task/presentation/task_detail_panel.dart';
import '../../features/task/task_providers.dart';
import '../../l10n/app_localizations.dart';
import 'layout_breakpoints.dart';
import 'shell_navigation.dart';
import 'shell_providers.dart';

export 'layout_breakpoints.dart' show kCompactBreakpoint, kExpandedBreakpoint;

/// A navigation destination shown in the adaptive shell.
class AdaptiveDestination {
  const AdaptiveDestination(this.route, this.icon, this.label);

  final String route;
  final IconData icon;

  /// English fallback label, used when localizations are unavailable
  /// (e.g. isolated widget tests without the [AppLocalizations] delegate).
  final String label;

  /// Resolves the localized label for this destination, falling back to
  /// [label] when no [AppLocalizations] is in the tree.
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return label;
    switch (route) {
      case '/tasks':
        return l10n.navTasks;
      case '/calendar':
        return l10n.navCalendar;
      case search_ui.kSearchOverlayRoute:
        return l10n.navSearch;
      case '/settings':
        return l10n.navSettings;
      default:
        return label;
    }
  }
}

/// Shell destinations for compact (mobile) and medium layouts — 3 items, no Settings.
const List<AdaptiveDestination> kShellDestinations = <AdaptiveDestination>[
  AdaptiveDestination('/tasks', Icons.task_alt_outlined, 'Tasks'),
  AdaptiveDestination('/calendar', Icons.calendar_month, 'Calendar'),
  AdaptiveDestination(search_ui.kSearchOverlayRoute, Icons.search, 'Search'),
];

/// Whether [location] belongs to the Tasks group (overview, hub, projects).
bool isTasksGroupLocation(String location) {
  return location.startsWith('/dashboard') ||
      location.startsWith('/projects') ||
      location.startsWith('/tasks') ||
      location.startsWith('/task/');
}

/// Responsive application shell.
///
/// * `< 600dp`  → compact: shell AppBar + bottom [NavigationBar] (3 tabs) + FAB.
/// * `600–1024dp` → medium: [NavigationRail] + content.
/// * `> 1024dp` → expanded: top bar + sidebar tree + content + right detail panel.
class AdaptiveScaffold extends ConsumerStatefulWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.onDestinationSelected,
  });

  final Widget child;
  final String location;
  final ValueChanged<String> onDestinationSelected;

  @override
  ConsumerState<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends ConsumerState<AdaptiveScaffold> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _loadSidebarCollapsed();
  }

  void _loadSidebarCollapsed() {
    try {
      final collapsed = ref
          .read(settingsStoreProvider)
          .get(SettingKeys.sidebarCollapsed);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(sidebarCollapsedProvider.notifier).state = collapsed;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    if (widget.location.startsWith('/calendar')) return 1;
    if (isTasksGroupLocation(widget.location)) return 0;
    return 0;
  }

  void _selectIndex(int index) {
    final dest = kShellDestinations[index];
    if (dest.route == search_ui.kSearchOverlayRoute) {
      search_ui.openSearchOverlay(_searchController, fullScreen: true);
      return;
    }
    widget.onDestinationSelected(dest.route);
  }

  Future<void> _openAddTask(BuildContext context) async {
    await showAddTaskSheet(
      context,
      onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
    );
  }

  @override
  Widget build(BuildContext context) {
    return search_ui.AppSearchOverlay(
      searchController: _searchController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width < kCompactBreakpoint) {
            return _buildCompact(context);
          }
          if (width <= kExpandedBreakpoint) {
            return _buildMedium(context);
          }
          return _buildExpanded(context);
        },
      ),
    );
  }

  PreferredSizeWidget _buildShellAppBar(
    BuildContext context, {
    bool showCollapse = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(l10n?.appTitle ?? 'Liveline'),
      actions: [
        IconButton(
          key: const Key('shell-search'),
          icon: const Icon(Icons.search),
          tooltip: l10n?.navSearch ?? 'Search',
          onPressed: () => search_ui.openSearchOverlay(_searchController),
        ),
        IconButton(
          key: const Key('shell-settings'),
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.navSettings ?? 'Settings',
          onPressed: () => widget.onDestinationSelected('/settings'),
        ),
        Tooltip(
          message: l10n?.guestAccount ?? 'Guest',
          child: CircleAvatar(
            radius: 14,
            backgroundColor: palette.surfaceContainer,
            child: Icon(
              Icons.person_outline,
              size: 18,
              color: palette.onSurfaceVariant,
            ),
          ),
        ),
        if (showCollapse) ...[
          IconButton(
            icon: Icon(
              ref.watch(sidebarCollapsedProvider)
                  ? Icons.chevron_right
                  : Icons.chevron_left,
            ),
            tooltip: l10n?.sidebarCollapse ?? 'Collapse sidebar',
            onPressed: _toggleSidebar,
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Future<void> _toggleSidebar() async {
    final next = !ref.read(sidebarCollapsedProvider);
    ref.read(sidebarCollapsedProvider.notifier).state = next;
    try {
      await ref
          .read(settingsStoreProvider)
          .set(SettingKeys.sidebarCollapsed, next);
    } catch (_) {}
  }

  Widget _buildCompact(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: _buildShellAppBar(context),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        key: const Key('shell-fab'),
        onPressed: () => _openAddTask(context),
        tooltip: l10n?.newTask ?? 'New task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectIndex,
        destinations: <Widget>[
          for (final d in kShellDestinations)
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.localizedLabel(context),
            ),
        ],
      ),
    );
  }

  Widget _buildMedium(BuildContext context) {
    return Scaffold(
      appBar: _buildShellAppBar(context),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectIndex,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              for (final d in kShellDestinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.localizedLabel(context)),
                ),
            ],
          ),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('shell-fab'),
        onPressed: () => _openAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);

    return Scaffold(
      appBar: _buildShellAppBar(context, showCollapse: true),
      body: Row(
        children: <Widget>[
          _DesktopSidebar(
            location: widget.location,
            collapsed: collapsed,
            onNavigate: widget.onDestinationSelected,
            onOpenSearch: () => search_ui.openSearchOverlay(_searchController),
          ),
          Expanded(flex: 2, child: widget.child),
          _DetailPanel(taskId: selectedId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('shell-fab'),
        onPressed: () => _openAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
    required this.location,
    required this.collapsed,
    required this.onNavigate,
    required this.onOpenSearch,
  });

  final String location;
  final bool collapsed;
  final ValueChanged<String> onNavigate;
  final VoidCallback onOpenSearch;

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final result = await showProjectEditDialog(context);
    if (result == null) return;
    await ref
        .read(createProjectUseCaseProvider)
        .call(result.name, color: result.color);
  }

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    final name = await showTagCreateDialog(context);
    if (name == null) return;
    await ref.read(createTagUseCaseProvider).call(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);
    final projectsAsync = ref.watch(projectListProvider);
    final tagsAsync = ref.watch(tagListProvider);
    final tasksActive = isTasksGroupLocation(location);
    final calendarActive = location.startsWith('/calendar');
    final settingsActive = location.startsWith('/settings');
    final overviewActive = location.startsWith('/dashboard');
    final projectsActive = location.startsWith('/projects');
    final filtersActive =
        location == '/tasks/today' ||
        location == '/tasks/overdue' ||
        location == '/tasks/completed';
    final tagsActive = location.startsWith('/tasks/tag/');
    final width = collapsed
        ? AppSpacing.sidebarCollapsedWidth
        : AppSpacing.sidebarWidth;

    Widget tile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool selected = false,
      Key? key,
      double leftPad = 0,
    }) {
      if (collapsed) {
        return Tooltip(
          message: label,
          child: IconButton(
            key: key,
            icon: Icon(icon),
            color: selected ? palette.primary : palette.onSurfaceVariant,
            style: IconButton.styleFrom(
              backgroundColor: selected
                  ? palette.primary.withValues(alpha: 0.12)
                  : null,
            ),
            onPressed: onTap,
          ),
        );
      }
      return ListTile(
        key: key,
        contentPadding: EdgeInsets.only(left: 16 + leftPad, right: 16),
        leading: Icon(icon, size: 20),
        title: Text(label),
        selected: selected,
        selectedTileColor: palette.primary.withValues(alpha: 0.12),
        onTap: onTap,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      key: const Key('desktop-sidebar'),
      width: width,
      child: Material(
        color: palette.surfaceContainerLow,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: collapsed ? 8 : 0),
          children: <Widget>[
            if (!collapsed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n?.appTitle ?? 'Liveline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            if (collapsed) const SizedBox(height: 8),
            if (collapsed)
              tile(
                icon: Icons.task_alt_outlined,
                label: l10n?.navTasks ?? 'Tasks',
                selected: tasksActive,
                onTap: () => onNavigate('/tasks'),
              )
            else
              ExpansionTile(
                key: const Key('sidebar-tasks'),
                initiallyExpanded: true,
                leading: const Icon(Icons.task_alt_outlined, size: 20),
                title: Text(l10n?.navTasks ?? 'Tasks'),
                iconColor: tasksActive ? palette.primary : null,
                children: [
                  tile(
                    key: const Key('sidebar-overview'),
                    icon: Icons.dashboard_outlined,
                    label: l10n?.navDashboard ?? 'Dashboard',
                    selected: overviewActive,
                    leftPad: 16,
                    onTap: () => onNavigate('/dashboard'),
                  ),
                  projectsAsync.when(
                    loading: () => tile(
                      icon: Icons.folder_outlined,
                      label: '…',
                      onTap: () {},
                      leftPad: 16,
                    ),
                    error: (e, _) => tile(
                      icon: Icons.error_outline,
                      label: '$e',
                      onTap: () {},
                      leftPad: 16,
                    ),
                    data: (projects) => collapsed
                        ? const SizedBox.shrink()
                        : ExpansionTile(
                            key: const Key('sidebar-projects'),
                            initiallyExpanded: true,
                            tilePadding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            childrenPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.folder_outlined,
                              size: 20,
                            ),
                            title: Text(l10n?.navProjects ?? 'Projects'),
                            iconColor: projectsActive ? palette.primary : null,
                            children: [
                              if (projects.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    48,
                                    0,
                                    16,
                                    8,
                                  ),
                                  child: Text(
                                    l10n?.projectsEmpty ?? 'No projects yet',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                )
                              else
                                for (final p in projects)
                                  ListTile(
                                    key: Key('sidebar-project-${p.id}'),
                                    contentPadding: const EdgeInsets.only(
                                      left: 48,
                                      right: 16,
                                    ),
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 8,
                                      backgroundColor:
                                          GanttLayout.parseColor(p.color) ??
                                          GanttLayout.projectColor(p.id),
                                    ),
                                    title: Text(p.name),
                                    selected: location.startsWith(
                                      '/projects/${p.id}',
                                    ),
                                    selectedTileColor: palette.primary
                                        .withValues(alpha: 0.12),
                                    onTap: () =>
                                        onNavigate('/projects/${p.id}'),
                                  ),
                              ListTile(
                                key: const Key('sidebar-project-create'),
                                contentPadding: const EdgeInsets.only(
                                  left: 48,
                                  right: 16,
                                ),
                                dense: true,
                                leading: const Icon(Icons.add, size: 18),
                                title: Text(
                                  l10n?.projectCreateTitle ?? 'New project',
                                ),
                                onTap: () => _createProject(context, ref),
                              ),
                            ],
                          ),
                  ),
                  ExpansionTile(
                    key: const Key('sidebar-filters'),
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.only(left: 32, right: 16),
                    childrenPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.filter_list, size: 20),
                    title: Text(l10n?.navFilters ?? 'Filters'),
                    iconColor: filtersActive ? palette.primary : null,
                    children: [
                      tile(
                        key: const Key('sidebar-filter-today'),
                        icon: Icons.today_outlined,
                        label: l10n?.filterToday ?? 'Today',
                        selected: location == '/tasks/today',
                        leftPad: 32,
                        onTap: () => onNavigate('/tasks/today'),
                      ),
                      tile(
                        key: const Key('sidebar-filter-overdue'),
                        icon: Icons.warning_amber_outlined,
                        label: l10n?.filterOverdue ?? 'Overdue',
                        selected: location == '/tasks/overdue',
                        leftPad: 32,
                        onTap: () => onNavigate('/tasks/overdue'),
                      ),
                      tile(
                        key: const Key('sidebar-filter-completed'),
                        icon: Icons.check_circle_outline,
                        label: l10n?.filterCompleted ?? 'Completed',
                        selected: location == '/tasks/completed',
                        leftPad: 32,
                        onTap: () => onNavigate('/tasks/completed'),
                      ),
                    ],
                  ),
                  tagsAsync.when(
                    loading: () => tile(
                      icon: Icons.label_outline,
                      label: '…',
                      onTap: () {},
                      leftPad: 16,
                    ),
                    error: (e, _) => tile(
                      icon: Icons.error_outline,
                      label: '$e',
                      onTap: () {},
                      leftPad: 16,
                    ),
                    data: (tags) => collapsed
                        ? const SizedBox.shrink()
                        : ExpansionTile(
                            key: const Key('sidebar-tags'),
                            initiallyExpanded: true,
                            tilePadding: const EdgeInsets.only(
                              left: 32,
                              right: 16,
                            ),
                            childrenPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.label_outline, size: 20),
                            title: Text(l10n?.navTags ?? 'Tags'),
                            iconColor: tagsActive ? palette.primary : null,
                            children: [
                              if (tags.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    48,
                                    0,
                                    16,
                                    8,
                                  ),
                                  child: Text(
                                    l10n?.tagsEmpty ?? 'No tags yet',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                )
                              else
                                for (final tag in tags)
                                  ListTile(
                                    key: Key('sidebar-tag-${tag.id}'),
                                    contentPadding: const EdgeInsets.only(
                                      left: 48,
                                      right: 16,
                                    ),
                                    dense: true,
                                    leading: const Icon(
                                      Icons.label_outline,
                                      size: 18,
                                    ),
                                    title: Text(tag.name),
                                    selected: location.startsWith(
                                      '/tasks/tag/${tag.id}',
                                    ),
                                    selectedTileColor: palette.primary
                                        .withValues(alpha: 0.12),
                                    onTap: () =>
                                        onNavigate('/tasks/tag/${tag.id}'),
                                  ),
                              ListTile(
                                key: const Key('sidebar-tag-create'),
                                contentPadding: const EdgeInsets.only(
                                  left: 48,
                                  right: 16,
                                ),
                                dense: true,
                                leading: const Icon(Icons.add, size: 18),
                                title: Text(l10n?.tagCreateTitle ?? 'New tag'),
                                onTap: () => _createTag(context, ref),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            tile(
              icon: Icons.calendar_month,
              label: l10n?.navCalendar ?? 'Calendar',
              selected: calendarActive,
              onTap: () => onNavigate('/calendar'),
            ),
            tile(
              key: const Key('sidebar-search'),
              icon: Icons.search,
              label: l10n?.navSearch ?? 'Search',
              onTap: onOpenSearch,
            ),
            tile(
              icon: Icons.settings_outlined,
              label: l10n?.navSettings ?? 'Settings',
              selected: settingsActive,
              onTap: () => onNavigate('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPanel extends ConsumerWidget {
  const _DetailPanel({this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);

    return Container(
      key: const Key('detail-panel'),
      width: AppSpacing.detailPanelWidth,
      decoration: BoxDecoration(
        color: palette.surfaceContainerLow,
        border: Border(left: BorderSide(color: palette.outline)),
      ),
      child: taskId == null
          ? Center(
              child: Text(
                l10n?.selectTaskHint ?? 'Select a task',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => clearTaskDetailSelection(ref),
                  ),
                ),
                Expanded(child: TaskDetailPanel(taskId: taskId)),
              ],
            ),
    );
  }
}
