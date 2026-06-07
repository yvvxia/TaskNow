// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProjectsTable get projects => attachedDatabase.projects;
  $RecurrenceRulesTable get recurrenceRules => attachedDatabase.recurrenceRules;
  $TasksTable get tasks => attachedDatabase.tasks;
  $SubtasksTable get subtasks => attachedDatabase.subtasks;
  $TagsTable get tags => attachedDatabase.tags;
  $TaskTagsTable get taskTags => attachedDatabase.taskTags;
  $RemindersTable get reminders => attachedDatabase.reminders;
  TaskDaoManager get managers => TaskDaoManager(this);
}

class TaskDaoManager {
  final _$TaskDaoMixin _db;
  TaskDaoManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db.attachedDatabase, _db.projects);
  $$RecurrenceRulesTableTableManager get recurrenceRules =>
      $$RecurrenceRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurrenceRules,
      );
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db.attachedDatabase, _db.subtasks);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db.attachedDatabase, _db.taskTags);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
}
