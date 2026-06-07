import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../../data/search/fts_tokenizer.dart';
import '../../task/presentation/task_view.dart';

/// Scrollable search results with optional keyword highlight in titles.
class ResultList extends StatelessWidget {
  const ResultList({
    super.key,
    required this.tasks,
    this.keyword,
    this.onTaskTap,
    this.onComplete,
  });

  final List<TaskView> tasks;
  final String? keyword;
  final ValueChanged<String>? onTaskTap;
  final ValueChanged<String>? onComplete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('search-result-list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _SearchResultTile(
          key: Key('search-result-${task.id}'),
          task: task,
          keyword: keyword,
          onTap: onTaskTap == null ? null : () => onTaskTap!(task.id),
          onComplete:
              onComplete == null ? null : () => onComplete!(task.id),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    super.key,
    required this.task,
    this.keyword,
    this.onTap,
    this.onComplete,
  });

  final TaskView task;
  final String? keyword;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue && !task.isCompleted;
    final highlightStyle = theme.textTheme.bodyLarge?.copyWith(
      backgroundColor: theme.colorScheme.primaryContainer,
      fontWeight: FontWeight.bold,
    );
    final baseStyle = task.isCompleted
        ? theme.textTheme.bodyLarge?.copyWith(
            decoration: TextDecoration.lineThrough,
          )
        : theme.textTheme.bodyLarge;

    final title = (keyword != null && keyword!.trim().isNotEmpty)
        ? RichText(
            text: TextSpan(
              style: baseStyle,
              children: buildHighlightSpans(
                task.title,
                keyword,
                spanBuilder: (segment, {required isMatch}) => TextSpan(
                  text: segment,
                  style: isMatch ? highlightStyle : null,
                ),
              ),
            ),
          )
        : Text(task.title, style: baseStyle);

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
        return false;
      },
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          key: Key('checkbox-${task.id}'),
          value: task.isCompleted,
          onChanged: (_) => onComplete?.call(),
        ),
        title: title,
        subtitle: _buildSubtitle(isOverdue),
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

  Widget? _buildSubtitle(bool isOverdue) {
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

/// Rich-text title with keyword highlighting for widget tests.
class HighlightedTitle extends StatelessWidget {
  const HighlightedTitle({
    super.key,
    required this.text,
    required this.keyword,
    this.baseStyle,
    this.highlightStyle,
  });

  final String text;
  final String keyword;
  final TextStyle? baseStyle;
  final TextStyle? highlightStyle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: buildHighlightSpans(
          text,
          keyword,
          spanBuilder: (segment, {required isMatch}) => TextSpan(
            text: segment,
            style: isMatch ? highlightStyle : null,
          ),
        ),
      ),
    );
  }
}
