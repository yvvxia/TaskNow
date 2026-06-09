import 'package:flutter/material.dart';

import 'task_list_row.dart';
import 'task_view.dart';

/// A single row in the task list with swipe actions wrapping [TaskListRow].
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
  final VoidCallback? onComplete;
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
          return false;
        }
        onDelete?.call();
        return false;
      },
      child: GestureDetector(
        onLongPress: onLongPress,
        child: TaskListRow(
          task: task,
          isSelected: isSelected,
          onComplete: onComplete,
          onTap: onTap,
        ),
      ),
    );
  }
}
