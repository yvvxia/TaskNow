/// Typed key used by [ISettingsStore] to read/write individual settings in a
/// type-safe way. Generic over the value type [T].
class SettingKey<T> {
  const SettingKey(this.name, this.defaultValue);

  /// Stable storage key.
  final String name;

  /// Value returned when nothing has been persisted yet.
  final T defaultValue;

  @override
  bool operator ==(Object other) =>
      other is SettingKey<T> &&
      other.name == name &&
      other.defaultValue == defaultValue;

  @override
  int get hashCode => Object.hash(T, name, defaultValue);

  @override
  String toString() => 'SettingKey<$T>($name, default: $defaultValue)';
}
