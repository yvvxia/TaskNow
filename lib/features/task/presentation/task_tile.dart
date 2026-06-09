import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import 'task_view.dart';

/// A single row in the task list showing checkbox, title, priority dot,
/// date range and subtask badge. Supports long-press for multi-select mode,
/// swipe-right to toggle completion and swipe-left to delete.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.onComplete,
    this.onDelete,
    this.onTap,
    this.isSelected = false,
    this.onLongPress,
  });

  final TaskView task;

  /// Invoked to toggle the task between complete and incomplete.
  final VoidCallback? onComplete;

  /// Invoked to permanently remove the task. When null, swipe-to-delete and
  /// the inline delete button are disabled.
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onLongPress;

  DismissDirection get _dismissDirection {
    if (onComplete != null && onDelete != null) {
      return DismissDirection.horizontal;
    }
    if (onComplete != null) return DismissDirection.startToEnd;
    if (onDelete != null) return DismissDirection.endToStart;
    return DismissDirection.none;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue && !task.isCompleted;

    return Dismissible(
      key: Key('dismissible-${task.id}'),
      direction: _dismissDirection,
      background: Container(
        color: theme.colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          task.isCompleted ? Icons.undo : Icons.check,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
          return false; // Completion is a state change, not a removal.
        }
        // endToStart → delete. Let the row dismiss; the repo drives removal.
        onDelete?.call();
        return false;
      },
      child: ListTile(
        selected: isSelected,
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Checkbox(
          key: Key('checkbox-${task.id}'),
          value: task.isCompleted,
          onChanged: (_) => onComplete?.call(),
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: _buildSubtitle(context, isOverdue),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.subtaskBadge.isNotEmpty)
              Text(task.subtaskBadge, style: theme.textTheme.labelSmall),
            const SizedBox(width: 6),
            _PriorityDot(priority: task.priority),
            if (onDelete != null)
              IconButton(
                key: Key('delete-${task.id}'),
                icon: const Icon(Icons.delete_outline),
                visualDensity: VisualDensity.compact,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, bool isOverdue) {
    if (task.dateRangeLabel.isEmpty) return null;
    return Text(
      task.dateRangeLabel,
      style: TextStyle(color: isOverdue ? Colors.red : null, fontSize: 12),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _color(priority),
        shape: BoxShape.circle,
      ),
    );
  }

  static Color _color(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.grey;
    }
  }
}
