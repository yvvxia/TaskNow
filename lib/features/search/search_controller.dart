import 'dart:async';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/enums/enums.dart';
import '../../core/enums/status_filter.dart';
import '../../core/models/date_filter.dart';
import '../../core/models/task_query.dart';

part 'search_controller.g.dart';

/// Holds the active [TaskQuery] for the search screen with debounced keyword
/// input.
@Riverpod(keepAlive: true)
class SearchController extends _$SearchController {
  Timer? _debounce;

  @override
  TaskQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const TaskQuery(includeCompleted: false);
  }

  void setKeyword(String kw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(keyword: kw.isEmpty ? null : kw);
    });
  }

  void flushKeyword() {
    _debounce?.cancel();
    _debounce = null;
  }

  void setStatus(StatusFilter status) {
    state = state.copyWith(statusFilter: status, status: null);
  }

  void toggleTag(String id) {
    final tags = Set<String>.from(state.tagIds);
    if (tags.contains(id)) {
      tags.remove(id);
    } else {
      tags.add(id);
    }
    state = state.copyWith(tagIds: tags.toList());
  }

  void setPriorities(Set<Priority> priorities) {
    state = state.copyWith(
      priorities: priorities.isEmpty ? null : priorities,
      priority: null,
    );
  }

  void togglePriority(Priority priority) {
    final current = Set<Priority>.from(state.effectivePriorities ?? {});
    if (current.contains(priority)) {
      current.remove(priority);
    } else {
      current.add(priority);
    }
    setPriorities(current);
  }

  void setDate(DateFilter? filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void setProjects(Set<String> projectIds) {
    state = state.copyWith(
      projectIds: projectIds,
      projectId: null,
    );
  }

  void toggleProject(String projectId) {
    final current = Set<String>.from(state.effectiveProjectIds);
    if (current.contains(projectId)) {
      current.remove(projectId);
    } else {
      current.add(projectId);
    }
    setProjects(current);
  }

  void setDateRange(DateTimeRange range) {
    setDate(DateFilter.range(range));
  }

  void clear() {
    _debounce?.cancel();
    _debounce = null;
    state = const TaskQuery(includeCompleted: false);
  }
}
