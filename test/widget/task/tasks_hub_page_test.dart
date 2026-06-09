import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/project.dart';
import 'package:liveline/features/task/tasks_hub_page.dart';

import '../../fakes/fake_project_repository.dart';

void main() {
  late FakeProjectRepository projects;

  setUp(() {
    projects = FakeProjectRepository()
      ..seed([
        const Project(id: 'p1', name: 'Alpha'),
        const Project(id: 'p2', name: 'Beta'),
      ]);
  });

  Widget wrap(GoRouter router) {
    return ProviderScope(
      overrides: [projectRepositoryProvider.overrideWithValue(projects)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders overview and expandable project list', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TasksHubPage()),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const Scaffold(key: Key('dashboard-page')),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (_, state) =>
              Scaffold(key: Key('project-${state.pathParameters['id']}')),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tasks-page')), findsOneWidget);
    expect(find.byKey(const Key('tasks-hub-overview')), findsOneWidget);
    expect(find.byKey(const Key('tasks-hub-projects')), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('tapping overview navigates to dashboard', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TasksHubPage()),
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const Scaffold(key: Key('dashboard-page')),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tasks-hub-overview')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-page')), findsOneWidget);
  });

  testWidgets('tapping a project navigates to its detail route', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const TasksHubPage()),
        GoRoute(
          path: '/projects/:id',
          builder: (_, state) =>
              Scaffold(key: Key('project-${state.pathParameters['id']}')),
        ),
      ],
    );

    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tasks-hub-project-p1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('project-p1')), findsOneWidget);
  });
}
