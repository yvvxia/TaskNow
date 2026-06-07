import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/adaptive_scaffold.dart';
import 'features/calendar/calendar_page.dart';
import 'features/search/search_page.dart';
import 'features/settings/settings_page.dart';
import 'features/settings/settings_providers.dart';
import 'features/task/task_detail_page.dart';
import 'features/task/task_list_page.dart';
import 'l10n/app_localizations.dart';

/// Brand seed color (proposal §5.5 primary `#1976D2`).
const Color kSeedColor = Color(0xFF1976D2);

/// Pre-built light theme. Computed once (rather than on every `build`) because
/// [ColorScheme.fromSeed] is comparatively expensive and re-running it on each
/// rebuild contributes to navigation jank.
final ThemeData kLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kSeedColor),
);

/// Pre-built dark theme. See [kLightTheme].
final ThemeData kDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: Brightness.dark,
  ),
);

/// Builds the application router. A factory (rather than a singleton) so tests
/// can construct an isolated router per test.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/tasks',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(
          location: state.uri.toString(),
          onDestinationSelected: (route) => context.go(route),
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TaskListPage(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/task/:id',
            builder: (context, state) =>
                TaskDetailPage(taskId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}

/// Lazily-created application router used by [PlanListApp] in production.
final GoRouter appRouter = createAppRouter();

/// Root application widget wiring [MaterialApp.router] to `go_router` with
/// Material 3 light/dark themes and localization (en/zh).
///
/// Reactively follows the user's settings: [themeProvider] drives the
/// [ThemeMode] (light/dark/system) and [localeProvider] drives the active
/// [Locale]. Both providers fall back to system defaults when the settings
/// store is unavailable, so the only requirement to pump this widget is a
/// surrounding [ProviderScope].
class PlanListApp extends ConsumerWidget {
  const PlanListApp({super.key, this.router});

  /// Optional injected router (used by tests). Defaults to [appRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'PlanList',
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router ?? appRouter,
    );
  }
}
