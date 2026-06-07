import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/core/models/task_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_task_repository.dart';

void main() {
  late FakeTaskRepository repo;

  setUp(() => repo = FakeTaskRepository());
  tearDown(() => repo.dispose());

  test(
    'watch emits the current snapshot immediately on subscription',
    () async {
      final first = await repo.watch(const TaskQuery()).first;
      expect(first, isEmpty);
    },
  );

  test('watch emits again on every write', () async {
    final emissions = <int>[];
    final sub = repo
        .watch(const TaskQuery())
        .listen((tasks) => emissions.add(tasks.length));

    await repo.create(const TaskDraft(title: 'A'));
    await repo.create(const TaskDraft(title: 'B'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // Initial snapshot (0) + one emission per create (1, then 2).
    expect(emissions, containsAllInOrder(<int>[0, 1, 2]));
  });

  test('watch filters by query status/project', () async {
    final created = await repo.create(
      const TaskDraft(title: 'Inbox', projectId: 'p1'),
    );
    expect(created.isOk, isTrue);

    final filtered = await repo.watch(const TaskQuery(projectId: 'p2')).first;
    expect(filtered, isEmpty);

    final matching = await repo.watch(const TaskQuery(projectId: 'p1')).first;
    expect(matching, hasLength(1));
  });

  test('seed populates without emitting on the stream', () async {
    final emissions = <int>[];
    final sub = repo
        .watch(const TaskQuery())
        .listen((tasks) => emissions.add(tasks.length));
    await Future<void>.delayed(Duration.zero);

    repo.seed([]);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // Only the initial subscription snapshot, no event from seed().
    expect(emissions, <int>[0]);
  });
}
