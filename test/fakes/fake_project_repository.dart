import 'dart:async';

import 'package:plan_list/core/contracts/i_project_repository.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/models/project.dart';
import 'package:plan_list/core/utils/result.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// In-memory [IProjectRepository] for tests. Emits on every mutation so
/// [watchAll] subscribers behave like the real Drift-backed stream.
class FakeProjectRepository implements IProjectRepository {
  final List<Project> _items = [];
  final _controller = StreamController<List<Project>>.broadcast();

  void seed(List<Project> projects) {
    _items
      ..clear()
      ..addAll(projects);
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<Result<List<Project>>> getAll() async => Ok(List.from(_items));

  @override
  Future<Result<Project>> create(String name, {String? color}) async {
    final p = Project(id: _uuid.v4(), name: name, color: color);
    _items.add(p);
    _emit();
    return Ok(p);
  }

  @override
  Future<Result<Project>> update(Project project) async {
    final idx = _items.indexWhere((p) => p.id == project.id);
    if (idx == -1) return const Err(NotFoundException());
    _items[idx] = project;
    _emit();
    return Ok(project);
  }

  @override
  Future<Result<void>> delete(
    String id, {
    required ProjectDeleteMode mode,
  }) async {
    _items.removeWhere((p) => p.id == id);
    _emit();
    return const Ok(null);
  }

  @override
  Stream<List<Project>> watchAll() async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }
}
