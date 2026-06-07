import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/app_settings.dart';

/// Live stream of [AppSettings] from the injected [ISettingsStore].
///
/// Enters [AsyncValue.error] when [settingsStoreProvider] is not overridden
/// (e.g. during tests that pump widgets without a real store). Consumers
/// should handle the error state gracefully.
final settingsNotifierProvider = StreamProvider<AppSettings>((ref) {
  final store = ref.watch(settingsStoreProvider);
  return store.watch();
});

/// Derived [ThemeMode] from the current [AppSettings.themeMode] string.
/// Falls back to [ThemeMode.system] on loading or error.
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsNotifierProvider).when(
    data: (s) => _parseThemeMode(s.themeMode),
    loading: () => ThemeMode.system,
    error: (_, _) => ThemeMode.system,
  );
});

/// Derived locale from the current [AppSettings.locale] string.
/// Falls back to `Locale('en')` on loading or error.
final localeProvider = Provider<Locale>((ref) {
  return ref.watch(settingsNotifierProvider).when(
    data: (s) => _parseLocale(s.locale),
    loading: () => const Locale('en'),
    error: (_, _) => const Locale('en'),
  );
});

ThemeMode _parseThemeMode(String raw) {
  switch (raw) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

Locale _parseLocale(String raw) {
  switch (raw) {
    case 'zh':
      return const Locale('zh');
    default:
      return const Locale('en');
  }
}
