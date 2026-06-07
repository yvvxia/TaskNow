// Global enums shared across modules. Integer values mirror
// `doc/proposal.md` §4.2 so they stay stable for persistence and sync.

/// Task priority. Lower index = higher priority (matches proposal: HIGH = 0).
enum Priority {
  high,
  medium,
  low,
}

/// Task lifecycle status. `overdue` is a derived state computed by the
/// scheduler when a task is past due and still incomplete.
enum TaskStatus {
  incomplete,
  complete,
  overdue,
}

/// Type of a reminder, controlling how its trigger time is computed.
enum ReminderType {
  beforeDue,
  atStart,
  custom,
  overdue,
}

/// Recurrence frequency for repeating tasks.
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  custom,
}

/// Calendar / Gantt view granularity.
enum CalendarViewType {
  day,
  week,
  month,
  gantt,
}

/// Sort order options for task lists (proposal §3.1.4).
/// Legacy values (`dueDate`, `priority`, `createdAt`) remain for module 02;
/// module 04 adds explicit asc/desc/manual variants.
enum TaskSort {
  dueDate,
  priority,
  createdAt,
  dueAsc,
  dueDesc,
  priorityDesc,
  createdDesc,
  manual,
}

/// Strategy for what happens to a project's tasks when the project is deleted.
enum ProjectDeleteMode {
  /// Delete the project and all of its tasks.
  deleteTasks,

  /// Keep the tasks but move them out of the project (to the inbox).
  moveToInbox,
}

/// Status emitted by the (Phase 2) sync engine.
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}
