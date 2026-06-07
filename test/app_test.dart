import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/app.dart';
import 'package:plan_list/main.dart' as app_main;

void main() {
  testWidgets('router starts on the tasks page', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(PlanListApp(router: router));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tasks-page')), findsOneWidget);
  });

  testWidgets('router navigates between top-level destinations',
      (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(PlanListApp(router: router));
    await tester.pumpAndSettle();

    router.go('/calendar');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);

    router.go('/search');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-page')), findsOneWidget);

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
  });

  testWidgets('task detail route passes the id path parameter',
      (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(PlanListApp(router: router));
    await tester.pumpAndSettle();

    router.go('/task/abc-123');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-detail-page')), findsOneWidget);
    expect(find.text('Task abc-123'), findsOneWidget);
  });

  testWidgets('tapping a shell destination navigates via go_router',
      (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(PlanListApp(router: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);
  });

  testWidgets('main() boots the app inside a ProviderScope', (tester) async {
    await app_main.main();
    await tester.pumpAndSettle();
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(PlanListApp), findsOneWidget);
    expect(find.byKey(const Key('tasks-page')), findsOneWidget);

    // Tear down within the test body so the real Drift data layer's
    // stream-close timer fires before the framework's pending-timer
    // invariant runs (main() now wires a concrete database). The timer is
    // zero-duration, so advance fake time past its deadline to flush it.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
