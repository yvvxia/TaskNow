import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/contracts/i_settings_store.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/core/models/app_settings.dart';
import 'package:plan_list/core/models/setting_key.dart';
import 'package:plan_list/features/settings/settings_providers.dart';

/// A minimal in-memory [ISettingsStore] used in unit tests.
class FakeSettingsStore implements ISettingsStore {
  AppSettings _current;
  final _controller = StreamController<AppSettings>.broadcast();

  FakeSettingsStore([AppSettings initial = const AppSettings()])
      : _current = initial;

  @override
  T get<T>(SettingKey<T> key) => key.defaultValue;

  @override
  Future<void> set<T>(SettingKey<T> key, T value) async {
    // For AppSettings fields, reconstruct the model
    AppSettings next = _current;
    if (key.name == 'themeMode' && value is String) {
      next = _current.copyWith(themeMode: value);
    } else if (key.name == 'notificationsEnabled' && value is bool) {
      next = _current.copyWith(notificationsEnabled: value);
    } else if (key.name == 'locale' && value is String) {
      next = _current.copyWith(locale: value);
    } else if (key.name == 'defaultReminderMinutes' && value is int) {
      next = _current.copyWith(defaultReminderMinutes: value);
    }
    _current = next;
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

  void close() => _controller.close();
}

void main() {
  group('settingsNotifierProvider', () {
    test('emits current AppSettings from the store', () async {
      const initial = AppSettings(themeMode: 'dark', locale: 'zh');
      final fakeStore = FakeSettingsStore(initial);
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      // Keep a persistent listener so the stream is not paused.
      final sub = container.listen(settingsNotifierProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(settingsNotifierProvider);
      expect(state.value?.themeMode, 'dark');
      expect(state.value?.locale, 'zh');
    });

    test('propagates store updates', () async {
      final fakeStore = FakeSettingsStore();
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      // Collect emitted settings
      final emitted = <AppSettings>[];
      container.listen(settingsNotifierProvider, (_, next) {
        next.whenData(emitted.add);
      });

      await Future<void>.delayed(Duration.zero);
      await fakeStore.set(
        const SettingKey<String>('themeMode', 'system'),
        'dark',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitted.any((s) => s.themeMode == 'dark'), isTrue);
    });

    test('enters error state when settingsStoreProvider is not overridden',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // settingsStoreProvider throws by default; wait for evaluation
      await Future<void>.delayed(Duration.zero);
      final updated = container.read(settingsNotifierProvider);
      expect(updated.hasError || updated.isLoading, isTrue);
    });
  });

  group('themeProvider', () {
    test('returns ThemeMode.system when store emits default settings', () async {
      final fakeStore = FakeSettingsStore();
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      // Keep a persistent listener so the stream is not paused.
      final sub = container.listen(settingsNotifierProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(themeProvider), ThemeMode.system);
    });

    test('returns ThemeMode.dark when themeMode setting is "dark"', () async {
      const initial = AppSettings(themeMode: 'dark');
      final fakeStore = FakeSettingsStore(initial);
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      final sub = container.listen(settingsNotifierProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(themeProvider), ThemeMode.dark);
    });

    test('returns ThemeMode.light when themeMode setting is "light"', () async {
      const initial = AppSettings(themeMode: 'light');
      final fakeStore = FakeSettingsStore(initial);
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      final sub = container.listen(settingsNotifierProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('falls back to ThemeMode.system when store not available', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // themeProvider handles error state from settingsNotifierProvider gracefully
      await Future<void>.delayed(Duration.zero);
      final themeMode = container.read(themeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('updates ThemeMode when settings change', () async {
      final fakeStore = FakeSettingsStore();
      addTearDown(fakeStore.close);

      final container = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      // Keep a persistent listener so the stream is not paused.
      final sub = container.listen(settingsNotifierProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);

      // Verify initial theme
      expect(container.read(themeProvider), ThemeMode.system);

      await fakeStore.set(
        const SettingKey<String>('themeMode', 'system'),
        'dark',
      );
      await Future<void>.delayed(Duration.zero);

      // container.read forces a flush so themeProvider re-evaluates.
      expect(container.read(themeProvider), ThemeMode.dark);
    });
  });
}
