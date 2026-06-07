import 'dart:async';

import 'package:plan_list/core/contracts/i_settings_store.dart';
import 'package:plan_list/core/models/app_settings.dart';
import 'package:plan_list/core/models/setting_key.dart';
import 'package:plan_list/platform/settings/setting_keys.dart';

/// In-memory [ISettingsStore]. Seed initial values via [values] and observe
/// changes through [watch].
class FakeSettingsStore implements ISettingsStore {
  FakeSettingsStore({Map<String, Object>? values})
    : _values = Map<String, Object>.from(values ?? {});

  final Map<String, Object> _values;
  final _controller = StreamController<AppSettings>.broadcast(sync: true);

  AppSettings _snapshot() => AppSettings(
    notificationsEnabled: get(SettingKeys.notificationsEnabled),
    defaultReminderMinutes: get(SettingKeys.defaultReminderMinutes),
    themeMode: get(SettingKeys.themeMode),
    locale: get(SettingKeys.locale),
  );

  @override
  T get<T>(SettingKey<T> key) {
    final raw = _values[key.name];
    if (raw == null) return key.defaultValue;
    return raw as T;
  }

  @override
  Future<void> set<T>(SettingKey<T> key, T value) async {
    _values[key.name] = value as Object;
    _controller.add(_snapshot());
  }

  @override
  Stream<AppSettings> watch() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

  void dispose() => _controller.close();
}
