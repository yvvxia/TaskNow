import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/core/widgets/adaptive_scaffold.dart';
import 'package:liveline/core/widgets/shell_providers.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {
  String location = '/tasks',
  ValueChanged<String>? onSelect,
  List<Override> overrides = const [],
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
        tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
        settingsStoreProvider.overrideWithValue(FakeSettingsStore()),
        ...overrides,
      ],
      child: MaterialApp(
        home: AdaptiveScaffold(
          location: location,
          onDestinationSelected: onSelect ?? (_) {},
          child: const Text('content', key: Key('content')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('compact (<600) renders a bottom NavigationBar', (tester) async {
    await _pumpAt(tester, const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('desktop-sidebar')), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
    expect(find.byKey(const Key('shell-fab')), findsOneWidget);
    // Settings is now a bottom navigation destination on phones.
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('medium (600-1024) renders a NavigationRail', (tester) async {
    await _pumpAt(tester, const Size(800, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('desktop-sidebar')), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
  });

  testWidgets('expanded (>1024) renders rail + sidebar + detail panel', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    expect(find.byKey(const Key('desktop-rail')), findsOneWidget);
    expect(find.byKey(const Key('desktop-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('detail-panel')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
  });

  testWidgets('expanded rail lists the top-level destinations', (tester) async {
    await _pumpAt(tester, const Size(1400, 900));
    expect(find.byKey(const Key('rail-tasks')), findsOneWidget);
    expect(find.byKey(const Key('rail-calendar')), findsOneWidget);
    expect(find.byKey(const Key('rail-search')), findsOneWidget);
    expect(find.byKey(const Key('rail-settings')), findsOneWidget);
  });

  testWidgets('expanded rail buttons use a wide rounded highlight', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    final sizedBox = tester
        .widgetList<SizedBox>(
          find.descendant(
            of: find.byKey(const Key('rail-tasks')),
            matching: find.byType(SizedBox),
          ),
        )
        .firstWhere((box) => box.width == 40 && box.height == 36);
    expect(sizedBox.width, greaterThan(sizedBox.height!));
  });

  testWidgets('expanded rail navigates to calendar', (tester) async {
    String? selected;
    await _pumpAt(tester, const Size(1400, 900), onSelect: (r) => selected = r);
    await tester.tap(find.byKey(const Key('rail-calendar')));
    await tester.pumpAndSettle();
    expect(selected, '/calendar');
  });

  testWidgets('expanded secondary nav collapses on non-tasks sections', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900), location: '/calendar');
    await tester.pumpAndSettle();
    final secondaryAlign = tester.widget<AnimatedAlign>(
      find.ancestor(
        of: find.byKey(const Key('desktop-sidebar')),
        matching: find.byType(AnimatedAlign),
      ),
    );
    expect(secondaryAlign.widthFactor, 0.0);
  });

  testWidgets('selecting a destination in compact invokes the callback', (
    tester,
  ) async {
    String? selected;
    await _pumpAt(tester, const Size(400, 800), onSelect: (r) => selected = r);
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(selected, '/calendar');
  });

  testWidgets('settings route does not change rail selection index', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(800, 800), location: '/settings');
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets('dashboard location highlights the Tasks destination', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(800, 800), location: '/dashboard');
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets('unknown location falls back to the first destination', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(800, 800), location: '/unknown');
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets('tapping Search opens overlay instead of navigating', (
    tester,
  ) async {
    String? selected;
    await _pumpAt(tester, const Size(400, 800), onSelect: (r) => selected = r);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.byKey(const Key('search-overlay')), findsOneWidget);
  });

  testWidgets('expanded sidebar shows tasks tree with overview and projects', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sidebar-tasks')), findsOneWidget);
    expect(find.byKey(const Key('sidebar-overview')), findsOneWidget);
    expect(find.byKey(const Key('sidebar-projects')), findsOneWidget);
  });

  testWidgets('expanded layout hides shell search and settings actions', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    expect(find.byKey(const Key('shell-search')), findsNothing);
    expect(find.byKey(const Key('shell-settings')), findsNothing);
  });

  testWidgets('compact layout hides top search and settings actions', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(400, 800));
    expect(find.byKey(const Key('shell-search')), findsNothing);
    expect(find.byKey(const Key('shell-settings')), findsNothing);
  });

  testWidgets('compact bottom bar includes a Settings destination', (
    tester,
  ) async {
    String? selected;
    await _pumpAt(tester, const Size(400, 800), onSelect: (r) => selected = r);
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(selected, '/settings');
  });

  testWidgets('expanded detail drawer collapses when no task selected', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    final align = tester.widget<AnimatedAlign>(
      find.ancestor(
        of: find.byKey(const Key('detail-panel')),
        matching: find.byType(AnimatedAlign),
      ),
    );
    expect(align.widthFactor, 0.0);
    expect(find.byKey(const Key('detail-panel-close')), findsNothing);
  });

  testWidgets('expanded detail drawer opens when task selected', (
    tester,
  ) async {
    final repo = FakeTaskRepository()
      ..seed([const Task(id: 't1', title: 'Drawer task')]);
    final notif = SpyNotificationService();
    addTearDown(repo.dispose);
    addTearDown(notif.dispose);

    await _pumpAt(
      tester,
      const Size(1400, 900),
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        reminderRepositoryProvider.overrideWithValue(FakeReminderRepository()),
        notificationServiceProvider.overrideWithValue(notif),
        selectedTaskIdProvider.overrideWith((ref) => 't1'),
      ],
    );
    await tester.pumpAndSettle();

    final align = tester.widget<AnimatedAlign>(
      find.ancestor(
        of: find.byKey(const Key('detail-panel')),
        matching: find.byType(AnimatedAlign),
      ),
    );
    expect(align.widthFactor, 1.0);
    expect(find.byKey(const Key('detail-panel-close')), findsOneWidget);
    expect(find.text('Drawer task'), findsOneWidget);
  });
}
