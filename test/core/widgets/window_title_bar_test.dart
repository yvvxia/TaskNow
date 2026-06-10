import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/widgets/window_title_bar.dart';
import 'package:liveline/l10n/app_localizations.dart';

void main() {
  testWidgets('caption buttons render minimize maximize and close', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WindowCaptionButtons(forceVisible: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('window-minimize')), findsOneWidget);
    expect(find.byKey(const Key('window-maximize')), findsOneWidget);
    expect(find.byKey(const Key('window-close')), findsOneWidget);
  });
}
