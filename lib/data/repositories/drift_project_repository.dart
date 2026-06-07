import '../../core/contracts/i_project_repository.dart';
import '../../core/enums/enums.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/project.dart';
import '../../core/utils/result.dart';
import '../db/app_database.dart';
import '../db/project_dao.dart';
import '../mappers/project_mapper.dart';
import '../mappers/time_mapper.dart';

/// Drift-backed implementation of [IProjectRepository].
class DriftProjectRepository implements IProjectRepository {
  DriftProjectRepository(AppDatabase db, {DateTime Function()? now})
      : _dao = db.projectDao,
        _now = now ?? DateTime.now;

  final ProjectDao _dao;
  final DateTime Function() _now;

  @override
  Future<Result<List<Project>>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return Ok(rows.map(ProjectMapper.toEntity).toList());
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<Project>> create(String name, {String? color}) async {
    try {
      final nowUtc = _now().toUtc();
      final project = Project(
        id: kUuid.v4(),
        name: name,
        color: color,
        createdAt: nowUtc,
        updatedAt: nowUtc,
      );
      await _dao.upsert(ProjectMapper.toRow(project));
      return Ok(project);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<Project>> update(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: _now().toUtc());
      await _dao.upsert(ProjectMapper.toRow(updated));
      return Ok(updated);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Future<Result<void>> delete(
    String id, {
    required ProjectDeleteMode mode,
  }) async {
    try {
      final existing = await _dao.findById(id);
      if (existing == null) {
        return const Err(NotFoundException());
      }
      await _dao.softDelete(
        id,
        _now().msUtc,
        deleteTasks: mode == ProjectDeleteMode.deleteTasks,
        reassignTasksTo:
            mode == ProjectDeleteMode.moveToInbox ? kInboxProjectId : null,
      );
      return const Ok<void>(null);
    } on Object catch (_) {
      return const Err(PersistenceException());
    }
  }

  @override
  Stream<List<Project>> watchAll() {
    return _dao.watchAll().map(
          (rows) => rows.map(ProjectMapper.toEntity).toList(),
        );
  }
}
