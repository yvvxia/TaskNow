import '../../../core/contracts/i_settings_store.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/setting_keys.dart';

/// Notification-related settings snapshot used by the reminder calculator
/// and scheduler. Combines [AppSettings] with extended DND keys from the store.
class NotificationSettings {
  const NotificationSettings({
    required this.notificationsEnabled,
    required this.defaultAdvanceMin,
    required this.overdueRepeatHours,
    required this.dndEnabled,
    required this.dndStartMinutes,
    required this.dndEndMinutes,
  });

  final bool notificationsEnabled;
  final int defaultAdvanceMin;
  final int overdueRepeatHours;
  final bool dndEnabled;
  final int dndStartMinutes;
  final int dndEndMinutes;

  factory NotificationSettings.fromStore(ISettingsStore store) {
    return NotificationSettings(
      notificationsEnabled: store.get(SettingKeys.notificationsEnabled),
      defaultAdvanceMin: store.get(SettingKeys.defaultReminderMinutes),
      overdueRepeatHours: store.get(SettingKeys.overdueRepeatHours),
      dndEnabled: store.get(SettingKeys.dndEnabled),
      dndStartMinutes: store.get(SettingKeys.dndStartMinutes),
      dndEndMinutes: store.get(SettingKeys.dndEndMinutes),
    );
  }

  /// Minimal [AppSettings] view for [ReminderCalculator.compute].
  AppSettings toAppSettings() => AppSettings(
    notificationsEnabled: notificationsEnabled,
    defaultReminderMinutes: defaultAdvanceMin,
  );
}
