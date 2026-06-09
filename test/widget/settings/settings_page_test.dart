import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/contracts/i_settings_store.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/app_settings.dart';
import 'package:liveline/core/models/setting_key.dart';
import 'package:liveline/features/settings/settings_page.dart';

/// Minimal in-memory settings store for widget tests.
class _FakeStore implements ISettingsStore {
  AppSettings _current;
  final _controller = StreamController<AppSettings>.broadcast();

  _FakeStore([AppSettings initial = const AppSettings()]) : _current = initial;

  @override
  T get<T>(SettingKey<T> key) => key.defaultValue;

  @override
  Future<void> set<T>(SettingKey<T> key, T value) async {
    if (key.name == 'themeMode' && value is String) {
      _current = _current.copyWith(themeMode: value);
    } else if (key.name == 'notificationsEnabled' && value is bool) {
      _current = _current.copyWith(notificationsEnabled: value);
    }
    _controller.add(_current);
  }

  @override
  Stream<AppSettings> watch() {
    return Stream.multi((controller) {
      controller.add(_current);
      final sub = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = () => sub.cancel();
    });
  }
}

Widget _buildTestApp({required Widget child, ISettingsStore? store}) {
  return ProviderScope(
    overrides: [
      if (store != null) settingsStoreProvider.overrideWithValue(store),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  group('SettingsPage widget tests', () {
    testWidgets('renders settings-page key', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings-page')), findsOneWidget);
    });

    testWidgets('shows theme segmented button', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('theme-segmented-button')), findsOneWidget);
    });

    testWidgets('shows gantt bar color segmented button', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('bar-color-segmented-button')),
        findsOneWidget,
      );
    });

    testWidgets('shows notifications global switch', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('notifications-global-switch')),
        findsOneWidget,
      );
    });

    testWidgets('shows sync coming-soon text after scrolling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Scroll down until the sync section is visible.
      await tester.scrollUntilVisible(
        find.textContaining('Phase 2'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Phase 2'), findsOneWidget);
    });

    testWidgets('shows about section with Liveline app name after scrolling', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(store: _FakeStore(), child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Scroll down until the about section is visible.
      // Use textContaining to avoid .last on a potentially empty Finder when
      // the About section is initially off-screen in the culled ListView.
      await tester.scrollUntilVisible(
        find.textContaining('Liveline'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Liveline'), findsWidgets);
    });

    testWidgets('renders with no store (error fallback)', (tester) async {
      // SettingsPage must not crash when no real store is available.
      await tester.pumpWidget(_buildTestApp(child: const SettingsPage()));
      // Allow the async provider to settle
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // The Scaffold key should still be present even in the error fallback.
      expect(find.byKey(const Key('settings-page')), findsOneWidget);
    });

    testWidgets('notifications switch reflects settings', (tester) async {
      final store = _FakeStore(const AppSettings(notificationsEnabled: false));
      await tester.pumpWidget(
        _buildTestApp(store: store, child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(
        find.descendant(
          of: find.byKey(const Key('notifications-global-switch')),
          matching: find.byType(Switch),
        ),
      );
      expect(switchWidget.value, false);
    });
  });
}
