import 'package:drift/drift.dart';

/// Drift table definitions for the local SQLite schema.
///
/// Column names are emitted in `snake_case` (see `build.yaml`) so they match
/// the DDL in `design/01-data-and-persistence.md` §3. Row data classes are
/// renamed with a `Row` suffix (e.g. [TaskRow]) to avoid colliding with the
/// domain entities in `core/models`.

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // --- Sync-reserved ---
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurrenceRuleRow')
class RecurrenceRules extends Table {
  TextColumn get id => text()();
  IntColumn get frequency => integer()();
  IntColumn get interval => integer().withDefault(const Constant(1))();

  /// JSON array, e.g. `[1,3,5]` (Mon/Wed/Fri).
  TextColumn get byweekday => text().nullable()();
  IntColumn get byMonthDay => integer().nullable()();
  IntColumn get endDate => integer().nullable()();
  IntColumn get count => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId =>
      text().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get startDate => integer().nullable()(); // UTC ms
  IntColumn get dueDate => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get recurrenceRuleId => text()
      .nullable()
      .references(RecurrenceRules, #id, onDelete: KeyAction.setNull)();
  TextColumn get recurrenceParent => text().nullable()();
  BoolColumn get autoCompleteOnSubtasks =>
      boolean().withDefault(const Constant(false))();

  // --- Sync-reserved ---
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => <String>[
        'CHECK (due_date IS NULL OR start_date IS NULL OR due_date >= start_date)',
      ];
}

@DataClassName('SubtaskRow')
class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskTagRow')
class TaskTags extends Table {
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {taskId, tagId};
}

@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId =>
      text().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get triggerAt => integer()(); // absolute UTC ms
  IntColumn get type => integer()();
  IntColumn get offsetMin => integer().nullable()();
  BoolColumn get isFired => boolean().withDefault(const Constant(false))();
  IntColumn get notifId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
