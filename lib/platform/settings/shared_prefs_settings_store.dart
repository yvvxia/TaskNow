import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/contracts/i_settings_store.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/setting_key.dart';
import '../../core/models/setting_keys.dart';

/// [ISettingsStore] backed by [SharedPreferences].
///
/// Call [init] once before first use (typically in `main()`). Reads are always
/// synchronous after init; writes persist immediately and broadcast on [watch].
class SharedPrefsSettingsStore implements ISettingsStore {
  SharedPreferences? _prefs;
  AppSettings _current = const AppSettings();
  final _controller = StreamController<AppSettings>.broadcast(sync: true);

  /// Load persisted values. Safe to call even if SharedPreferences is
  /// unavailable (e.g. in widget tests) — falls back to defaults silently.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _current = _buildSettings();
    } catch (_) {
      _current = const AppSettings();
    }
    _controller.add(_current);
  }

  AppSettings _buildSettings() {
    return AppSettings(
      notificationsEnabled: get(SettingKeys.notificationsEnabled),
      defaultReminderMinutes: get(SettingKeys.defaultReminderMinutes),
      themeMode: get(SettingKeys.themeMode),
      locale: get(SettingKeys.locale),
      dashboardUpcomingDays: get(SettingKeys.dashboardUpcomingDays),
    );
  }

  @override
  T get<T>(SettingKey<T> key) {
    if (_prefs == null) return key.defaultValue;
    final raw = _prefs!.get(key.name);
    if (raw == null) return key.defaultValue;
    // SharedPreferences already returns the correct Dart type for bool/int/String/double.
    return raw as T;
  }

  @override
  Future<void> set<T>(SettingKey<T> key, T value) async {
    if (_prefs == null) return;
    final name = key.name;
    if (value is bool) {
      await _prefs!.setBool(name, value);
    } else if (value is int) {
      await _prefs!.setInt(name, value);
    } else if (value is String) {
      await _prefs!.setString(name, value);
    } else if (value is double) {
      await _prefs!.setDouble(name, value);
    }
    _current = _buildSettings();
    _controller.add(_current);
  }

  @override
  Stream<AppSettings> watch() {
    late StreamSubscription<AppSettings> innerSub;
    late StreamController<AppSettings> outer;
    outer = StreamController<AppSettings>(
      sync: true,
      onListen: () {
        outer.add(_current);
        innerSub = _controller.stream.listen(
          outer.add,
          onError: outer.addError,
          onDone: outer.close,
        );
      },
      onCancel: () => innerSub.cancel(),
    );
    return outer.stream;
  }

  /// Release resources.
  Future<void> dispose() => _controller.close();
}
