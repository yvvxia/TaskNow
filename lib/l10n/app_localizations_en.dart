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
  String get navDashboard => 'Dashboard';

  @override
  String get navProjects => 'Projects';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get addTaskHint => 'Add a task… (press Enter)';

  @override
  String get newTaskTitle => 'Task title';

  @override
  String get taskStartDate => 'Start date';

  @override
  String get taskDueDate => 'Due date';

  @override
  String get dateNotSet => 'Not set';

  @override
  String get dateClear => 'Clear';

  @override
  String get allDay => 'All day';

  @override
  String get clearTime => 'Clear time (all day)';

  @override
  String get newTaskWithTime => 'New task with date & time';

  @override
  String get emptyTaskList => 'No tasks here';

  @override
  String get createAction => 'Create';

  @override
  String get taskPriority => 'Priority';

  @override
  String get calendarPrevious => 'Previous';

  @override
  String get calendarNext => 'Next';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarDay => 'Day';

  @override
  String get calendarWeek => 'Week';

  @override
  String get calendarMonth => 'Month';

  @override
  String get calendarGantt => 'Gantt';

  @override
  String calendarLoadError(String message) {
    return 'Error: $message';
  }

  @override
  String calendarWeekTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks this week',
      one: '1 task this week',
      zero: 'No tasks this week',
    );
    return '$_temp0';
  }

  @override
  String calendarMoreTasks(int count) {
    return '+$count more';
  }

  @override
  String get searchHint => 'Search tasks…';

  @override
  String get searchNoResults => 'No tasks match your search';

  @override
  String get searchTryDifferentFilters => 'Try different keywords or filters';

  @override
  String searchFailed(String message) {
    return 'Search failed: $message';
  }

  @override
  String get searchClearFilters => 'Clear';

  @override
  String get searchDateFilter => 'Date';

  @override
  String get searchDateToday => 'Today';

  @override
  String get searchDateThisWeek => 'This week';

  @override
  String get searchDateThisMonth => 'This month';

  @override
  String get searchDateCustomRange => 'Custom range';

  @override
  String get searchDateClearFilter => 'Clear date filter';

  @override
  String searchDateOverlap(String range) {
    return 'Overlap $range';
  }

  @override
  String get searchStatusAll => 'All';

  @override
  String get searchStatusIncomplete => 'Incomplete';

  @override
  String get searchStatusDone => 'Done';

  @override
  String get searchStatusOverdue => 'Overdue';

  @override
  String get searchPriorityHigh => 'High';

  @override
  String get searchPriorityMedium => 'Medium';

  @override
  String get searchPriorityLow => 'Low';

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
  String get aboutFonts => 'Fonts';

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
  String get deleteTaskTitle => 'Delete task?';

  @override
  String deleteTaskMessage(String title) {
    return 'This will permanently remove \"$title\".';
  }

  @override
  String get deleteTaskGenericMessage =>
      'This will permanently remove the task.';

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

  @override
  String get projectLabel => 'Project';

  @override
  String get calendarCreateTaskHere => 'Create task';

  @override
  String get calendarOpenDay => 'Open day';

  @override
  String get dashboardEmpty => 'Nothing due. You are all clear!';

  @override
  String get dashboardSectionEmpty => 'Nothing here';

  @override
  String get dashboardOverdue => 'Overdue';

  @override
  String get dashboardToday => 'Today';

  @override
  String dashboardUpcoming(int days) {
    return 'Upcoming ($days days)';
  }

  @override
  String get dashboardUpcomingDaysSetting => 'Upcoming window';

  @override
  String dashboardUpcomingDaysValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashboardUpcomingDaysDialog => 'Upcoming window (days)';

  @override
  String get projectsEmpty => 'No projects yet. Tap + to create one.';

  @override
  String get projectCreateTitle => 'New project';

  @override
  String get projectEditTitle => 'Edit project';

  @override
  String get projectNameLabel => 'Project name';

  @override
  String get projectColorLabel => 'Color';

  @override
  String get projectDeleteTitle => 'Delete project?';

  @override
  String projectDeleteMessage(String name) {
    return 'What should happen to the tasks in \"$name\"?';
  }

  @override
  String get projectDeleteMoveInbox => 'Move to Inbox';

  @override
  String get projectDeleteWithTasks => 'Delete tasks';

  @override
  String get projectTabList => 'List';

  @override
  String get projectTabCalendar => 'Calendar';

  @override
  String get projectTabGantt => 'Gantt';

  @override
  String get errorEmptyProjectName => 'Project name cannot be empty';

  @override
  String get appTitle => 'PlanList';

  @override
  String get guestAccount => 'Guest';

  @override
  String get sidebarCollapse => 'Collapse sidebar';

  @override
  String get selectTaskHint => 'Select a task';

  @override
  String get navTags => 'Tags';

  @override
  String get tagsEmpty => 'No tags yet';

  @override
  String get navFilters => 'Filters';

  @override
  String get filterToday => 'Today';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get newTask => 'New task';

  @override
  String get taskOverdue => 'Overdue';

  @override
  String subtaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subtasks',
      one: '1 subtask',
    );
    return '$_temp0';
  }

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get sortLabel => 'Sort';

  @override
  String get filterLabel => 'Filter';

  @override
  String get detailSectionDates => 'Dates';

  @override
  String get detailSectionAttributes => 'Attributes';

  @override
  String get detailSectionSubtasks => 'Subtasks';

  @override
  String get detailSectionReminders => 'Reminders';

  @override
  String get detailSectionRecurrence => 'Recurrence';

  @override
  String get detailSectionNotes => 'Notes';

  @override
  String get detailSectionMeta => 'Info';

  @override
  String get remindersComingSoon => 'Reminders coming soon';

  @override
  String get taskLoading => 'Loading…';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get barColorMode => 'Gantt bar color';

  @override
  String get barColorPriority => 'Priority';

  @override
  String get barColorProject => 'Project';

  @override
  String get defaultCalendarView => 'Default calendar view';

  @override
  String get filterSectionStatus => 'Status';

  @override
  String get filterSectionPriority => 'Priority';

  @override
  String get filterSectionDate => 'Date';

  @override
  String get filterSectionTags => 'Tags';

  @override
  String get filterSectionProjects => 'Projects';
}
