import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/errors/app_exception.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/core/models/task_draft.dart';
import 'package:liveline/core/models/task_query.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTaskRepository repo;
  final fixedNow = DateTime.utc(2026, 6, 15, 10);

  setUp(() {
    db = newTestDb();
    repo = DriftTaskRepository(db, now: () => fixedNow);
  });
  tearDown(() => db.close());

  Future<Task> create(String title, {DateTime? start, DateTime? due}) async {
    final res = await repo.create(
      TaskDraft(title: title, startDate: start, dueDate: due),
    );
    return (res as Ok<Task>).value;
  }

  test('create persists a task with a generated id and timestamps', () async {
    final res = await repo.create(const TaskDraft(title: 'First'));
    expect(res.isOk, isTrue);
    final task = res.valueOrNull!;
    expect(task.id, isNotEmpty);
    expect(task.createdAt, fixedNow);
    expect(task.updatedAt, fixedNow);

    final found = await repo.findById(task.id);
    expect(found.valueOrNull!.title, 'First');
  });

  test('update persists changes and bumps updatedAt', () async {
    final task = await create('Old');
    final later = DriftTaskRepository(db, now: () => DateTime.utc(2026, 6, 16));
    final res = await later.update(
      task.copyWith(title: 'New', priority: Priority.high),
    );
    expect(res.isOk, isTrue);
    final found = await repo.findById(task.id);
    expect(found.valueOrNull!.title, 'New');
    expect(found.valueOrNull!.priority, Priority.high);
    expect(res.valueOrNull!.updatedAt, DateTime.utc(2026, 6, 16));
  });

  test('findById returns Ok(null) for unknown id', () async {
    final res = await repo.findById('nope');
    expect(res.isOk, isTrue);
    expect(res.valueOrNull, isNull);
  });

  test('delete soft-deletes and hides the task from reads', () async {
    final task = await create('Doomed');
    final res = await repo.delete(task.id, entireSeries: false);
    expect(res.isOk, isTrue);

    expect((await repo.findById(task.id)).valueOrNull, isNull);
    final all = await repo.query(const TaskQuery());
    expect(all.valueOrNull!.map((t) => t.id), isNot(contains(task.id)));
  });

  test('delete returns NotFound for an unknown id', () async {
    final res = await repo.delete('ghost', entireSeries: false);
    expect(res.errorOrNull, isA<NotFoundException>());
  });

  test('findInRange returns only intersecting tasks', () async {
    final inside = await create(
      'inside',
      start: DateTime.utc(2026, 6, 3),
      due: DateTime.utc(2026, 6, 4),
    );
    await create(
      'outside',
      start: DateTime.utc(2026, 7, 1),
      due: DateTime.utc(2026, 7, 2),
    );

    final res = await repo.findInRange(
      DateTimeRange(
        start: DateTime.utc(2026, 6, 1),
        end: DateTime.utc(2026, 6, 30),
      ),
    );
    expect(res.valueOrNull!.map((t) => t.id), {inside.id});
  });

  test('query with text uses FTS over title and notes', () async {
    await repo.create(const TaskDraft(title: 'Buy milk', notes: 'grocery'));
    await repo.create(const TaskDraft(title: 'Walk dog'));
    final res = await repo.query(const TaskQuery(text: 'milk'));
    expect(res.valueOrNull!.map((t) => t.title), {'Buy milk'});
  });

  test('query composes linked tag ids', () async {
    await db.into(db.tags).insert(const TagRow(id: 'tg', name: 'home'));
    final task = await create('Tagged');
    await repo.update(task.copyWith(tagIds: const ['tg']));
    final res = await repo.query(const TaskQuery());
    final reloaded = res.valueOrNull!.firstWhere((t) => t.id == task.id);
    expect(reloaded.tagIds, const ['tg']);
  });

  test('watch emits an updated list after a write', () async {
    final stream = repo.watch(const TaskQuery());
    final expectation = expectLater(
      stream,
      emitsThrough(predicate<List<Task>>((list) => list.length == 1)),
    );
    await repo.create(const TaskDraft(title: 'streamed'));
    await expectation;
  });
}
