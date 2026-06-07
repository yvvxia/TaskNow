import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import 'task_view.dart';

/// A single row in the task list showing checkbox, title, priority dot,
/// date range and subtask badge. Supports long-press for multi-select mode
/// and (on narrow viewports) left-swipe to complete.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.onComplete,
    this.onTap,
    this.isSelected = false,
    this.onLongPress,
  });

  final TaskView task;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final bool isSelected;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue && !task.isCompleted;

    return Dismissible(
      key: Key('dismissible-${task.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: theme.colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(Icons.check, color: theme.colorScheme.onPrimary),
      ),
      confirmDismiss: (_) async {
        onComplete?.call();
        return false; // Never actually dismiss – the repo drives removal.
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
              Text(
                task.subtaskBadge,
                style: theme.textTheme.labelSmall,
              ),
            const SizedBox(width: 6),
            _PriorityDot(priority: task.priority),
          ],
        ),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, bool isOverdue) {
    if (task.dateRangeLabel.isEmpty) return null;
    return Text(
      task.dateRangeLabel,
      style: TextStyle(
        color: isOverdue ? Colors.red : null,
        fontSize: 12,
      ),
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
