import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// Project entity (list grouping for tasks).
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    String? color,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,

    // --- Sync-reserved fields (Phase 2). See proposal §4.4. ---
    DateTime? deletedAt,
    @Default(0) int syncVersion,
    String? deviceId,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}
