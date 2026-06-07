import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Aggregate of user-configurable settings. Module 06 (settings) fleshes this
/// out; kept minimal here.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(true) bool notificationsEnabled,
    @Default(15) int defaultReminderMinutes,
    @Default('system') String themeMode,
    @Default('en') String locale,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
