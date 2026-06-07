import '../models/tag.dart';
import '../utils/result.dart';

/// Tag repository contract.
abstract interface class ITagRepository {
  Future<Result<List<Tag>>> getAll();

  Future<Result<Tag>> create(String name, {String? color});

  Future<Result<void>> delete(String id);

  Stream<List<Tag>> watchAll();
}
