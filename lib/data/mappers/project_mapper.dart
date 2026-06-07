import '../../core/models/project.dart';
import '../db/app_database.dart';
import 'time_mapper.dart';

/// Pure, bidirectional mapping between [ProjectRow] and [Project].
abstract final class ProjectMapper {
  static Project toEntity(ProjectRow row) {
    return Project(
      id: row.id,
      name: row.name,
      color: row.color,
      sortOrder: row.sortOrder,
      createdAt: dateTimeFromUtcMs(row.createdAt),
      updatedAt: dateTimeFromUtcMs(row.updatedAt),
      deletedAt: dateTimeFromUtcMsOrNull(row.deletedAt),
      syncVersion: row.syncVersion,
      deviceId: row.deviceId,
    );
  }

  static ProjectRow toRow(Project project) {
    return ProjectRow(
      id: project.id,
      name: project.name,
      color: project.color,
      sortOrder: project.sortOrder,
      createdAt: project.createdAt?.msUtc ?? 0,
      updatedAt: project.updatedAt?.msUtc ?? project.createdAt?.msUtc ?? 0,
      deletedAt: project.deletedAt.msUtcOrNull,
      syncVersion: project.syncVersion,
      deviceId: project.deviceId,
    );
  }
}
