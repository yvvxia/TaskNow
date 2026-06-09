import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/widgets/adaptive_scaffold.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

Future<void> _pumpAt(
  WidgetTester tester,
  Size size, {
  String location = '/tasks',
  ValueChanged<String>? onSelect,
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
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('medium (600-1024) renders a NavigationRail', (tester) async {
    await _pumpAt(tester, const Size(800, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('desktop-sidebar')), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
  });

  testWidgets('expanded (>1024) renders sidebar + detail panel', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(1400, 900));
    expect(find.byKey(const Key('desktop-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('detail-panel')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
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
}
