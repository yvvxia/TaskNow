import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/models/project.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/data/db/app_database.dart';
import 'package:plan_list/data/repositories/drift_project_repository.dart';
import 'package:plan_list/data/repositories/drift_task_repository.dart';

void main() {
  late AppDatabase db;
  late DriftProjectRepository repo;
  final fixedNow = DateTime.utc(2026, 6, 15);

  setUp(() {
    db = newTestDb();
    repo = DriftProjectRepository(db, now: () => fixedNow);
  });
  tearDown(() => db.close());

  test('getAll includes the seeded Inbox project', () async {
    final res = await repo.getAll();
    expect(res.valueOrNull!.map((p) => p.id), contains(kInboxProjectId));
  });

  test('create persists a project', () async {
    final res = await repo.create('Work', color: '#1976D2');
    expect(res.isOk, isTrue);
    final created = res.valueOrNull!;
    expect(created.name, 'Work');
    expect(created.createdAt, fixedNow);

    final all = await repo.getAll();
    expect(all.valueOrNull!.map((p) => p.name), contains('Work'));
  });

  test('update changes name and bumps updatedAt', () async {
    final created = (await repo.create('Old')).valueOrNull!;
    final res = await repo.update(created.copyWith(name: 'New'));
    expect(res.isOk, isTrue);
    final reloaded = (await repo.getAll())
        .valueOrNull!
        .firstWhere((p) => p.id == created.id);
    expect(reloaded.name, 'New');
  });

  test('delete with moveToInbox reassigns tasks then soft-deletes', () async {
    final project = (await repo.create('Temp')).valueOrNull!;
    final taskRepo = DriftTaskRepository(db, now: () => fixedNow);
    final task = (await taskRepo.create(
      TaskDraft(title: 'orphan', projectId: project.id),
    ))
        .valueOrNull!;

    final res = await repo.delete(project.id, mode: ProjectDeleteMode.moveToInbox);
    expect(res.isOk, isTrue);

    final all = await repo.getAll();
    expect(all.valueOrNull!.map((p) => p.id), isNot(contains(project.id)));

    final reloaded = (await taskRepo.findById(task.id)).valueOrNull!;
    expect(reloaded.projectId, kInboxProjectId);
  });

  test('delete with deleteTasks soft-deletes the project tasks too', () async {
    final project = (await repo.create('Temp')).valueOrNull!;
    final taskRepo = DriftTaskRepository(db, now: () => fixedNow);
    final task = (await taskRepo.create(
      TaskDraft(title: 'gone', projectId: project.id),
    ))
        .valueOrNull!;

    await repo.delete(project.id, mode: ProjectDeleteMode.deleteTasks);
    expect((await taskRepo.findById(task.id)).valueOrNull, isNull);
  });

  test('delete returns NotFound for an unknown id', () async {
    final res =
        await repo.delete('ghost', mode: ProjectDeleteMode.moveToInbox);
    expect(res.errorOrNull, isA<NotFoundException>());
  });

  test('watchAll emits after a create', () async {
    final expectation = expectLater(
      repo.watchAll(),
      emitsThrough(
        predicate<List<Project>>((list) => list.any((p) => p.name == 'Live')),
      ),
    );
    await repo.create('Live');
    await expectation;
  });
}
