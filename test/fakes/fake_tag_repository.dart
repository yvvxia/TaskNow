import 'dart:async';

import 'package:liveline/core/contracts/i_tag_repository.dart';
import 'package:liveline/core/models/tag.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// In-memory [ITagRepository] for tests.
class FakeTagRepository implements ITagRepository {
  final List<Tag> _items = [];
  final _controller = StreamController<List<Tag>>.broadcast();

  void seed(List<Tag> tags) {
    _items
      ..clear()
      ..addAll(tags);
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<Result<List<Tag>>> getAll() async => Ok(List.from(_items));

  @override
  Future<Result<Tag>> create(String name, {String? color}) async {
    final t = Tag(id: _uuid.v4(), name: name, color: color);
    _items.add(t);
    _emit();
    return Ok(t);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
    _emit();
    return const Ok(null);
  }

  @override
  Stream<List<Tag>> watchAll() {
    Future.microtask(_emit);
    return _controller.stream;
  }
}
