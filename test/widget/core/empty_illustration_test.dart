import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/widgets/empty_illustration.dart';

void main() {
  testWidgets('renders illustration, title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyIllustration(
            key: Key('empty-state'),
            asset: 'assets/illustrations/empty_tasks.png',
            title: 'No tasks yet',
            subtitle: 'Tap + to add your first task',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('empty-state')), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Tap + to add your first task'), findsOneWidget);

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as AssetImage;
    expect(provider.assetName, 'assets/illustrations/empty_tasks.png');
  });

  testWidgets('omits subtitle when not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyIllustration(
            asset: 'assets/illustrations/empty_today.png',
            title: 'No tasks today',
          ),
        ),
      ),
    );

    expect(find.text('No tasks today'), findsOneWidget);
    // Only the title text should be present (no subtitle Text alongside it).
    expect(find.byType(Text), findsOneWidget);
  });
}
