import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/domain/gantt_layout.dart';
import '../../features/project/project_providers.dart';
import '../../features/search/presentation/search_overlay.dart' as search_ui;
import '../../l10n/app_localizations.dart';

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

/// Top-level navigation destinations, shared across all layout sizes.
const List<AdaptiveDestination> kAdaptiveDestinations = <AdaptiveDestination>[
  AdaptiveDestination('/tasks', Icons.task_alt_outlined, 'Tasks'),
  AdaptiveDestination('/calendar', Icons.calendar_month, 'Calendar'),
  AdaptiveDestination(search_ui.kSearchOverlayRoute, Icons.search, 'Search'),
  AdaptiveDestination('/settings', Icons.settings, 'Settings'),
];

/// Width below which the compact (mobile) layout is used.
const double kCompactBreakpoint = 600;

/// Width above which the expanded (desktop) layout is used.
const double kExpandedBreakpoint = 1024;

/// Whether [location] belongs to the Tasks group (overview, hub, projects).
bool isTasksGroupLocation(String location) {
  return location.startsWith('/dashboard') ||
      location.startsWith('/projects') ||
      location.startsWith('/tasks') ||
      location.startsWith('/task/');
}

/// Responsive application shell.
///
/// * `< 600dp`  → compact: bottom [NavigationBar].
/// * `600–1024dp` → medium: [NavigationRail] + content.
/// * `> 1024dp` → expanded: sidebar tree + content + right detail panel.
///
/// Search is an overlay (not a route). The Tasks group nests Overview and
/// Projects on desktop (sidebar tree) and on mobile/tablet ([/tasks] hub).
class AdaptiveScaffold extends ConsumerStatefulWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.onDestinationSelected,
  });

  /// The routed content for the active destination.
  final Widget child;

  /// The current router location, used to highlight the active destination.
  final String location;

  /// Invoked with the target route when a routable destination is selected.
  final ValueChanged<String> onDestinationSelected;

  @override
  ConsumerState<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends ConsumerState<AdaptiveScaffold> {
  final SearchController _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    if (widget.location.startsWith('/calendar')) return 1;
    if (widget.location.startsWith('/settings')) return 3;
    if (isTasksGroupLocation(widget.location)) return 0;
    final index = kAdaptiveDestinations.indexWhere(
      (d) => widget.location.startsWith(d.route),
    );
    return index < 0 ? 0 : index;
  }

  void _selectIndex(int index) {
    final dest = kAdaptiveDestinations[index];
    if (dest.route == search_ui.kSearchOverlayRoute) {
      search_ui.openSearchOverlay(_searchController);
      return;
    }
    widget.onDestinationSelected(dest.route);
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

  Widget _buildCompact(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectIndex,
        destinations: <Widget>[
          for (final d in kAdaptiveDestinations)
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
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectIndex,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              for (final d in kAdaptiveDestinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.localizedLabel(context)),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          _DesktopSidebar(
            location: widget.location,
            onNavigate: widget.onDestinationSelected,
            onOpenSearch: () => search_ui.openSearchOverlay(_searchController),
          ),
          const VerticalDivider(width: 1),
          Expanded(flex: 2, child: widget.child),
          const VerticalDivider(width: 1),
          const _DetailPanel(),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
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
    final projectsAsync = ref.watch(projectListProvider);
    final tasksActive = isTasksGroupLocation(location);
    final calendarActive = location.startsWith('/calendar');
    final settingsActive = location.startsWith('/settings');
    final overviewActive = location.startsWith('/dashboard');
    final projectsActive = location.startsWith('/projects');

    return SizedBox(
      key: const Key('desktop-sidebar'),
      width: 260,
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('PlanList'),
            ),
          ),
          ExpansionTile(
            key: const Key('sidebar-tasks'),
            initiallyExpanded: true,
            leading: const Icon(Icons.task_alt_outlined),
            title: Text(l10n?.navTasks ?? 'Tasks'),
            iconColor: tasksActive
                ? Theme.of(context).colorScheme.primary
                : null,
            children: [
              ListTile(
                key: const Key('sidebar-overview'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                leading: const Icon(Icons.dashboard_outlined, size: 20),
                title: Text(l10n?.navDashboard ?? 'Dashboard'),
                selected: overviewActive,
                onTap: () => onNavigate('/dashboard'),
              ),
              projectsAsync.when(
                loading: () => const ListTile(
                  contentPadding: EdgeInsets.only(left: 32),
                  title: Text('…'),
                ),
                error: (e, _) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 32),
                  title: Text('$e'),
                ),
                data: (projects) => ExpansionTile(
                  key: const Key('sidebar-projects'),
                  initiallyExpanded: true,
                  // Same left indent as the Overview tile so Projects and
                  // Overview read as siblings (both second-level under Tasks).
                  tilePadding: const EdgeInsets.only(left: 32, right: 16),
                  childrenPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined, size: 20),
                  title: Text(l10n?.navProjects ?? 'Projects'),
                  iconColor: projectsActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  children: [
                    if (projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 0, 16, 8),
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
                          selected: location.startsWith('/projects/${p.id}'),
                          onTap: () => onNavigate('/projects/${p.id}'),
                        ),
                  ],
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n?.navCalendar ?? 'Calendar'),
            selected: calendarActive,
            onTap: () => onNavigate('/calendar'),
          ),
          ListTile(
            key: const Key('sidebar-search'),
            leading: const Icon(Icons.search),
            title: Text(l10n?.navSearch ?? 'Search'),
            onTap: onOpenSearch,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n?.navSettings ?? 'Settings'),
            selected: settingsActive,
            onTap: () => onNavigate('/settings'),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: Key('detail-panel'),
      width: 320,
      child: Center(child: Text('Select a task')),
    );
  }
}
