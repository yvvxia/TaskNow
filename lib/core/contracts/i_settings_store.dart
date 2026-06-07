import '../models/app_settings.dart';
import '../models/setting_key.dart';

/// Settings store contract (module 06), implemented by the platform layer.
abstract interface class ISettingsStore {
  T get<T>(SettingKey<T> key);

  Future<void> set<T>(SettingKey<T> key, T value);

  Stream<AppSettings> watch();
}
