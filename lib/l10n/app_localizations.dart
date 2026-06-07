import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Navigation label for Tasks tab
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// Navigation label for Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Navigation label for Search tab
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Navigation label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title of the task list page
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// Hint for the desktop quick-add bar
  ///
  /// In en, this message translates to:
  /// **'Add a task… (press Enter)'**
  String get addTaskHint;

  /// Hint for the new task title field
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get newTaskTitle;

  /// Label for a task start date
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get taskStartDate;

  /// Label for a task due date
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDate;

  /// Shown when a date has not been chosen
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get dateNotSet;

  /// Button to clear a chosen date
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get dateClear;

  /// Empty state for the task list
  ///
  /// In en, this message translates to:
  /// **'No tasks here'**
  String get emptyTaskList;

  /// Confirm button to create a task
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// Label for task priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriority;

  /// Title of the Settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header for appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// Theme option: follow system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option: light mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: dark mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Settings section header for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// Language option: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option: Chinese
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// Settings section header for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// Toggle for global notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notificationsGlobal;

  /// Setting for default reminder advance time
  ///
  /// In en, this message translates to:
  /// **'Default Reminder'**
  String get notificationsDefaultReminder;

  /// Value label for default reminder minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String notificationsDefaultReminderValue(int minutes);

  /// Setting for overdue notification repeat interval
  ///
  /// In en, this message translates to:
  /// **'Overdue Repeat Interval'**
  String get notificationsOverdueRepeat;

  /// Value label for overdue repeat hours
  ///
  /// In en, this message translates to:
  /// **'Every {hours} h'**
  String notificationsOverdueRepeatValue(int hours);

  /// Settings section header for DND
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get dndSection;

  /// Toggle for do not disturb mode
  ///
  /// In en, this message translates to:
  /// **'Enable Do Not Disturb'**
  String get dndEnabled;

  /// Setting for DND start time
  ///
  /// In en, this message translates to:
  /// **'DND Start'**
  String get dndStart;

  /// Setting for DND end time
  ///
  /// In en, this message translates to:
  /// **'DND End'**
  String get dndEnd;

  /// Settings section header for sync
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get syncSection;

  /// Placeholder text for sync feature
  ///
  /// In en, this message translates to:
  /// **'Cloud sync — coming in Phase 2'**
  String get syncComingSoon;

  /// Settings section header for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// Link to privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// Link to open source licenses
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get aboutOpenSource;

  /// Save action label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Complete action label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get actionComplete;

  /// Edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Add action label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Error when task title is empty
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get errorEmptyTitle;

  /// Error when due date is before start date
  ///
  /// In en, this message translates to:
  /// **'Due date must be after start date'**
  String get errorDueBeforeStart;

  /// Error for invalid reminder
  ///
  /// In en, this message translates to:
  /// **'Invalid reminder time'**
  String get errorInvalidReminder;

  /// Error when item is not found
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get errorNotFound;

  /// Error when saving data fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save data'**
  String get errorPersistence;

  /// Error when permission is denied
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermission;

  /// Dialog title for setting reminder minutes
  ///
  /// In en, this message translates to:
  /// **'Set reminder advance (minutes)'**
  String get minutesDialog;

  /// Dialog title for setting overdue repeat hours
  ///
  /// In en, this message translates to:
  /// **'Set overdue repeat interval (hours)'**
  String get hoursDialog;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
