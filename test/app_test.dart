import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liveline/app.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/main.dart' as app_main;

import 'helpers/fake_settings_store.dart';
import 'helpers/fakes.dart';

void main() {
  // LivelineApp is a ConsumerWidget (reads theme/locale providers) and the
  // routed pages read the data/settings providers, so it must be pumped inside
  // a ProviderScope wired with the standard fakes. This lets the real page
  // bodies render their (empty) data states rather than error fallbacks.
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late FakeProjectRepository projects;

  final frozen = DateTime.utc(2026, 6, 7);

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    projects = FakeProjectRepository();
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  List<Override> baseOverrides() => [
    taskRepositoryProvider.overrideWithValue(repo),
    reminderRepositoryProvider.overrideWithValue(reminders),
    notificationServiceProvider.overrideWithValue(notif),
    settingsStoreProvider.overrideWithValue(settings),
    projectRepositoryProvider.overrideWithValue(projects),
    clockProvider.overrideWith(
      (ref) =>
          () => frozen,
    ),
  ];

  Widget wrap(GoRouter router) => ProviderScope(
    overrides: baseOverrides(),
    child: LivelineApp(router: router),
  );

  testWidgets('router starts on the dashboard page', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-page')), findsOneWidget);
  });

  testWidgets('router navigates between top-level destinations', (
    tester,
  ) async {
    final router = createAppRouter();
    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    router.go('/calendar');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);

    router.go('/tasks');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tasks-page')), findsOneWidget);

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
  });

  testWidgets('task detail route passes the id path parameter', (tester) async {
    repo.seed([const Task(id: 'abc-123', title: 'Task abc-123')]);

    final router = createAppRouter();
    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    router.go('/task/abc-123');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-detail-page')), findsOneWidget);
    expect(find.text('Task abc-123'), findsOneWidget);
  });

  testWidgets('tapping a shell destination navigates via go_router', (
    tester,
  ) async {
    final router = createAppRouter();
    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);
  });

  testWidgets('tapping Search opens overlay instead of a page', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(wrap(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-overlay')), findsOneWidget);
    expect(find.byKey(const Key('search-page')), findsNothing);
  });

  testWidgets('main() boots the app inside a ProviderScope', (tester) async {
    await app_main.main();
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(LivelineApp), findsOneWidget);
    expect(find.byKey(const Key('dashboard-page')), findsOneWidget);

    // Tear down within the test body so the real Drift data layer's
    // stream-close timer fires before the framework's pending-timer
    // invariant runs (main() now wires a concrete database). The timer is
    // zero-duration, so advance fake time past its deadline to flush it.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
