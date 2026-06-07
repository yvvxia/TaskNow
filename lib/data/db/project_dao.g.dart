// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dao.dart';

// ignore_for_file: type=lint
mixin _$ProjectDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProjectsTable get projects => attachedDatabase.projects;
  $RecurrenceRulesTable get recurrenceRules => attachedDatabase.recurrenceRules;
  $TasksTable get tasks => attachedDatabase.tasks;
  ProjectDaoManager get managers => ProjectDaoManager(this);
}

class ProjectDaoManager {
  final _$ProjectDaoMixin _db;
  ProjectDaoManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db.attachedDatabase, _db.projects);
  $$RecurrenceRulesTableTableManager get recurrenceRules =>
      $$RecurrenceRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurrenceRules,
      );
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
}
