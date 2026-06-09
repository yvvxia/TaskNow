import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/models/task_query.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';

import '../builders/seed_data.dart';

/// Performance / regression smoke tests over a 1000-task dataset on the real
/// in-memory database (`design/07-testing-strategy.md` §8). These guard against
/// accidental O(n^2) regressions in the query path; the generous budgets keep
/// them stable across CI hardware.
void main() {
  late AppDatabase db;
  late DriftTaskRepository repo;

  setUp(() async {
    db = newTestDb();
    repo = DriftTaskRepository(db, now: () => DateTime.utc(2026, 1, 1));
    await seedTasks(repo, count: 1000);
  });
  tearDown(() => db.close());

  test('seeds 1000 tasks', () async {
    final all = await repo.query(const TaskQuery());
    expect((all as Ok).value, hasLength(1000));
  });

  test('month-view range query completes well under 2s', () async {
    final range = DateTimeRange(
      start: DateTime.utc(2026, 2, 1),
      end: DateTime.utc(2026, 2, 28, 23, 59, 59),
    );

    final sw = Stopwatch()..start();
    final result = await repo.findInRange(range);
    sw.stop();

    expect(result.isOk, isTrue);
    expect((result as Ok).value, isNotEmpty);
    expect(
      sw.elapsedMilliseconds,
      lessThan(2000),
      reason: 'month-view range query took ${sw.elapsedMilliseconds}ms',
    );
  });

  test('repeated list queries stay fast (no per-call degradation)', () async {
    final sw = Stopwatch()..start();
    for (var i = 0; i < 20; i++) {
      final res = await repo.query(const TaskQuery());
      expect(res.isOk, isTrue);
    }
    sw.stop();

    expect(
      sw.elapsedMilliseconds,
      lessThan(2000),
      reason: '20 full-list queries took ${sw.elapsedMilliseconds}ms',
    );
  });
}
