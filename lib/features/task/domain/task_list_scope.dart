import '../../../core/enums/enums.dart';
import '../../../core/models/task_query.dart';

/// Represents the current list context shown in [TaskListPage].
/// Each variant converts itself to a [TaskQuery] for the repository.
sealed class TaskListScope {
  const TaskListScope();

  TaskQuery toQuery();

  /// Human-readable label for this scope (used as page title).
  String get label;
}

/// All tasks owned by a specific project.
final class ProjectScope extends TaskListScope {
  const ProjectScope(this.projectId, {this.name = 'Project'});

  final String projectId;
  final String name;

  @override
  TaskQuery toQuery() => TaskQuery(projectId: projectId, sort: TaskSort.dueDate);

  @override
  String get label => name;

  @override
  bool operator ==(Object other) =>
      other is ProjectScope && other.projectId == projectId;

  @override
  int get hashCode => projectId.hashCode;
}

/// All tasks with a specific tag.
final class TagScope extends TaskListScope {
  const TagScope(this.tagId, {this.name = 'Tag'});

  final String tagId;
  final String name;

  @override
  TaskQuery toQuery() => TaskQuery(tagIds: [tagId], sort: TaskSort.dueDate);

  @override
  String get label => name;

  @override
  bool operator ==(Object other) =>
      other is TagScope && other.tagId == tagId;

  @override
  int get hashCode => tagId.hashCode;
}

/// Tasks due today (sort by due date; filtering is applied by the notifier).
final class TodayScope extends TaskListScope {
  const TodayScope();

  @override
  TaskQuery toQuery() => const TaskQuery(sort: TaskSort.dueDate);

  @override
  String get label => 'Today';

  @override
  bool operator ==(Object other) => other is TodayScope;

  @override
  int get hashCode => 0;
}

/// Incomplete tasks past their due date.
final class OverdueScope extends TaskListScope {
  const OverdueScope();

  @override
  TaskQuery toQuery() => const TaskQuery(status: TaskStatus.overdue);

  @override
  String get label => 'Overdue';

  @override
  bool operator ==(Object other) => other is OverdueScope;

  @override
  int get hashCode => 1;
}

/// Completed tasks.
final class CompletedScope extends TaskListScope {
  const CompletedScope();

  @override
  TaskQuery toQuery() => const TaskQuery(status: TaskStatus.complete);

  @override
  String get label => 'Completed';

  @override
  bool operator ==(Object other) => other is CompletedScope;

  @override
  int get hashCode => 2;
}

/// Tasks with no project (inbox).
final class InboxScope extends TaskListScope {
  const InboxScope();

  @override
  TaskQuery toQuery() => const TaskQuery(sort: TaskSort.createdAt);

  @override
  String get label => 'Inbox';

  @override
  bool operator ==(Object other) => other is InboxScope;

  @override
  int get hashCode => 3;
}

/// All non-deleted tasks.
final class AllScope extends TaskListScope {
  const AllScope();

  @override
  TaskQuery toQuery() => const TaskQuery(sort: TaskSort.dueDate);

  @override
  String get label => 'All Tasks';

  @override
  bool operator ==(Object other) => other is AllScope;

  @override
  int get hashCode => 4;
}
