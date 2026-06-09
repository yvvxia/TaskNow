// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  defaultReminderMinutes:
      (json['defaultReminderMinutes'] as num?)?.toInt() ?? 15,
  themeMode: json['themeMode'] as String? ?? 'system',
  locale: json['locale'] as String? ?? 'en',
  dashboardUpcomingDays: (json['dashboardUpcomingDays'] as num?)?.toInt() ?? 7,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'defaultReminderMinutes': instance.defaultReminderMinutes,
      'themeMode': instance.themeMode,
      'locale': instance.locale,
      'dashboardUpcomingDays': instance.dashboardUpcomingDays,
    };
