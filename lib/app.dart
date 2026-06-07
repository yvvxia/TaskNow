import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/adaptive_scaffold.dart';
import 'features/calendar/calendar_page.dart';
import 'features/search/search_page.dart';
import 'features/settings/settings_page.dart';
import 'features/task/task_detail_page.dart';
import 'features/task/task_list_page.dart';
import 'l10n/app_localizations.dart';

/// Brand seed color (proposal §5.5 primary `#1976D2`).
const Color kSeedColor = Color(0xFF1976D2);

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
/// `themeMode` follows the system setting and the locale follows the device
/// locale via [AppLocalizations.supportedLocales]; both stay free of Riverpod
/// reads so the widget can be pumped in isolation by router tests.
class PlanListApp extends StatelessWidget {
  const PlanListApp({super.key, this.router});

  /// Optional injected router (used by tests). Defaults to [appRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlanList',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kSeedColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router ?? appRouter,
    );
  }
}
