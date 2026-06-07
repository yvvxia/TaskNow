import '../../core/contracts/i_tag_repository.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/tag.dart';
import '../../core/utils/result.dart';
import '../db/app_database.dart';
import '../db/tag_dao.dart';
import '../mappers/tag_mapper.dart';

/// Drift-backed implementation of [ITagRepository].
class DriftTagRepository implements ITagRepository {
  DriftTagRepository(AppDatabase db) : _dao = db.tagDao;

  final TagDao _dao;

  @override
  Future<Result<List<Tag>>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return Ok(rows.map(TagMapper.toEntity).toList());
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<Tag>> create(String name, {String? color}) async {
    try {
      final tag = Tag(id: kUuid.v4(), name: name, color: color);
      await _dao.upsert(TagMapper.toRow(tag));
      return Ok(tag);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dao.deleteById(id);
      return const Ok<void>(null);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Stream<List<Tag>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(TagMapper.toEntity).toList());
  }
}
