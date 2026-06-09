import 'setting_key.dart';

/// All [SettingKey] constants used by [SharedPrefsSettingsStore].
/// These are the stable storage keys for every user-configurable setting.
abstract final class SettingKeys {
  // ── Core AppSettings fields ──────────────────────────────────────────────

  static const notificationsEnabled = SettingKey<bool>(
    'notificationsEnabled',
    true,
  );

  static const defaultReminderMinutes = SettingKey<int>(
    'defaultReminderMinutes',
    15,
  );

  /// 'system' | 'light' | 'dark'
  static const themeMode = SettingKey<String>('themeMode', 'system');

  /// BCP-47 language tag: 'en' | 'zh'
  static const locale = SettingKey<String>('locale', 'en');

  // ── Extended notification / DND settings ─────────────────────────────────

  /// Hours between overdue notifications. 0 = off.
  static const overdueRepeatHours = SettingKey<int>('overdueRepeatHours', 24);

  /// Whether Do Not Disturb is active.
  static const dndEnabled = SettingKey<bool>('dndEnabled', false);

  /// DND window start as minutes-since-midnight (default 22:00 = 1320).
  static const dndStartMinutes = SettingKey<int>('dndStartMinutes', 22 * 60);

  /// DND window end as minutes-since-midnight (default 08:00 = 480).
  static const dndEndMinutes = SettingKey<int>('dndEndMinutes', 8 * 60);

  // ── Dashboard ────────────────────────────────────────────────────────────

  /// Number of days ahead counted as "upcoming" on the dashboard (default 7).
  static const dashboardUpcomingDays = SettingKey<int>(
    'dashboardUpcomingDays',
    7,
  );
}
