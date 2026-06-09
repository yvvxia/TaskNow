import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/task_draft.dart';
import '../../l10n/app_localizations.dart';
import 'domain/delete_task_usecase.dart';
import 'domain/task_list_scope.dart';
import 'presentation/add_task_sheet.dart';
import 'presentation/quick_add_bar.dart';
import 'presentation/task_list_notifier.dart';
import 'presentation/task_tile.dart';
import 'presentation/task_view.dart';
import 'task_providers.dart';

/// Main task list page. Adapts its input affordance to the viewport width:
/// - Desktop (≥ 600 dp): top [QuickAddBar] + Enter to create.
/// - Mobile (< 600 dp): FAB + bottom modal sheet for quick add.
///
/// Handles the case where no [ProviderScope] exists in the widget tree (used
/// by legacy integration tests) by rendering an empty body with the required
/// key.
class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key, this.scope, this.embedded = false});

  final TaskListScope? scope;

  /// When true the page omits its own [Scaffold]/[AppBar] so it can be hosted
  /// inside another page (e.g. a project detail tab).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    // Guard: if there's no ProviderScope in the tree (e.g. legacy router
    // tests), render a minimal shell with the expected key so tests can still
    // find the widget.
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    final effectiveScope = scope ?? const AllScope();
    final content = hasScope
        ? _TaskListContent(scope: effectiveScope, embedded: embedded)
        : const SizedBox.shrink();

    if (embedded) return content;
    return Scaffold(key: const Key('tasks-page'), body: content);
  }
}

class _TaskListContent extends ConsumerStatefulWidget {
  const _TaskListContent({required this.scope, this.embedded = false});

  final TaskListScope scope;
  final bool embedded;

  @override
  ConsumerState<_TaskListContent> createState() => _TaskListContentState();
}

class _TaskListContentState extends ConsumerState<_TaskListContent> {
  /// Project id derived from the current scope, so quick-add creates the task
  /// in the project being viewed (null = no project context → picker shown).
  String? get _scopeProjectId {
    final scope = widget.scope;
    return scope is ProjectScope ? scope.projectId : null;
  }

  Future<void> _quickAdd(String title) async {
    await _createDraft(TaskDraft(title: title, projectId: _scopeProjectId));
  }

  Future<void> _createDraft(TaskDraft draft) async {
    await ref.read(createTaskUseCaseProvider).call(draft);
  }

  void _openAddSheet(BuildContext context) {
    showAddTaskSheet(
      context,
      onCreate: _createDraft,
      projectId: _scopeProjectId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tasksState = ref.watch(taskListProvider(widget.scope));
    final isWide = MediaQuery.of(context).size.width >= 600;
    final notifier = ref.read(taskListProvider(widget.scope).notifier);

    final title = widget.scope is AllScope
        ? (l10n?.tasksTitle ?? widget.scope.label)
        : widget.scope.label;

    // Embedded inside a project tab: an always-present quick-add row plus the
    // list, with no Scaffold/AppBar of its own.
    final selectionActions = <Widget>[
      if (notifier.selectedIds.isNotEmpty) ...[
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: l10n?.actionComplete ?? 'Complete',
          onPressed: notifier.completeSelected,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: l10n?.actionDelete ?? 'Delete',
          onPressed: notifier.deleteSelected,
        ),
      ],
    ];

    final showQuickAdd = isWide || widget.embedded;
    final body = Column(
      children: [
        if (widget.embedded && selectionActions.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: selectionActions,
            ),
          ),
        if (showQuickAdd)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(child: QuickAddBar(onSubmit: _quickAdd)),
                IconButton.filledTonal(
                  icon: const Icon(Icons.more_time),
                  tooltip: l10n?.newTaskWithTime ?? 'New task with date & time',
                  onPressed: () => _openAddSheet(context),
                ),
              ],
            ),
          ),
        Expanded(
          child: tasksState.when(
            data: (tasks) => _TaskListView(tasks: tasks, notifier: notifier),
            loading: () => const SizedBox.shrink(),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: selectionActions),
      body: body,
      floatingActionButton: isWide
          ? null
          : FloatingActionButton(
              onPressed: () => _openAddSheet(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView({required this.tasks, required this.notifier});

  final List<TaskView> tasks;
  final TaskListNotifier notifier;

  Future<void> _confirmDelete(BuildContext context, TaskView task) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.deleteTaskTitle ?? 'Delete task?'),
        content: Text(
          l10n?.deleteTaskMessage(task.title) ??
              'This will permanently remove "${task.title}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await notifier.delete(task.id, DeleteScope.thisOnly);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(child: Text(l10n?.emptyTaskList ?? 'No tasks here'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = notifier.selectedIds.contains(task.id);
        return TaskTile(
          key: Key('task-tile-${task.id}'),
          task: task,
          isSelected: isSelected,
          onTap: () => context.go('/task/${task.id}'),
          onComplete: () => notifier.toggleComplete(task),
          onDelete: () => _confirmDelete(context, task),
          onLongPress: () => notifier.toggleSelect(task.id),
        );
      },
    );
  }
}
