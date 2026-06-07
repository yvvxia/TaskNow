import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'tag_dao.g.dart';

/// Data-access object for tags. Tags are hard-deleted (no soft-delete column);
/// the FK `ON DELETE CASCADE` removes their `task_tags` links.
@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<TagRow>> getAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Stream<List<TagRow>> watchAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<TagRow?> findById(String id) {
    return (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(TagRow row) => into(tags).insertOnConflictUpdate(row);

  Future<int> deleteById(String id) {
    return (delete(tags)..where((t) => t.id.equals(id))).go();
  }
}
