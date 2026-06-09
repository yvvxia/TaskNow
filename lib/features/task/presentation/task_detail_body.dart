import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/subtask.dart';
import '../../../core/models/task.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/task_list_scope.dart';
import '../task_providers.dart';
import 'recurrence_picker.dart';
import 'task_list_notifier.dart';

/// Shared detail body used by both [TaskDetailPage] (full-screen, mobile) and
/// [TaskDetailPanel] (right panel, desktop).
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

  @override
  Widget build(BuildContext context) {
    // Watch a stream for this specific task.
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

    return SingleChildScrollView(
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

          _SectionTitle(l10n?.detailSectionDates ?? 'Dates'),
          _DateTimeRow(
            label: AppLocalizations.of(context)?.taskStartDate ?? 'Start date',
            dateTime: taskView.task.startDate,
            onChanged: (d) async {
              final updated = _task!.copyWith(startDate: d);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),
          _DateTimeRow(
            label: AppLocalizations.of(context)?.taskDueDate ?? 'Due date',
            dateTime: taskView.task.dueDate,
            onChanged: (d) async {
              final updated = _task!.copyWith(dueDate: d);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),

          _SectionTitle(l10n?.detailSectionAttributes ?? 'Attributes'),
          Row(
            children: [
              Text('${l10n?.taskPriority ?? 'Priority'}: '),
              DropdownButton<Priority>(
                value: taskView.task.priority,
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
                  await ref.read(updateTaskUseCaseProvider).call(updated);
                },
              ),
            ],
          ),

          _SectionTitle(l10n?.detailSectionSubtasks ?? 'Subtasks'),
          ..._buildSubtasks(context, taskView.task.subtasks),
          _AddSubtaskField(
            onAdd: (title) async {
              final newId = DateTime.now().microsecondsSinceEpoch.toString();
              final newSubtask = Subtask(id: newId, title: title);
              final updated = _task!.copyWith(
                subtasks: [..._task!.subtasks, newSubtask],
              );
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),

          _SectionTitle(l10n?.detailSectionReminders ?? 'Reminders'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n?.remindersComingSoon ?? 'Reminders coming soon'),
            dense: true,
          ),

          _SectionTitle(l10n?.detailSectionRecurrence ?? 'Recurrence'),
          RecurrencePicker(
            value: taskView.task.recurrence,
            onChanged: (rule) async {
              final updated = _task!.copyWith(recurrence: rule);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),

          _SectionTitle(l10n?.detailSectionNotes ?? 'Notes'),
          TextField(
            controller: _notesCtrl,
            maxLines: null,
            decoration: InputDecoration(
              hintText: l10n?.detailSectionNotes ?? 'Notes',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() => _editing = true),
            onEditingComplete: () {
              _editing = false;
              _saveNotes();
            },
          ),

          _SectionTitle(l10n?.detailSectionMeta ?? 'Info'),
          if (taskView.task.createdAt != null)
            Text(
              'Created: ${taskView.task.createdAt}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          if (taskView.task.completedAt != null)
            Text(
              'Completed: ${taskView.task.completedAt}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
    );
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
          await ref.read(updateTaskUseCaseProvider).call(updated);
        },
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () async {
            if (_task == null) return;
            final updated = _task!.copyWith(
              subtasks: _task!.subtasks.where((x) => x.id != s.id).toList(),
            );
            await ref.read(updateTaskUseCaseProvider).call(updated);
          },
        ),
        dense: true,
      );
    }).toList();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
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
            // Keep existing time, swap the calendar day.
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'Add subtask…',
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
