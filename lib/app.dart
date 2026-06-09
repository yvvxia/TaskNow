import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_design_system.dart';
import 'core/theme/theme_providers.dart';
import 'core/widgets/adaptive_scaffold.dart';
import 'features/calendar/calendar_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/project/project_detail_page.dart';
import 'features/project/projects_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/settings_providers.dart';
import 'features/task/domain/task_list_scope.dart';
import 'features/task/task_detail_page.dart';
import 'features/task/task_list_page.dart';
import 'features/task/tasks_hub_page.dart';
import 'l10n/app_localizations.dart';

/// Duration of the transition played when switching between shell routes.
const Duration kRouteTransitionDuration = Duration(milliseconds: 260);

/// Wraps [child] in a [CustomTransitionPage] using a Material "fade-through":
/// the outgoing page fades fully out over the first part of the animation and
/// the incoming page fades in only afterwards, so the two pages are never
/// visible on top of each other at the same time (no overlap / ghosting).
///
/// Applying the transition at the route level (rather than animating the
/// [ShellRoute] child with an [AnimatedSwitcher]) lets the inner [Navigator]
/// own the sequencing, without duplicating the `GlobalKey`s that `go_router`
/// assigns to each page.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: kRouteTransitionDuration,
    reverseTransitionDuration: kRouteTransitionDuration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Incoming page: stay invisible for the first 40%, then fade in.
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      );
      // This page when it is being covered by a new route: fade out during
      // the first 40%, then stay gone.
      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
        ),
      );
      return FadeTransition(
        opacity: fadeIn,
        child: FadeTransition(opacity: fadeOut, child: child),
      );
    },
  );
}

/// Builds the application router. A factory (rather than a singleton) so tests
/// can construct an isolated router per test.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(
          location: state.uri.toString(),
          onDestinationSelected: (route) => context.go(route),
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                _fadePage(state, const DashboardPage()),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) =>
                _fadePage(state, const ProjectsPage()),
          ),
          GoRoute(
            path: '/projects/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              ProjectDetailPage(projectId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                _fadePage(state, const CalendarPage()),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) =>
                _fadePage(state, const TasksHubPage()),
          ),
          GoRoute(
            path: '/tasks/today',
            pageBuilder: (context, state) =>
                _fadePage(state, const TaskListPage(scope: TodayScope())),
          ),
          GoRoute(
            path: '/tasks/overdue',
            pageBuilder: (context, state) =>
                _fadePage(state, const TaskListPage(scope: OverdueScope())),
          ),
          GoRoute(
            path: '/tasks/completed',
            pageBuilder: (context, state) =>
                _fadePage(state, const TaskListPage(scope: CompletedScope())),
          ),
          GoRoute(
            path: '/tasks/tag/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              TaskListPage(scope: TagScope(state.pathParameters['id']!)),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _fadePage(state, const SettingsPage()),
          ),
          GoRoute(
            path: '/task/:id',
            pageBuilder: (context, state) => _fadePage(
              state,
              TaskDetailPage(taskId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Lazily-created application router used by [LivelineApp] in production.
final GoRouter appRouter = createAppRouter();

/// Root application widget wiring [MaterialApp.router] to `go_router` with
/// Material 3 light/dark themes and localization (en/zh).
///
/// Reactively follows the user's settings: [themeProvider] drives the
/// [ThemeMode] (light/dark/system) and [localeProvider] drives the active
/// [Locale]. Both providers fall back to system defaults when the settings
/// store is unavailable, so the only requirement to pump this widget is a
/// surrounding [ProviderScope].
class LivelineApp extends ConsumerWidget {
  const LivelineApp({super.key, this.router});

  /// Optional injected router (used by tests). Defaults to [appRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Liveline',
      theme: ref.watch(appLightThemeProvider),
      darkTheme: ref.watch(appDarkThemeProvider),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router ?? appRouter,
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;
        if (width >= kCompactBreakpoint) {
          return child ?? const SizedBox.shrink();
        }
        final brightness = Theme.of(context).brightness;
        return Theme(
          data: AppDesignSystem.buildTheme(
            brightness,
            typography: AppTypographyScale.comfortable,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
