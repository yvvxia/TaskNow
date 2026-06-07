import 'package:flutter/material.dart';

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
      case '/search':
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
  AdaptiveDestination('/tasks', Icons.checklist, 'Tasks'),
  AdaptiveDestination('/calendar', Icons.calendar_month, 'Calendar'),
  AdaptiveDestination('/search', Icons.search, 'Search'),
  AdaptiveDestination('/settings', Icons.settings, 'Settings'),
];

/// Width below which the compact (mobile) layout is used.
const double kCompactBreakpoint = 600;

/// Width above which the expanded (desktop) layout is used.
const double kExpandedBreakpoint = 1024;

/// Responsive application shell.
///
/// * `< 600dp`  → compact: bottom [NavigationBar].
/// * `600–1024dp` → medium: [NavigationRail] + content.
/// * `> 1024dp` → expanded: sidebar + content + right detail panel.
///
/// This widget is intentionally router-agnostic: the current [location] and the
/// [onDestinationSelected] callback are injected by the caller (the
/// `go_router` `ShellRoute`), which keeps it trivially testable in isolation.
class AdaptiveScaffold extends StatelessWidget {
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

  /// Invoked with the target route when a destination is selected.
  final ValueChanged<String> onDestinationSelected;

  int get _selectedIndex {
    final index = kAdaptiveDestinations
        .indexWhere((d) => location.startsWith(d.route));
    return index < 0 ? 0 : index;
  }

  void _selectIndex(int index) =>
      onDestinationSelected(kAdaptiveDestinations[index].route);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
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
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          _DesktopSidebar(
            selectedIndex: _selectedIndex,
            onSelect: _selectIndex,
          ),
          const VerticalDivider(width: 1),
          Expanded(flex: 2, child: child),
          const VerticalDivider(width: 1),
          const _DetailPanel(),
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('desktop-sidebar'),
      width: 240,
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('PlanList'),
            ),
          ),
          for (var i = 0; i < kAdaptiveDestinations.length; i++)
            ListTile(
              leading: Icon(kAdaptiveDestinations[i].icon),
              title: Text(kAdaptiveDestinations[i].localizedLabel(context)),
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
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
