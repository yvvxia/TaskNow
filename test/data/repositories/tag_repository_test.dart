import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/models/tag.dart';
import 'package:plan_list/data/db/app_database.dart';
import 'package:plan_list/data/repositories/drift_tag_repository.dart';

void main() {
  late AppDatabase db;
  late DriftTagRepository repo;

  setUp(() {
    db = newTestDb();
    repo = DriftTagRepository(db);
  });
  tearDown(() => db.close());

  test('create then getAll returns the tag', () async {
    final res = await repo.create('urgent', color: '#E53935');
    expect(res.isOk, isTrue);
    final all = await repo.getAll();
    expect(all.valueOrNull!.map((t) => t.name), contains('urgent'));
  });

  test(
    'duplicate tag name violates UNIQUE and yields a persistence error',
    () async {
      await repo.create('dup');
      final res = await repo.create('dup');
      expect(res.errorOrNull, isA<PersistenceException>());
    },
  );

  test('delete removes the tag', () async {
    final tag = (await repo.create('temp')).valueOrNull!;
    final res = await repo.delete(tag.id);
    expect(res.isOk, isTrue);
    final all = await repo.getAll();
    expect(all.valueOrNull!.map((t) => t.id), isNot(contains(tag.id)));
  });

  test('watchAll emits after a create', () async {
    final expectation = expectLater(
      repo.watchAll(),
      emitsThrough(
        predicate<List<Tag>>((list) => list.any((t) => t.name == 'live')),
      ),
    );
    await repo.create('live');
    await expectation;
  });
}
