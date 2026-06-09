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

  /// Navigation label for the Dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation label for the Projects tab
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

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

  /// Shown when a date has no specific time
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get allDay;

  /// Tooltip to clear a date's time component
  ///
  /// In en, this message translates to:
  /// **'Clear time (all day)'**
  String get clearTime;

  /// Desktop button to open the full create-task sheet
  ///
  /// In en, this message translates to:
  /// **'New task with date & time'**
  String get newTaskWithTime;

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

  /// Calendar previous-window button tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get calendarPrevious;

  /// Calendar next-window button tooltip
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get calendarNext;

  /// Calendar button or date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// Calendar view selector label for day view
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendarDay;

  /// Calendar view selector label for week view
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarWeek;

  /// Calendar view selector label for month view
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// Calendar view selector label for gantt view
  ///
  /// In en, this message translates to:
  /// **'Gantt'**
  String get calendarGantt;

  /// Calendar load error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String calendarLoadError(String message);

  /// Summary text for number of tasks in the current week
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks this week} =1{1 task this week} other{{count} tasks this week}}'**
  String calendarWeekTaskCount(int count);

  /// Month cell overflow label for hidden tasks
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String calendarMoreTasks(int count);

  /// Hint text for the search input
  ///
  /// In en, this message translates to:
  /// **'Search tasks…'**
  String get searchHint;

  /// Search empty-state title
  ///
  /// In en, this message translates to:
  /// **'No tasks match your search'**
  String get searchNoResults;

  /// Search empty-state helper text
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or filters'**
  String get searchTryDifferentFilters;

  /// Search load error message
  ///
  /// In en, this message translates to:
  /// **'Search failed: {message}'**
  String searchFailed(String message);

  /// Action chip label to clear search filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClearFilters;

  /// Default date filter chip label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get searchDateFilter;

  /// Search date filter label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get searchDateToday;

  /// Search date filter label for this week
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get searchDateThisWeek;

  /// Search date filter label for this month
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get searchDateThisMonth;

  /// Search date filter label for a custom range
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get searchDateCustomRange;

  /// Search date filter label to clear the selected date
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get searchDateClearFilter;

  /// Search date overlap chip label
  ///
  /// In en, this message translates to:
  /// **'Overlap {range}'**
  String searchDateOverlap(String range);

  /// Search status filter label for all tasks
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchStatusAll;

  /// Search status filter label for incomplete tasks
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get searchStatusIncomplete;

  /// Search status filter label for completed tasks
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get searchStatusDone;

  /// Search status filter label for overdue tasks
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get searchStatusOverdue;

  /// Search priority filter label for high priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get searchPriorityHigh;

  /// Search priority filter label for medium priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get searchPriorityMedium;

  /// Search priority filter label for low priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get searchPriorityLow;

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

  /// Generic save button
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

  /// Title of the delete-task confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// Body of the delete-task confirmation dialog, naming the task
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove \"{title}\".'**
  String deleteTaskMessage(String title);

  /// Body of the delete-task confirmation dialog when the title is unavailable
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the task.'**
  String get deleteTaskGenericMessage;

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

  /// Label for the project picker
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectLabel;

  /// Context-menu action to create a task on the selected day
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get calendarCreateTaskHere;

  /// Context-menu action to open the day view
  ///
  /// In en, this message translates to:
  /// **'Open day'**
  String get calendarOpenDay;

  /// Dashboard empty state when there are no relevant tasks
  ///
  /// In en, this message translates to:
  /// **'Nothing due. You are all clear!'**
  String get dashboardEmpty;

  /// Empty state for an individual dashboard section
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get dashboardSectionEmpty;

  /// Dashboard section header for overdue tasks
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardOverdue;

  /// Dashboard section header for today's tasks
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// Dashboard section header for upcoming tasks within N days
  ///
  /// In en, this message translates to:
  /// **'Upcoming ({days} days)'**
  String dashboardUpcoming(int days);

  /// Settings label for the dashboard upcoming window length
  ///
  /// In en, this message translates to:
  /// **'Upcoming window'**
  String get dashboardUpcomingDaysSetting;

  /// Value label for the dashboard upcoming window length
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String dashboardUpcomingDaysValue(int days);

  /// Dialog title for setting the dashboard upcoming window length
  ///
  /// In en, this message translates to:
  /// **'Upcoming window (days)'**
  String get dashboardUpcomingDaysDialog;

  /// Empty state for the projects list
  ///
  /// In en, this message translates to:
  /// **'No projects yet. Tap + to create one.'**
  String get projectsEmpty;

  /// Title of the create-project dialog
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get projectCreateTitle;

  /// Title of the edit-project dialog
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get projectEditTitle;

  /// Label for the project name field
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectNameLabel;

  /// Label for the project color picker
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get projectColorLabel;

  /// Title of the delete-project dialog
  ///
  /// In en, this message translates to:
  /// **'Delete project?'**
  String get projectDeleteTitle;

  /// Body of the delete-project dialog
  ///
  /// In en, this message translates to:
  /// **'What should happen to the tasks in \"{name}\"?'**
  String projectDeleteMessage(String name);

  /// Delete-project option: move tasks to inbox
  ///
  /// In en, this message translates to:
  /// **'Move to Inbox'**
  String get projectDeleteMoveInbox;

  /// Delete-project option: delete tasks too
  ///
  /// In en, this message translates to:
  /// **'Delete tasks'**
  String get projectDeleteWithTasks;

  /// Project detail tab: task list
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get projectTabList;

  /// Project detail tab: calendar
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get projectTabCalendar;

  /// Project detail tab: gantt
  ///
  /// In en, this message translates to:
  /// **'Gantt'**
  String get projectTabGantt;

  /// Error when a project name is empty
  ///
  /// In en, this message translates to:
  /// **'Project name cannot be empty'**
  String get errorEmptyProjectName;

  /// Application title shown in the shell header
  ///
  /// In en, this message translates to:
  /// **'PlanList'**
  String get appTitle;

  /// Tooltip for the placeholder account avatar
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestAccount;

  /// Tooltip for collapsing the desktop sidebar
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get sidebarCollapse;

  /// Placeholder in the desktop detail panel
  ///
  /// In en, this message translates to:
  /// **'Select a task'**
  String get selectTaskHint;

  /// Sidebar section label for tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get navTags;

  /// Empty state when no tags exist
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get tagsEmpty;

  /// Sidebar section label for smart filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get navFilters;

  /// Smart filter: tasks due today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// Smart filter: overdue tasks
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// Smart filter: completed tasks
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// Tooltip for the global FAB
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// Overdue badge on task rows
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get taskOverdue;

  /// Subtask count suffix on task rows
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subtask} other{{count} subtasks}}'**
  String subtaskCount(int count);

  /// High priority badge label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Medium priority badge label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Low priority badge label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// List toolbar sort dropdown label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// List toolbar filter dropdown label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterLabel;

  /// Task detail section: dates
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get detailSectionDates;

  /// Task detail section: priority, project, tags
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get detailSectionAttributes;

  /// Task detail section: subtasks
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get detailSectionSubtasks;

  /// Task detail section: reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get detailSectionReminders;

  /// Task detail section: recurrence
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get detailSectionRecurrence;

  /// Task detail section: notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailSectionNotes;

  /// Task detail section: created/completed meta
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get detailSectionMeta;

  /// Placeholder for reminders UI
  ///
  /// In en, this message translates to:
  /// **'Reminders coming soon'**
  String get remindersComingSoon;

  /// Task detail loading state
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get taskLoading;

  /// Task detail when task is missing
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// Settings: Gantt bar coloring mode
  ///
  /// In en, this message translates to:
  /// **'Gantt bar color'**
  String get barColorMode;

  /// Gantt bars colored by priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get barColorPriority;

  /// Gantt bars colored by project
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get barColorProject;

  /// Settings: default calendar view
  ///
  /// In en, this message translates to:
  /// **'Default calendar view'**
  String get defaultCalendarView;

  /// Search filter group: status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterSectionStatus;

  /// Search filter group: priority
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get filterSectionPriority;

  /// Search filter group: date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filterSectionDate;

  /// Search filter group: tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get filterSectionTags;

  /// Search filter group: projects
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get filterSectionProjects;
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
