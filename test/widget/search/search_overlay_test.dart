import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/data/data_providers.dart';
import 'package:plan_list/data/db/app_database.dart';
import 'package:plan_list/features/search/presentation/filter_chips_row.dart';
import 'package:plan_list/features/search/presentation/search_overlay.dart';

import '../../helpers/fakes.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    db = newTestDb();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  testWidgets('openSearchOverlay shows filter chips in the view', (
    tester,
  ) async {
    final searchController = SearchController();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: AppSearchOverlay(
            searchController: searchController,
            child: const Scaffold(body: Text('body')),
          ),
        ),
      ),
    );

    openSearchOverlay(searchController);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-overlay')), findsOneWidget);
    expect(find.byType(FilterChipsRow), findsOneWidget);

    searchController.dispose();
  });
}
