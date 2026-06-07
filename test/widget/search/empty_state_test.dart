import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/features/search/presentation/empty_state.dart';

void main() {
  testWidgets('shows default no-results message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyState())),
    );

    expect(find.byKey(const Key('search-empty-state')), findsOneWidget);
    expect(find.text('No tasks match your search'), findsOneWidget);
    expect(find.text('Try different keywords or filters'), findsOneWidget);
  });

  testWidgets('shows custom message when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EmptyState(message: 'Nothing here')),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
  });
}
