import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/setting_keys.dart';
import '../../core/theme/app_radius.dart';
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
import '../../features/task/presentation/task_nav_drawer.dart';
import '../../features/task/task_providers.dart';
import '../../l10n/app_localizations.dart';
import 'layout_breakpoints.dart';
import 'shell_navigation.dart';
import 'shell_providers.dart';
import 'window_title_bar.dart';

export 'layout_breakpoints.dart' show kCompactBreakpoint, kExpandedBreakpoint;

/// Slide duration for the desktop detail drawer (matches route transitions).
const Duration _detailDrawerDuration = Duration(milliseconds: 260);

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
      case '/dashboard':
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

/// Shell destinations for the medium layout — 3 items, no Settings.
const List<AdaptiveDestination> kShellDestinations = <AdaptiveDestination>[
  // The Tasks tab lands on the dashboard overview; task navigation (filters,
  // projects, tags) is reached through the hamburger drawer on phones and the
  // secondary sidebar on desktop.
  AdaptiveDestination('/dashboard', Icons.task_alt_outlined, 'Tasks'),
  AdaptiveDestination('/calendar', Icons.calendar_month, 'Calendar'),
  AdaptiveDestination(search_ui.kSearchOverlayRoute, Icons.search, 'Search'),
];

/// Shell destinations for the compact (phone) layout. Settings lives in the
/// bottom navigation bar here (instead of the top app bar) so the cramped phone
/// app bar only needs to carry the title and account avatar.
const List<AdaptiveDestination> kCompactShellDestinations =
    <AdaptiveDestination>[
      AdaptiveDestination('/dashboard', Icons.task_alt_outlined, 'Tasks'),
      AdaptiveDestination('/calendar', Icons.calendar_month, 'Calendar'),
      AdaptiveDestination(search_ui.kSearchOverlayRoute, Icons.search, 'Search'),
      AdaptiveDestination('/settings', Icons.settings_outlined, 'Settings'),
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

  int get _compactSelectedIndex {
    if (widget.location.startsWith('/calendar')) return 1;
    if (widget.location.startsWith('/settings')) return 3;
    if (isTasksGroupLocation(widget.location)) return 0;
    return 0;
  }

  void _selectCompactIndex(int index) {
    final dest = kCompactShellDestinations[index];
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
    bool showActions = true,
    bool showSearchAction = true,
    bool showSettingsAction = true,
    Widget? leading,
  }) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);

    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      flexibleSpace: const WindowAppBarDragRegion(),
      title: WindowDragRegion(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n?.appTitle ?? 'Liveline'),
        ),
      ),
      actions: [
        if (showActions) ...[
          if (showSearchAction)
            IconButton(
              key: const Key('shell-search'),
              icon: const Icon(Icons.search),
              tooltip: l10n?.navSearch ?? 'Search',
              onPressed: () => search_ui.openSearchOverlay(_searchController),
            ),
          if (showSettingsAction)
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
        ],
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
        const WindowCaptionButtons(),
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
    // The Tasks section swaps its drill-down list for a hamburger + navigation
    // drawer on phones. Detail routes (which carry their own back button) and
    // project detail keep the plain shell bar.
    final showTaskDrawer =
        widget.location == '/dashboard' || widget.location.startsWith('/tasks');
    return Scaffold(
      appBar: _buildShellAppBar(
        context,
        // Search and Settings live in the bottom navigation bar on phones, so
        // the top app bar drops them (the bottom search would otherwise clash).
        showSearchAction: false,
        showSettingsAction: false,
        leading: showTaskDrawer
            ? Builder(
                builder: (innerContext) => IconButton(
                  key: const Key('shell-menu'),
                  icon: const Icon(Icons.menu),
                  tooltip: MaterialLocalizations.of(
                    innerContext,
                  ).openAppDrawerTooltip,
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: showTaskDrawer ? TaskNavDrawer(location: widget.location) : null,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        key: const Key('shell-fab'),
        onPressed: () => _openAddTask(context),
        tooltip: l10n?.newTask ?? 'New task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _compactSelectedIndex,
        onDestinationSelected: _selectCompactIndex,
        destinations: <Widget>[
          for (final d in kCompactShellDestinations)
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
    final tasksActive = isTasksGroupLocation(widget.location);
    // The secondary column only carries sub-options for the Tasks section;
    // other sections (Calendar, Settings) use the full content width.
    final showSecondary = tasksActive && !collapsed;

    return Scaffold(
      appBar: _buildShellAppBar(
        context,
        showCollapse: tasksActive,
        showActions: false,
      ),
      body: Row(
        children: <Widget>[
          _PrimaryRail(
            location: widget.location,
            onNavigate: widget.onDestinationSelected,
            onOpenSearch: () => search_ui.openSearchOverlay(_searchController),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.centerLeft,
              widthFactor: showSecondary ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: _SecondaryNav(
                location: widget.location,
                onNavigate: widget.onDestinationSelected,
              ),
            ),
          ),
          Expanded(flex: 2, child: widget.child),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.centerRight,
              widthFactor: selectedId == null ? 0.0 : 1.0,
              duration: _detailDrawerDuration,
              curve: Curves.easeOutCubic,
              child: _DetailPanel(taskId: selectedId),
            ),
          ),
        ],
      ),
    );
  }
}

/// Narrow always-visible icon rail listing the top-level destinations on the
/// expanded desktop layout. The active section's sub-options live in the
/// adjacent [_SecondaryNav] column.
class _PrimaryRail extends ConsumerWidget {
  const _PrimaryRail({
    required this.location,
    required this.onNavigate,
    required this.onOpenSearch,
  });

  final String location;
  final ValueChanged<String> onNavigate;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);
    final tasksActive = isTasksGroupLocation(location);
    final calendarActive = location.startsWith('/calendar');
    final settingsActive = location.startsWith('/settings');

    Widget railButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool selected = false,
      Key? key,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Tooltip(
          message: label,
          child: Material(
            color: selected
                ? palette.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: key,
              onTap: onTap,
              child: SizedBox(
                width: AppSpacing.railWidth - 24,
                height: 36,
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? palette.primary : palette.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      key: const Key('desktop-rail'),
      width: AppSpacing.railWidth,
      child: Material(
        color: palette.surfaceContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 12),
            Tooltip(
              message: l10n?.guestAccount ?? 'Guest',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: palette.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: palette.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            railButton(
              key: const Key('rail-tasks'),
              icon: Icons.task_alt_outlined,
              label: l10n?.navTasks ?? 'Tasks',
              selected: tasksActive,
              onTap: () => onNavigate('/dashboard'),
            ),
            railButton(
              key: const Key('rail-calendar'),
              icon: Icons.calendar_month,
              label: l10n?.navCalendar ?? 'Calendar',
              selected: calendarActive,
              onTap: () => onNavigate('/calendar'),
            ),
            railButton(
              key: const Key('rail-search'),
              icon: Icons.search,
              label: l10n?.navSearch ?? 'Search',
              onTap: onOpenSearch,
            ),
            const Spacer(),
            railButton(
              key: const Key('rail-settings'),
              icon: Icons.settings_outlined,
              label: l10n?.navSettings ?? 'Settings',
              selected: settingsActive,
              onTap: () => onNavigate('/settings'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Dedicated column listing the sub-options of the active section (the Tasks
/// overview, projects, filters and tags) on the expanded desktop layout.
class _SecondaryNav extends ConsumerWidget {
  const _SecondaryNav({required this.location, required this.onNavigate});

  final String location;
  final ValueChanged<String> onNavigate;

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
    final overviewActive = location.startsWith('/dashboard');
    final projectsActive = location.startsWith('/projects');
    final filtersActive =
        location == '/tasks/today' ||
        location == '/tasks/overdue' ||
        location == '/tasks/completed';
    final tagsActive = location.startsWith('/tasks/tag/');

    Widget tile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool selected = false,
      Key? key,
      double leftPad = 0,
    }) {
      return ListTile(
        key: key,
        contentPadding: EdgeInsets.only(left: 8 + leftPad, right: 8),
        leading: Icon(icon, size: 20),
        title: Text(label),
        selected: selected,
        onTap: onTap,
      );
    }

    return SizedBox(
      key: const Key('desktop-sidebar'),
      width: AppSpacing.secondaryNavWidth,
      child: Material(
        color: palette.surfaceContainerLow,
        child: Theme(
          data: Theme.of(context).copyWith(
            visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
            listTileTheme: Theme.of(context).listTileTheme.copyWith(
              minTileHeight: 40,
              selectedColor: palette.primary,
              selectedTileColor: palette.primary.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            children: <Widget>[
              Padding(
                key: const Key('sidebar-tasks'),
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Text(
                  l10n?.navTasks ?? 'Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              tile(
                key: const Key('sidebar-overview'),
                icon: Icons.dashboard_outlined,
                label: l10n?.navDashboard ?? 'Dashboard',
                selected: overviewActive,
                onTap: () => onNavigate('/dashboard'),
              ),
              projectsAsync.when(
                loading: () =>
                    tile(icon: Icons.folder_outlined, label: '…', onTap: () {}),
                error: (e, _) =>
                    tile(icon: Icons.error_outline, label: '$e', onTap: () {}),
                data: (projects) => ExpansionTile(
                  key: const Key('sidebar-projects'),
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.only(left: 8, right: 8),
                  childrenPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined, size: 20),
                  title: Text(l10n?.navProjects ?? 'Projects'),
                  iconColor: projectsActive ? palette.primary : null,
                  children: [
                    if (projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 8, 8),
                        child: Text(
                          l10n?.projectsEmpty ?? 'No projects yet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      for (final p in projects)
                        ListTile(
                          key: Key('sidebar-project-${p.id}'),
                          contentPadding: const EdgeInsets.only(
                            left: 24,
                            right: 8,
                          ),
                          dense: true,
                          leading: CircleAvatar(
                            radius: 8,
                            backgroundColor:
                                GanttLayout.parseColor(p.color) ??
                                GanttLayout.projectColor(p.id),
                          ),
                          title: Text(p.name),
                          selected: location.startsWith('/projects/${p.id}'),
                          selectedTileColor: palette.primary.withValues(
                            alpha: 0.12,
                          ),
                          onTap: () => onNavigate('/projects/${p.id}'),
                        ),
                    ListTile(
                      key: const Key('sidebar-project-create'),
                      contentPadding: const EdgeInsets.only(left: 24, right: 8),
                      dense: true,
                      leading: const Icon(Icons.add, size: 18),
                      title: Text(l10n?.projectCreateTitle ?? 'New project'),
                      onTap: () => _createProject(context, ref),
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                key: const Key('sidebar-filters'),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.only(left: 8, right: 8),
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
                    leftPad: 16,
                    onTap: () => onNavigate('/tasks/today'),
                  ),
                  tile(
                    key: const Key('sidebar-filter-overdue'),
                    icon: Icons.warning_amber_outlined,
                    label: l10n?.filterOverdue ?? 'Overdue',
                    selected: location == '/tasks/overdue',
                    leftPad: 16,
                    onTap: () => onNavigate('/tasks/overdue'),
                  ),
                  tile(
                    key: const Key('sidebar-filter-completed'),
                    icon: Icons.check_circle_outline,
                    label: l10n?.filterCompleted ?? 'Completed',
                    selected: location == '/tasks/completed',
                    leftPad: 16,
                    onTap: () => onNavigate('/tasks/completed'),
                  ),
                ],
              ),
              tagsAsync.when(
                loading: () =>
                    tile(icon: Icons.label_outline, label: '…', onTap: () {}),
                error: (e, _) =>
                    tile(icon: Icons.error_outline, label: '$e', onTap: () {}),
                data: (tags) => ExpansionTile(
                  key: const Key('sidebar-tags'),
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.only(left: 8, right: 8),
                  childrenPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.label_outline, size: 20),
                  title: Text(l10n?.navTags ?? 'Tags'),
                  iconColor: tagsActive ? palette.primary : null,
                  children: [
                    if (tags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 8, 8),
                        child: Text(
                          l10n?.tagsEmpty ?? 'No tags yet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      for (final tag in tags)
                        ListTile(
                          key: Key('sidebar-tag-${tag.id}'),
                          contentPadding: const EdgeInsets.only(
                            left: 24,
                            right: 8,
                          ),
                          dense: true,
                          leading: const Icon(Icons.label_outline, size: 18),
                          title: Text(tag.name),
                          selected: location.startsWith('/tasks/tag/${tag.id}'),
                          selectedTileColor: palette.primary.withValues(
                            alpha: 0.12,
                          ),
                          onTap: () => onNavigate('/tasks/tag/${tag.id}'),
                        ),
                    ListTile(
                      key: const Key('sidebar-tag-create'),
                      contentPadding: const EdgeInsets.only(left: 24, right: 8),
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
    final palette = SemanticColors.paletteOf(context);

    if (taskId == null) {
      return const SizedBox(
        key: Key('detail-panel'),
        width: AppSpacing.detailPanelWidth,
      );
    }

    return Container(
      key: const Key('detail-panel'),
      width: AppSpacing.detailPanelWidth,
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(left: BorderSide(color: palette.outline)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                key: const Key('detail-panel-close'),
                icon: const Icon(Icons.close),
                color: palette.onSurfaceVariant,
                onPressed: () => clearTaskDetailSelection(ref),
              ),
            ),
            Expanded(child: TaskDetailPanel(taskId: taskId)),
          ],
        ),
      ),
    );
  }
}
