import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'project_dao.g.dart';

/// Data-access object for projects.
@DriftAccessor(tables: [Projects, Tasks])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<List<ProjectRow>> getAll() {
    return (select(projects)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .get();
  }

  Stream<List<ProjectRow>> watchAll() {
    return (select(projects)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .watch();
  }

  Future<ProjectRow?> findById(String id) {
    return (select(
      projects,
    )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
  }

  Future<void> upsert(ProjectRow row) =>
      into(projects).insertOnConflictUpdate(row);

  /// Soft-deletes the project. When [reassignTasksTo] is provided, moves the
  /// project's tasks to that project; otherwise soft-deletes them.
  Future<void> softDelete(
    String id,
    int nowMs, {
    String? reassignTasksTo,
    bool deleteTasks = false,
  }) async {
    await transaction(() async {
      if (deleteTasks) {
        await (update(tasks)..where((t) => t.projectId.equals(id))).write(
          TasksCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
        );
      } else {
        await (update(tasks)..where((t) => t.projectId.equals(id))).write(
          TasksCompanion(
            projectId: Value(reassignTasksTo),
            updatedAt: Value(nowMs),
          ),
        );
      }
      await (update(projects)..where((p) => p.id.equals(id))).write(
        ProjectsCompanion(deletedAt: Value(nowMs), updatedAt: Value(nowMs)),
      );
    });
  }
}
