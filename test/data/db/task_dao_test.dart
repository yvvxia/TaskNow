import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task_query.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/db/task_dao.dart';

int ms(int y, int m, int d) => DateTime.utc(y, m, d).millisecondsSinceEpoch;

TaskRow taskRow(
  String id, {
  String title = 'task',
  String? notes,
  int? start,
  int? due,
  bool completed = false,
  int priority = 2,
  String? projectId,
}) {
  return TaskRow(
    id: id,
    title: title,
    notes: notes,
    projectId: projectId,
    startDate: start,
    dueDate: due,
    createdAt: 0,
    priority: priority,
    isCompleted: completed,
    sortOrder: 0,
    autoCompleteOnSubtasks: false,
    updatedAt: 0,
    syncVersion: 0,
  );
}

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = newTestDb();
    dao = db.taskDao;
  });
  tearDown(() => db.close());

  group('range query intersection', () {
    setUp(() async {
      await dao.upsertTask(
        taskRow('a', start: ms(2026, 6, 1), due: ms(2026, 6, 3)),
        const [],
      );
      await dao.upsertTask(
        taskRow('b', start: ms(2026, 6, 5), due: ms(2026, 6, 10)),
        const [],
      );
      await dao.upsertTask(taskRow('c', due: ms(2026, 6, 2)), const []);
      await dao.upsertTask(taskRow('d', start: ms(2026, 6, 20)), const []);
      await dao.upsertTask(taskRow('e'), const []); // no dates
    });

    test('returns only tasks overlapping the window', () async {
      final rows = await dao.getInRange(ms(2026, 6, 2), ms(2026, 6, 6));
      expect(rows.map((r) => r.id).toSet(), {'a', 'b', 'c'});
    });

    test('excludes dateless tasks and non-overlapping tasks', () async {
      final rows = await dao.getInRange(ms(2026, 6, 2), ms(2026, 6, 6));
      final ids = rows.map((r) => r.id);
      expect(ids, isNot(contains('d')));
      expect(ids, isNot(contains('e')));
    });

    test('watchInRange emits the same intersection', () async {
      final rows = await dao.watchInRange(ms(2026, 6, 2), ms(2026, 6, 6)).first;
      expect(rows.map((r) => r.id).toSet(), {'a', 'b', 'c'});
    });

    test('soft-deleted tasks drop out of the range', () async {
      await dao.softDelete('a', ms(2026, 6, 4));
      final rows = await dao.getInRange(ms(2026, 6, 2), ms(2026, 6, 6));
      expect(rows.map((r) => r.id).toSet(), {'b', 'c'});
    });
  });

  group('buildQuery dynamic filters', () {
    final nowMs = ms(2026, 6, 15);

    setUp(() async {
      await dao.upsertTask(
        taskRow('hi', priority: Priority.high.index, completed: false),
        const [],
      );
      await dao.upsertTask(taskRow('done', completed: true), const []);
      await dao.upsertTask(
        taskRow('overdue', due: ms(2026, 6, 1), completed: false),
        const [],
      );
    });

    test('status incomplete excludes completed tasks', () async {
      final rows = await dao
          .buildQuery(
            const TaskQuery(status: TaskStatus.incomplete),
            nowMs: nowMs,
          )
          .get();
      expect(rows.map((r) => r.id), isNot(contains('done')));
    });

    test('status complete returns only completed tasks', () async {
      final rows = await dao
          .buildQuery(
            const TaskQuery(status: TaskStatus.complete),
            nowMs: nowMs,
          )
          .get();
      expect(rows.map((r) => r.id).toSet(), {'done'});
    });

    test('status overdue returns past-due incomplete tasks', () async {
      final rows = await dao
          .buildQuery(const TaskQuery(status: TaskStatus.overdue), nowMs: nowMs)
          .get();
      expect(rows.map((r) => r.id).toSet(), {'overdue'});
    });

    test('priority filter', () async {
      final rows = await dao
          .buildQuery(const TaskQuery(priority: Priority.high), nowMs: nowMs)
          .get();
      expect(rows.map((r) => r.id).toSet(), {'hi'});
    });

    test('tag filter via join', () async {
      await db.into(db.tags).insert(const TagRow(id: 'tag1', name: 'urgent'));
      await dao.upsertTask(taskRow('tagged'), const ['tag1']);
      final rows = await dao
          .buildQuery(const TaskQuery(tagIds: ['tag1']), nowMs: nowMs)
          .get();
      expect(rows.map((r) => r.id).toSet(), {'tagged'});
    });

    test('sort by createdAt is descending', () async {
      // createdAt is 0 for all; ensure query runs and returns rows.
      final rows = await dao
          .buildQuery(const TaskQuery(sort: TaskSort.createdAt), nowMs: nowMs)
          .get();
      expect(rows, isNotEmpty);
    });
  });

  group('FTS triggers keep tasks_fts in sync', () {
    test('insert trigger indexes title and notes', () async {
      await dao.upsertTask(
        taskRow('m', title: 'Buy milk', notes: 'grocery store'),
        const [],
      );
      expect((await dao.searchFts('milk')).map((r) => r.id), {'m'});
      expect((await dao.searchFts('grocery')).map((r) => r.id), {'m'});
    });

    test('update trigger re-indexes new content', () async {
      await dao.upsertTask(taskRow('m', title: 'Buy milk'), const []);
      await dao.upsertTask(taskRow('m', title: 'Buy bread'), const []);
      expect(await dao.searchFts('milk'), isEmpty);
      expect((await dao.searchFts('bread')).map((r) => r.id), {'m'});
    });

    test('delete trigger removes the row from the index', () async {
      await dao.upsertTask(taskRow('m', title: 'Buy bread'), const []);
      await (db.delete(db.tasks)..where((t) => t.id.equals('m'))).go();
      expect(await dao.searchFts('bread'), isEmpty);
    });

    test('search excludes soft-deleted tasks', () async {
      await dao.upsertTask(taskRow('m', title: 'Buy bread'), const []);
      await dao.softDelete('m', ms(2026, 6, 1));
      expect(await dao.searchFts('bread'), isEmpty);
    });
  });

  group('upsert with relations', () {
    test('replaces tag links atomically', () async {
      await db.into(db.tags).insert(const TagRow(id: 't1', name: 'a'));
      await db.into(db.tags).insert(const TagRow(id: 't2', name: 'b'));
      await dao.upsertTask(taskRow('x'), const ['t1', 't2']);
      expect((await dao.tagIdsFor('x')).toSet(), {'t1', 't2'});

      await dao.upsertTask(taskRow('x'), const ['t1']);
      expect(await dao.tagIdsFor('x'), const ['t1']);
    });

    test('findById ignores soft-deleted rows', () async {
      await dao.upsertTask(taskRow('x'), const []);
      expect(await dao.findById('x'), isNotNull);
      await dao.softDelete('x', ms(2026, 6, 1));
      expect(await dao.findById('x'), isNull);
      expect(await dao.findByIdIncludingDeleted('x'), isNotNull);
    });

    test('softDeleteSeries soft-deletes all tasks sharing a parent', () async {
      await dao.upsertTask(taskRow('p'), const []);
      await db
          .into(db.tasks)
          .insert(
            taskRow('child1').copyWith(recurrenceParent: const Value('series')),
          );
      await db
          .into(db.tasks)
          .insert(
            taskRow('child2').copyWith(recurrenceParent: const Value('series')),
          );
      await dao.softDeleteSeries('series', ms(2026, 6, 1));
      expect(await dao.findById('child1'), isNull);
      expect(await dao.findById('child2'), isNull);
    });
  });
}
