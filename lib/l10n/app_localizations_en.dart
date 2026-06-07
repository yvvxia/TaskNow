// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navTasks => 'Tasks';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSection => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsGlobal => 'Enable Notifications';

  @override
  String get notificationsDefaultReminder => 'Default Reminder';

  @override
  String notificationsDefaultReminderValue(int minutes) {
    return '$minutes min before';
  }

  @override
  String get notificationsOverdueRepeat => 'Overdue Repeat Interval';

  @override
  String notificationsOverdueRepeatValue(int hours) {
    return 'Every $hours h';
  }

  @override
  String get dndSection => 'Do Not Disturb';

  @override
  String get dndEnabled => 'Enable Do Not Disturb';

  @override
  String get dndStart => 'DND Start';

  @override
  String get dndEnd => 'DND End';

  @override
  String get syncSection => 'Cloud Sync';

  @override
  String get syncComingSoon => 'Cloud sync — coming in Phase 2';

  @override
  String get aboutSection => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get aboutOpenSource => 'Open Source Licenses';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionComplete => 'Complete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get errorEmptyTitle => 'Title cannot be empty';

  @override
  String get errorDueBeforeStart => 'Due date must be after start date';

  @override
  String get errorInvalidReminder => 'Invalid reminder time';

  @override
  String get errorNotFound => 'Item not found';

  @override
  String get errorPersistence => 'Failed to save data';

  @override
  String get errorPermission => 'Permission denied';

  @override
  String get minutesDialog => 'Set reminder advance (minutes)';

  @override
  String get hoursDialog => 'Set overdue repeat interval (hours)';
}
