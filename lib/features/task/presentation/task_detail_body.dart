import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/subtask.dart';
import '../../../core/models/task.dart';
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
        orElse: () => list.isEmpty
            ? throw StateError('not found')
            : list.first,
      ),
    );

    if (task.hasError || task.isLoading) {
      return const Center(child: Text('Loading…'));
    }

    final taskView = task.value;
    if (taskView == null) {
      return const Center(child: Text('Task not found'));
    }

    _loadTask(taskView.task);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextField(
            controller: _titleCtrl,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Task title',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() => _editing = true),
            onSubmitted: (_) {
              _editing = false;
              _saveTitle();
            },
          ),

          const Divider(),

          // Dates
          _DateRow(
            label: 'Start date',
            date: taskView.task.startDate,
            onPicked: (d) async {
              final updated = _task!.copyWith(startDate: d);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),
          _DateRow(
            label: 'Due date',
            date: taskView.task.dueDate,
            onPicked: (d) async {
              final updated = _task!.copyWith(dueDate: d);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),

          const Divider(),

          // Priority
          Row(
            children: [
              const Text('Priority: '),
              DropdownButton<Priority>(
                value: taskView.task.priority,
                items: Priority.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
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

          const Divider(),

          // Subtasks
          Text(
            'Subtasks',
            style: Theme.of(context).textTheme.titleSmall,
          ),
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

          const Divider(),

          // Recurrence
          Text(
            'Recurrence',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          RecurrencePicker(
            value: taskView.task.recurrence,
            onChanged: (rule) async {
              final updated = _task!.copyWith(recurrence: rule);
              await ref.read(updateTaskUseCaseProvider).call(updated);
            },
          ),

          const Divider(),

          // Notes
          TextField(
            controller: _notesCtrl,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Add notes…',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() => _editing = true),
            onEditingComplete: () {
              _editing = false;
              _saveNotes();
            },
          ),

          const Divider(),

          // Meta
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

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: '),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onPicked(picked);
          },
          child: Text(
            date == null
                ? 'None'
                : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
          ),
        ),
        if (date != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () => onPicked(null),
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
