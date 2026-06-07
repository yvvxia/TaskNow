import 'package:plan_list/core/contracts/i_tag_repository.dart';
import 'package:plan_list/core/models/tag.dart';
import 'package:plan_list/core/utils/result.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// In-memory [ITagRepository] for tests.
class FakeTagRepository implements ITagRepository {
  final List<Tag> _items = [];

  void seed(List<Tag> tags) {
    _items
      ..clear()
      ..addAll(tags);
  }

  @override
  Future<Result<List<Tag>>> getAll() async => Ok(List.from(_items));

  @override
  Future<Result<Tag>> create(String name, {String? color}) async {
    final t = Tag(id: _uuid.v4(), name: name, color: color);
    _items.add(t);
    return Ok(t);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
    return const Ok(null);
  }

  @override
  Stream<List<Tag>> watchAll() => const Stream.empty();
}
