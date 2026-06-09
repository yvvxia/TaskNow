import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/features/search/presentation/filter_chips_row.dart';
import 'package:liveline/features/search/search_controller.dart';
import '../../helpers/fakes.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
      ],
    );
  });

  tearDown(() => container.dispose());

  Widget wrap(Widget child) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('priority menu toggles selected state in query', (tester) async {
    await tester.pumpWidget(wrap(const FilterChipsRow()));

    await tester.tap(find.byKey(const Key('priority-filter-chip')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('priority-menu-high')));
    await tester.pumpAndSettle();

    final query = container.read(searchControllerProvider);
    expect(query.effectivePriorities, {Priority.high});
  });

  testWidgets('clear chip resets filters', (tester) async {
    container
        .read(searchControllerProvider.notifier)
        .togglePriority(Priority.high);
    container.read(searchControllerProvider.notifier).toggleTag('t1');

    await tester.pumpWidget(wrap(const FilterChipsRow()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('clear-filters-chip')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('clear-filters-chip')));
    await tester.pumpAndSettle();

    final query = container.read(searchControllerProvider);
    expect(query.effectivePriorities, isNull);
    expect(query.tagIds, isEmpty);
  });
}
