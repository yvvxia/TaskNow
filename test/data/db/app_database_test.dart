import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDb());
  tearDown(() => db.close());

  Future<Set<String>> objectsOfType(String type) async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = '$type'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  test('schemaVersion is 1', () {
    expect(db.schemaVersion, 1);
  });

  test('first run seeds the default Inbox project', () async {
    final projects = await db.select(db.projects).get();
    expect(projects, hasLength(1));
    expect(projects.single.id, kInboxProjectId);
    expect(projects.single.name, contains('Inbox'));
  });

  test('creates all named indexes', () async {
    final indexes = await objectsOfType('index');
    expect(
      indexes,
      containsAll(<String>[
        'idx_task_due',
        'idx_task_start',
        'idx_task_completed',
        'idx_task_project',
        'idx_task_deleted',
        'idx_reminder_trig',
        'idx_subtask_task',
      ]),
    );
  });

  test('creates the FTS5 virtual table and sync triggers', () async {
    final tables = await objectsOfType('table');
    expect(tables, contains('tasks_fts'));
    final triggers = await objectsOfType('trigger');
    expect(triggers, containsAll(<String>['tasks_ai', 'tasks_ad', 'tasks_au']));
  });

  test('foreign key enforcement is enabled', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, 1);
  });

  test('start_date <= due_date check constraint is enforced', () async {
    final nowMs = DateTime.utc(2026).millisecondsSinceEpoch;
    Future<void> insertBad() => db.into(db.tasks).insert(
          TasksCompanion.insert(
            id: 'bad',
            title: 'invalid range',
            createdAt: nowMs,
            updatedAt: nowMs,
            startDate: Value(DateTime.utc(2026, 6, 10).millisecondsSinceEpoch),
            dueDate: Value(DateTime.utc(2026, 6, 1).millisecondsSinceEpoch),
          ),
        );
    await expectLater(insertBad(), throwsA(isA<SqliteException>()));
  });

  test('migration placeholder: a fresh database opens at version 1', () async {
    // Until schemaVersion > 1 there are no upgrade steps; opening the database
    // must succeed and run onCreate (verified by the seed/index tests above).
    final fresh = newTestDb();
    addTearDown(fresh.close);
    final result =
        await fresh.customSelect('SELECT 1 AS ok').getSingle();
    expect(result.read<int>('ok'), 1);
  });
}
