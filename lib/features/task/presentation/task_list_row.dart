import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/semantic_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'task_view.dart';

/// Shared task row styled per design-system (Todoist one-line + priority badge).
class TaskListRow extends StatelessWidget {
  const TaskListRow({
    super.key,
    required this.task,
    this.onComplete,
    this.onTap,
    this.isSelected = false,
    this.showCheckbox = true,
  });

  final TaskView task;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = SemanticColors.paletteOf(context);
    final brightness = Theme.of(context).brightness;
    final isOverdue = task.isOverdue && !task.isCompleted;

    return Material(
      color: isSelected
          ? palette.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.taskRowMinHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.outline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showCheckbox)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    key: Key('checkbox-${task.id}'),
                    value: task.isCompleted,
                    onChanged: onComplete == null ? null : (_) => onComplete!(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (showCheckbox) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? SemanticPalette.forBrightness(brightness).complete
                            : palette.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.dateRangeLabel.isNotEmpty ||
                        task.subtaskBadge.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (task.dateRangeLabel.isNotEmpty)
                            Text(
                              task.dateRangeLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isOverdue
                                        ? palette.priorityHigh
                                        : palette.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                            ),
                          if (task.subtaskBadge.isNotEmpty) ...[
                            if (task.dateRangeLabel.isNotEmpty)
                              Text(
                                ' · ',
                                style: TextStyle(
                                  color: palette.onSurfaceVariant,
                                ),
                              ),
                            Text(
                              _subtaskLabel(l10n, task),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isOverdue) ...[
                _OverdueBadge(l10n: l10n),
                const SizedBox(width: AppSpacing.xs),
              ],
              _PriorityBadge(priority: task.priority),
            ],
          ),
        ),
      ),
    );
  }

  String _subtaskLabel(AppLocalizations? l10n, TaskView task) {
    final parts = task.subtaskBadge.split('/');
    if (parts.length == 2) {
      final total = int.tryParse(parts[1]) ?? 0;
      if (total > 0) {
        return l10n?.subtaskCount(total) ?? '$total subtasks';
      }
    }
    return task.subtaskBadge;
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final color = SemanticColors.colorForPriority(
      priority,
      brightness: brightness,
    );
    final label = switch (priority) {
      Priority.high => l10n?.priorityHigh ?? 'High',
      Priority.medium => l10n?.priorityMedium ?? 'Medium',
      Priority.low => l10n?.priorityLow ?? 'Low',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: SemanticColors.badgeBackgroundForPriority(
              priority,
              brightness: brightness,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge({this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final palette = SemanticColors.paletteOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: palette.overdue,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        l10n?.taskOverdue ?? 'Overdue',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: palette.overdueOn),
      ),
    );
  }
}
