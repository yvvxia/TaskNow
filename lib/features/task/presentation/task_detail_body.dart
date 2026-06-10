import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/subtask.dart';
import '../../../core/models/task.dart';
import '../../../core/widgets/shell_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/delete_task_usecase.dart';
import '../domain/task_list_scope.dart';
import '../task_providers.dart';
import 'note_editor.dart';
import 'recurrence_picker.dart';
import 'tag_picker.dart';
import 'task_list_notifier.dart';

/// Shared detail body used by both [TaskDetailPage] (full-screen, mobile) and
/// [TaskDetailPanel] (right panel, desktop). Note-centric layout with tags,
/// subtasks, and a compact toolbar (dates / priority / more).
class TaskDetailBody extends ConsumerStatefulWidget {
  const TaskDetailBody({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailBody> createState() => _TaskDetailBodyState();
}

class _TaskDetailBodyState extends ConsumerState<TaskDetailBody> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  Task? _task;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _loadTask(Task task) {
    if (!_editing) {
      _titleCtrl.text = task.title;
      _notesCtrl.text = task.notes ?? '';
    }
    _task = task;
  }

  Future<void> _saveTitle() async {
    if (_task == null) return;
    final updated = _task!.copyWith(title: _titleCtrl.text.trim());
    await ref.read(updateTaskUseCaseProvider).call(updated);
  }

  Future<void> _saveNotes() async {
    if (_task == null) return;
    final updated = _task!.copyWith(notes: _notesCtrl.text.trim());
    await ref.read(updateTaskUseCaseProvider).call(updated);
  }

  Future<void> _updateTask(Task updated) async {
    await ref.read(updateTaskUseCaseProvider).call(updated);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.deleteTaskTitle ?? 'Delete task?'),
        content: Text(
          l10n?.deleteTaskGenericMessage ??
              'This will permanently remove the task.',
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
    if (!(confirmed ?? false)) return;

    await ref
        .read(deleteTaskUseCaseProvider)
        .call(widget.taskId, DeleteScope.thisOnly);

    if (!mounted) return;
    clearTaskDetailSelection(ref);
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) context.pop();
  }

  Future<void> _showDatesDialog(Task task) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.detailDatesDialogTitle ?? 'Dates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateTimeRow(
              label: l10n?.taskStartDate ?? 'Start date',
              dateTime: task.startDate,
              onChanged: (d) async {
                final updated = _task!.copyWith(startDate: d);
                await _updateTask(updated);
              },
            ),
            _DateTimeRow(
              label: l10n?.taskDueDate ?? 'Due date',
              dateTime: task.dueDate,
              onChanged: (d) async {
                final updated = _task!.copyWith(dueDate: d);
                await _updateTask(updated);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionSave ?? 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecurrenceDialog(Task task) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.detailMenuRecurrence ?? 'Recurrence'),
        content: SingleChildScrollView(
          child: RecurrencePicker(
            value: task.recurrence,
            onChanged: (rule) async {
              final updated = _task!.copyWith(recurrence: rule);
              await _updateTask(updated);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionSave ?? 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemindersDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.detailMenuReminders ?? 'Reminders'),
        content: Text(l10n?.remindersComingSoon ?? 'Reminders coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfoDialog(Task task) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.detailMenuInfo ?? 'Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.createdAt != null)
              Text(
                l10n?.detailCreated(
                      _formatMeta(context, task.createdAt!),
                    ) ??
                    'Created ${task.createdAt}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            if (task.completedAt != null)
              Text(
                l10n?.detailCompleted(
                      _formatMeta(context, task.completedAt!),
                    ) ??
                    'Completed ${task.completedAt}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n?.autoCompleteOnSubtasksLabel ??
                    'Auto-complete when all subtasks are done',
              ),
              value: task.autoCompleteOnSubtasks,
              onChanged: (v) async {
                final updated = _task!.copyWith(autoCompleteOnSubtasks: v);
                await _updateTask(updated);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionSave ?? 'Save'),
          ),
        ],
      ),
    );
  }

  void _onMoreMenuSelected(String value, Task task) {
    switch (value) {
      case 'recurrence':
        _showRecurrenceDialog(task);
      case 'reminders':
        _showRemindersDialog();
      case 'info':
        _showInfoDialog(task);
      case 'delete':
        _confirmDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allState = ref.watch(taskListProvider(const AllScope()));
    final task = allState.whenData(
      (list) => list.firstWhere(
        (v) => v.id == widget.taskId,
        orElse: () => list.isEmpty ? throw StateError('not found') : list.first,
      ),
    );

    final l10n = AppLocalizations.of(context);

    if (task.hasError || task.isLoading) {
      return Center(child: Text(l10n?.taskLoading ?? 'Loading…'));
    }

    final taskView = task.value;
    if (taskView == null) {
      return Center(child: Text(l10n?.taskNotFound ?? 'Task not found'));
    }

    _loadTask(taskView.task);

    final subtasks = taskView.task.subtasks;
    final doneCount = subtasks.where((s) => s.isDone).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: taskView.isCompleted,
                onChanged: (_) async {
                  await ref
                      .read(taskListProvider(const AllScope()).notifier)
                      .toggleComplete(taskView);
                },
              ),
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: InputDecoration(
                    hintText: l10n?.newTaskTitle ?? 'Task title',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() => _editing = true),
                  onSubmitted: (_) {
                    _editing = false;
                    _saveTitle();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                key: const Key('detail-dates-button'),
                onPressed: () => _showDatesDialog(taskView.task),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(l10n?.detailMenuDates ?? 'Dates'),
              ),
              DropdownButton<Priority>(
                key: const Key('detail-priority'),
                value: taskView.task.priority,
                underline: const SizedBox.shrink(),
                items: Priority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(_priorityLabel(l10n, p)),
                      ),
                    )
                    .toList(),
                onChanged: (p) async {
                  if (p == null) return;
                  final updated = _task!.copyWith(priority: p);
                  await _updateTask(updated);
                },
              ),
              PopupMenuButton<String>(
                key: const Key('detail-more-menu'),
                tooltip: l10n?.detailMoreMenu ?? 'More',
                icon: const Icon(Icons.more_vert),
                onSelected: (v) => _onMoreMenuSelected(v, taskView.task),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'recurrence',
                    child: ListTile(
                      leading: const Icon(Icons.repeat, size: 20),
                      title: Text(l10n?.detailMenuRecurrence ?? 'Recurrence'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reminders',
                    child: ListTile(
                      leading: const Icon(Icons.notifications_outlined, size: 20),
                      title: Text(l10n?.detailMenuReminders ?? 'Reminders'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'info',
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, size: 20),
                      title: Text(l10n?.detailMenuInfo ?? 'Info'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      key: const Key('detail-delete'),
                      leading: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(ctx).colorScheme.error,
                      ),
                      title: Text(
                        l10n?.detailMenuDelete ?? 'Delete task',
                        style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          TaskTagPicker(
            selectedTagIds: taskView.task.tagIds,
            onChanged: (ids) async {
              final updated = _task!.copyWith(tagIds: ids);
              await _updateTask(updated);
            },
          ),

          const SizedBox(height: 12),
          Expanded(
            child: NoteEditor(
              controller: _notesCtrl,
              onSave: () {
                _editing = false;
                _saveNotes();
              },
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n?.detailSectionSubtasks ?? 'Subtasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (subtasks.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  l10n?.subtaskProgress(doneCount, subtasks.length) ??
                      '$doneCount of ${subtasks.length} done',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          ..._buildSubtasks(context, subtasks),
          _AddSubtaskField(
            onAdd: (title) async {
              final newId = DateTime.now().microsecondsSinceEpoch.toString();
              final newSubtask = Subtask(id: newId, title: title);
              final updated = _task!.copyWith(
                subtasks: [..._task!.subtasks, newSubtask],
              );
              await _updateTask(updated);
            },
          ),
        ],
      ),
    );
  }

  String _formatMeta(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    return DateFormat.yMMMd(l10n?.localeName).add_Hm().format(dt.toLocal());
  }

  String _priorityLabel(AppLocalizations? l10n, Priority p) => switch (p) {
    Priority.high => l10n?.priorityHigh ?? 'High',
    Priority.medium => l10n?.priorityMedium ?? 'Medium',
    Priority.low => l10n?.priorityLow ?? 'Low',
  };

  List<Widget> _buildSubtasks(BuildContext context, List<Subtask> subtasks) {
    return subtasks.map((s) {
      return CheckboxListTile(
        key: Key('subtask-${s.id}'),
        title: Text(
          s.title,
          style: s.isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        value: s.isDone,
        onChanged: (_) async {
          if (_task == null) return;
          final updated = _task!.copyWith(
            subtasks: _task!.subtasks
                .map((x) => x.id == s.id ? x.copyWith(isDone: !x.isDone) : x)
                .toList(),
          );
          await _updateTask(updated);
        },
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () async {
            if (_task == null) return;
            final updated = _task!.copyWith(
              subtasks: _task!.subtasks.where((x) => x.id != s.id).toList(),
            );
            await _updateTask(updated);
          },
        ),
        dense: true,
      );
    }).toList();
  }
}

/// Date row with an optional time-of-day picker. Stored values are UTC in the
/// entity; this row displays and edits in local time.
class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.dateTime,
    required this.onChanged,
  });

  final String label;
  final DateTime? dateTime;
  final ValueChanged<DateTime?> onChanged;

  bool _hasTime(DateTime local) => local.hour != 0 || local.minute != 0;

  @override
  Widget build(BuildContext context) {
    final local = dateTime?.toLocal();
    final l10n = AppLocalizations.of(context);
    final dateLabel = local == null
        ? (l10n?.dateNotSet ?? 'Not set')
        : '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final timeLabel = local != null && _hasTime(local)
        ? '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}'
        : null;

    return Row(
      children: [
        Text('$label: '),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: local ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;
            if (local == null) {
              onChanged(picked);
              return;
            }
            onChanged(
              DateTime(
                picked.year,
                picked.month,
                picked.day,
                local.hour,
                local.minute,
              ),
            );
          },
          child: Text(dateLabel),
        ),
        if (local != null) ...[
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(local),
              );
              if (picked == null) return;
              onChanged(
                DateTime(
                  local.year,
                  local.month,
                  local.day,
                  picked.hour,
                  picked.minute,
                ),
              );
            },
            child: Text(timeLabel ?? (l10n?.allDay ?? 'All day')),
          ),
          if (timeLabel != null)
            IconButton(
              icon: const Icon(Icons.access_time, size: 16),
              tooltip: l10n?.clearTime ?? 'Clear time (all day)',
              onPressed: () =>
                  onChanged(DateTime(local.year, local.month, local.day)),
            ),
        ],
        if (local != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            tooltip: l10n?.dateClear ?? 'Clear',
            onPressed: () => onChanged(null),
          ),
      ],
    );
  }
}

class _AddSubtaskField extends StatefulWidget {
  const _AddSubtaskField({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddSubtaskField> createState() => _AddSubtaskFieldState();
}

class _AddSubtaskFieldState extends State<_AddSubtaskField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('add-subtask-field'),
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: l10n?.addSubtaskHint ?? 'Add subtask…',
              isDense: true,
            ),
            onSubmitted: (v) {
              if (v.trim().isEmpty) return;
              widget.onAdd(v.trim());
              _ctrl.clear();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (_ctrl.text.trim().isEmpty) return;
            widget.onAdd(_ctrl.text.trim());
            _ctrl.clear();
          },
        ),
      ],
    );
  }
}
