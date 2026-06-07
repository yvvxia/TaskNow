import 'package:flutter/material.dart' show DateTimeRange;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';
import '../enums/status_filter.dart';
import 'date_filter.dart';

part 'task_query.freezed.dart';

/// Query specification for list/search/calendar reads.
///
/// Module 04 extends this with richer filtering while keeping legacy fields
/// (`text`, [TaskStatus], single [priority]/[projectId]) used by module 02
/// list scopes.
@freezed
abstract class TaskQuery with _$TaskQuery {
  const TaskQuery._();

  const factory TaskQuery({
    // --- Module 04 (search) -------------------------------------------------
    String? keyword,
    DateFilter? dateFilter,
    @Default(StatusFilter.all) StatusFilter statusFilter,
    Set<Priority>? priorities,
    @Default(<String>{}) Set<String> projectIds,
    @Default(true) bool includeCompleted,
    @Default(false) bool includeDeleted,

    // --- Legacy module 02 fields --------------------------------------------
    String? text,
    TaskStatus? status,
    Priority? priority,
    String? projectId,
    @Default(<String>[]) List<String> tagIds,
    @Default(TaskSort.dueDate) TaskSort sort,
  }) = _TaskQuery;

  /// Range-overlap query for calendar & Gantt views.
  factory TaskQuery.rangeOverlap(DateTimeRange range) => TaskQuery(
        dateFilter: DateFilter.overlap(range),
        includeCompleted: true,
      );

  /// Keyword for FTS, preferring [keyword] then legacy [text].
  String? get effectiveKeyword {
    final raw = keyword ?? text;
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Tag ids from either the legacy list or an empty default.
  Set<String> get effectiveTagIds => tagIds.toSet();

  /// Project ids from [projectIds] and/or legacy [projectId].
  Set<String> get effectiveProjectIds {
    if (projectIds.isNotEmpty) return projectIds;
    if (projectId != null) return {projectId!};
    return const {};
  }

  /// Priority filter: multi-select or legacy single value.
  Set<Priority>? get effectivePriorities {
    if (priorities != null && priorities!.isNotEmpty) return priorities;
    if (priority != null) return {priority!};
    return null;
  }

  /// Resolves legacy [status] to [StatusFilter] when present.
  StatusFilter get effectiveStatusFilter {
    if (status != null) {
      return switch (status!) {
        TaskStatus.incomplete => StatusFilter.incomplete,
        TaskStatus.complete => StatusFilter.complete,
        TaskStatus.overdue => StatusFilter.overdue,
      };
    }
    return statusFilter;
  }
}
