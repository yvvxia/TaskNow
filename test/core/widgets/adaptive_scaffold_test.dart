import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/widgets/adaptive_scaffold.dart';

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
    MaterialApp(
      home: AdaptiveScaffold(
        location: location,
        onDestinationSelected: onSelect ?? (_) {},
        child: const Text('content', key: Key('content')),
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
  });

  testWidgets('medium (600-1024) renders a NavigationRail', (tester) async {
    await _pumpAt(tester, const Size(800, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('desktop-sidebar')), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
  });

  testWidgets('expanded (>1024) renders sidebar + detail panel',
      (tester) async {
    await _pumpAt(tester, const Size(1400, 900));
    expect(find.byKey(const Key('desktop-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('detail-panel')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('content')), findsOneWidget);
  });

  testWidgets('selecting a destination in compact invokes the callback',
      (tester) async {
    String? selected;
    await _pumpAt(tester, const Size(400, 800), onSelect: (r) => selected = r);
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(selected, '/calendar');
  });

  testWidgets('selected index follows the current location', (tester) async {
    await _pumpAt(tester, const Size(800, 800), location: '/settings');
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 3);
  });

  testWidgets('unknown location falls back to the first destination',
      (tester) async {
    await _pumpAt(tester, const Size(800, 800), location: '/unknown');
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 0);
  });

  testWidgets('tapping a sidebar item in expanded invokes the callback',
      (tester) async {
    String? selected;
    await _pumpAt(tester, const Size(1400, 900), onSelect: (r) => selected = r);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(selected, '/search');
  });
}
