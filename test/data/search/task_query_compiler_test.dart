import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/enums/status_filter.dart';
import 'package:plan_list/core/models/date_filter.dart';
import 'package:plan_list/core/models/task_query.dart';
import 'package:plan_list/data/db/app_database.dart';
import 'package:plan_list/data/db/task_dao.dart';
import 'package:plan_list/data/db/task_query_compiler.dart';

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
  int createdAt = 0,
  int sortOrder = 0,
}) {
  return TaskRow(
    id: id,
    title: title,
    notes: notes,
    projectId: projectId,
    startDate: start,
    dueDate: due,
    createdAt: createdAt,
    priority: priority,
    isCompleted: completed,
    sortOrder: sortOrder,
    autoCompleteOnSubtasks: false,
    updatedAt: 0,
    syncVersion: 0,
  );
}

void main() {
  late AppDatabase db;
  late TaskDao dao;
  late TaskQueryCompiler compiler;
  final nowMs = ms(2026, 6, 15);

  setUp(() {
    db = newTestDb();
    dao = db.taskDao;
    compiler = TaskQueryCompiler(db);
  });
  tearDown(() => db.close());

  group('deleted filter', () {
    test('excludes soft-deleted tasks by default', () async {
      await dao.upsertTask(taskRow('live', title: 'visible'), const []);
      await dao.upsertTask(taskRow('gone', title: 'hidden'), const []);
      await dao.softDelete('gone', nowMs);

      final rows = await compiler.query(const TaskQuery(), nowMs: nowMs);
      expect(rows.map((r) => r.id), ['live']);
    });

    test('includeDeleted shows soft-deleted tasks', () async {
      await dao.upsertTask(taskRow('gone', title: 'hidden'), const []);
      await dao.softDelete('gone', nowMs);

      final rows = await compiler.query(
        const TaskQuery(includeDeleted: true),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['gone']);
    });
  });

  group('status filter', () {
    setUp(() async {
      await dao.upsertTask(taskRow('open'), const []);
      await dao.upsertTask(taskRow('done', completed: true), const []);
      await dao.upsertTask(
        taskRow('late', due: ms(2026, 6, 1), completed: false),
        const [],
      );
    });

    test('incomplete excludes completed', () async {
      final rows = await compiler.query(
        const TaskQuery(statusFilter: StatusFilter.incomplete),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id).toSet(), {'open', 'late'});
    });

    test('complete returns only completed tasks', () async {
      final rows = await compiler.query(
        const TaskQuery(
          statusFilter: StatusFilter.complete,
          includeCompleted: true,
        ),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['done']);
    });

    test('overdue returns past-due incomplete tasks', () async {
      final rows = await compiler.query(
        const TaskQuery(statusFilter: StatusFilter.overdue),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['late']);
    });

    test('legacy TaskStatus still works', () async {
      final rows = await compiler.query(
        const TaskQuery(status: TaskStatus.complete),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['done']);
    });
  });

  group('priority filter', () {
    test('filters by single legacy priority', () async {
      await dao.upsertTask(
        taskRow('hi', priority: Priority.high.index),
        const [],
      );
      await dao.upsertTask(taskRow('lo'), const []);

      final rows = await compiler.query(
        const TaskQuery(priority: Priority.high),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['hi']);
    });

    test('filters by multiple priorities', () async {
      await dao.upsertTask(
        taskRow('hi', priority: Priority.high.index),
        const [],
      );
      await dao.upsertTask(
        taskRow('med', priority: Priority.medium.index),
        const [],
      );
      await dao.upsertTask(
        taskRow('lo', priority: Priority.low.index),
        const [],
      );

      final rows = await compiler.query(
        TaskQuery(priorities: {Priority.high, Priority.low}),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id).toSet(), {'hi', 'lo'});
    });
  });

  group('project filter', () {
    setUp(() async {
      await db
          .into(db.projects)
          .insert(
            ProjectRow(
              id: 'p1',
              name: 'P1',
              sortOrder: 0,
              createdAt: 0,
              updatedAt: 0,
              syncVersion: 0,
            ),
          );
      await db
          .into(db.projects)
          .insert(
            ProjectRow(
              id: 'p2',
              name: 'P2',
              sortOrder: 1,
              createdAt: 0,
              updatedAt: 0,
              syncVersion: 0,
            ),
          );
    });

    test('filters by legacy projectId', () async {
      await dao.upsertTask(taskRow('a', projectId: 'p1'), const []);
      await dao.upsertTask(taskRow('b', projectId: 'p2'), const []);

      final rows = await compiler.query(
        const TaskQuery(projectId: 'p1'),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['a']);
    });

    test('filters by projectIds set', () async {
      await dao.upsertTask(taskRow('a', projectId: 'p1'), const []);
      await dao.upsertTask(taskRow('b', projectId: 'p2'), const []);

      final rows = await compiler.query(
        const TaskQuery(projectIds: {'p2'}),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['b']);
    });
  });

  group('tag filter', () {
    test('requires at least one matching tag', () async {
      await db.into(db.tags).insert(const TagRow(id: 't1', name: 'a'));
      await db.into(db.tags).insert(const TagRow(id: 't2', name: 'b'));
      await dao.upsertTask(taskRow('tagged'), const ['t1']);
      await dao.upsertTask(taskRow('other'), const ['t2']);

      final rows = await compiler.query(
        const TaskQuery(tagIds: ['t1']),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['tagged']);
    });
  });

  group('date filter', () {
    setUp(() async {
      await dao.upsertTask(taskRow('today', due: ms(2026, 6, 15)), const []);
      await dao.upsertTask(taskRow('week', due: ms(2026, 6, 17)), const []);
      await dao.upsertTask(taskRow('outside', due: ms(2026, 7, 1)), const []);
      await dao.upsertTask(
        taskRow('span', start: ms(2026, 6, 10), due: ms(2026, 6, 20)),
        const [],
      );
    });

    test('on matches tasks due on that day', () async {
      final rows = await compiler.query(
        TaskQuery(
          dateFilter: DateFilter.on(DateTime.utc(2026, 6, 15)),
          includeCompleted: true,
        ),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), contains('today'));
      expect(rows.map((r) => r.id), isNot(contains('outside')));
    });

    test('range matches due dates within window', () async {
      final rows = await compiler.query(
        TaskQuery(
          dateFilter: DateFilter.range(
            DateTimeRange(
              start: DateTime.utc(2026, 6, 14),
              end: DateTime.utc(2026, 6, 18),
            ),
          ),
          includeCompleted: true,
        ),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id).toSet(), {'today', 'week'});
    });

    test('overlap matches intersecting spans', () async {
      final rows = await compiler.query(
        TaskQuery(
          dateFilter: DateFilter.overlap(
            DateTimeRange(
              start: DateTime.utc(2026, 6, 14),
              end: DateTime.utc(2026, 6, 16),
            ),
          ),
          includeCompleted: true,
        ),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id).toSet(), {'today', 'span'});
    });
  });

  group('keyword + filters AND combination', () {
    test('keyword + overdue status combine with AND', () async {
      await dao.upsertTask(
        taskRow('match', title: '报告 overdue', due: ms(2026, 6, 1)),
        const [],
      );
      await dao.upsertTask(
        taskRow('wrong-status', title: '报告 ok', due: ms(2026, 6, 20)),
        const [],
      );
      await dao.upsertTask(
        taskRow('wrong-word', title: 'notes', due: ms(2026, 6, 1)),
        const [],
      );

      final rows = await compiler.query(
        TaskQuery(keyword: '报告', statusFilter: StatusFilter.overdue),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['match']);
    });

    test('keyword + tag combine with AND', () async {
      await db.into(db.tags).insert(const TagRow(id: 't1', name: 'urgent'));
      await dao.upsertTask(taskRow('match', title: 'Buy milk'), const ['t1']);
      await dao.upsertTask(taskRow('no-tag', title: 'Buy milk'), const []);
      await dao.upsertTask(taskRow('wrong-word', title: 'Bread'), const ['t1']);

      final rows = await compiler.query(
        const TaskQuery(keyword: 'milk', tagIds: ['t1']),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['match']);
    });
  });

  group('sort', () {
    setUp(() async {
      await dao.upsertTask(
        taskRow('b', due: ms(2026, 6, 20), createdAt: 2, sortOrder: 2),
        const [],
      );
      await dao.upsertTask(
        taskRow('a', due: ms(2026, 6, 10), createdAt: 1, sortOrder: 1),
        const [],
      );
    });

    test('dueAsc orders by due date ascending', () async {
      final rows = await compiler.query(
        const TaskQuery(sort: TaskSort.dueAsc, includeCompleted: true),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['a', 'b']);
    });

    test('dueDesc orders by due date descending', () async {
      final rows = await compiler.query(
        const TaskQuery(sort: TaskSort.dueDesc, includeCompleted: true),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['b', 'a']);
    });

    test('manual orders by sortOrder', () async {
      final rows = await compiler.query(
        const TaskQuery(sort: TaskSort.manual, includeCompleted: true),
        nowMs: nowMs,
      );
      expect(rows.map((r) => r.id), ['a', 'b']);
    });
  });

  group('TaskQuery.rangeOverlap factory', () {
    test('sets overlap date filter and includeCompleted', () {
      final range = DateTimeRange(
        start: DateTime.utc(2026, 6, 1),
        end: DateTime.utc(2026, 6, 30),
      );
      final q = TaskQuery.rangeOverlap(range);
      expect(q.dateFilter, DateFilter.overlap(range));
      expect(q.includeCompleted, isTrue);
    });
  });

  group('FTS uses buildFtsMatch', () {
    test('finds CJK title via 2-gram match expression', () async {
      await dao.upsertTask(taskRow('cn', title: '需求文档'), const []);
      final ids = await compiler.ftsTaskIds(const TaskQuery(keyword: '需求文档'));
      expect(ids, {'cn'});
    });
  });
}
