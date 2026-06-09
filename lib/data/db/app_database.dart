import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'project_dao.dart';
import 'reminder_dao.dart';
import 'tables.dart';
import 'tag_dao.dart';
import 'task_dao.dart';

part 'app_database.g.dart';

/// SQL that creates the FTS5 virtual table mirroring `tasks(title, notes)` and
/// the triggers that keep it in sync. See design §3.4. Run once on create.
const List<String> _ftsStatements = <String>[
  'CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts USING fts5('
      'title, notes, content=\'tasks\', content_rowid=\'rowid\');',
  'CREATE TRIGGER IF NOT EXISTS tasks_ai AFTER INSERT ON tasks BEGIN '
      'INSERT INTO tasks_fts(rowid, title, notes) '
      'VALUES (new.rowid, new.title, new.notes); END;',
  'CREATE TRIGGER IF NOT EXISTS tasks_ad AFTER DELETE ON tasks BEGIN '
      'INSERT INTO tasks_fts(tasks_fts, rowid, title, notes) '
      'VALUES(\'delete\', old.rowid, old.title, old.notes); END;',
  'CREATE TRIGGER IF NOT EXISTS tasks_au AFTER UPDATE ON tasks BEGIN '
      'INSERT INTO tasks_fts(tasks_fts, rowid, title, notes) '
      'VALUES(\'delete\', old.rowid, old.title, old.notes); '
      'INSERT INTO tasks_fts(rowid, title, notes) '
      'VALUES (new.rowid, new.title, new.notes); END;',
];

/// Secondary indexes named in the task checklist (design §3.3).
const List<String> _indexStatements = <String>[
  'CREATE INDEX IF NOT EXISTS idx_task_due ON tasks(due_date);',
  'CREATE INDEX IF NOT EXISTS idx_task_start ON tasks(start_date);',
  'CREATE INDEX IF NOT EXISTS idx_task_completed ON tasks(is_completed);',
  'CREATE INDEX IF NOT EXISTS idx_task_project ON tasks(project_id);',
  'CREATE INDEX IF NOT EXISTS idx_task_deleted ON tasks(deleted_at);',
  'CREATE INDEX IF NOT EXISTS idx_reminder_trig '
      'ON reminders(trigger_at, is_fired);',
  'CREATE INDEX IF NOT EXISTS idx_subtask_task '
      'ON subtasks(task_id, sort_order);',
];

/// The default project seeded on first run. Tasks with no project belong here.
const String kInboxProjectId = 'inbox';

@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    Subtasks,
    Tags,
    TaskTags,
    Reminders,
    RecurrenceRules,
  ],
  daos: [TaskDao, ProjectDao, TagDao, ReminderDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final sql in _indexStatements) {
        await customStatement(sql);
      }
      for (final sql in _ftsStatements) {
        await customStatement(sql);
      }
      await _seedDefaultProject();
    },
    onUpgrade: (m, from, to) async {
      // v1 -> v2: per-Gantt-row manual ordering column.
      if (from < 2) {
        await m.addColumn(tasks, tasks.ganttOrder);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Seeds the default `Inbox / 收件箱` project on first run.
  Future<void> _seedDefaultProject() async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    await into(projects).insert(
      ProjectRow(
        id: kInboxProjectId,
        name: 'Inbox / 收件箱',
        sortOrder: 0,
        createdAt: nowMs,
        updatedAt: nowMs,
        syncVersion: 0,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

/// Opens the production database connection.
///
/// Stores the SQLite file in the platform application-documents directory
/// (works on Windows and Android via `path_provider`). Wrapped in a
/// [LazyDatabase] so the async path lookup happens on first use, keeping the
/// constructor synchronous and tests free to inject [NativeDatabase.memory].
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'plan_list.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Creates an in-memory database for tests (no file, no `path_provider`).
AppDatabase newTestDb() => AppDatabase(NativeDatabase.memory());

/// Shared UUID generator for repository-assigned ids.
const Uuid kUuid = Uuid();
