import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/task_draft.dart';
import '../../../l10n/app_localizations.dart';
import '../../project/project_providers.dart';

/// Shows the [AddTaskSheet] as a modal bottom sheet.
///
/// Optionally pre-fills the start / due date-time, which the calendar's
/// tap-to-create flow uses so a task is created directly on the tapped day
/// (and, in the day view, at the tapped time).
///
/// When [projectId] is provided the task is created in that project silently.
/// When it is null a (required) project picker is shown so a task is always
/// created inside a project.
Future<void> showAddTaskSheet(
  BuildContext context, {
  required Future<void> Function(TaskDraft draft) onCreate,
  DateTime? initialStart,
  DateTime? initialDue,
  String? projectId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AddTaskSheet(
      onCreate: onCreate,
      initialStart: initialStart,
      initialDue: initialDue,
      projectId: projectId,
    ),
  );
}

/// Bottom sheet for creating a task with a title plus optional start and due
/// date-times. Time is optional per date: a date with a midnight time is
/// treated as "all day". Dates are local [DateTime]s; persistence converts
/// them to UTC.
class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({
    super.key,
    required this.onCreate,
    this.initialStart,
    this.initialDue,
    this.projectId,
  });

  final Future<void> Function(TaskDraft draft) onCreate;
  final DateTime? initialStart;
  final DateTime? initialDue;

  /// When non-null the task is created in this project and no picker is shown.
  final String? projectId;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  DateTime? _start;
  DateTime? _due;
  String? _projectId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _due = widget.initialDue;
    _projectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting || _projectId == null) return;
    setState(() => _submitting = true);
    await widget.onCreate(
      TaskDraft(
        title: title,
        startDate: _start,
        dueDate: _due,
        projectId: _projectId,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showPicker = widget.projectId == null;
    final projects = ref.watch(projectListProvider).asData?.value ?? const [];
    // Default the picker to the first project (typically Inbox) so creation is
    // never blocked on an explicit choice.
    if (showPicker && _projectId == null && projects.isNotEmpty) {
      _projectId = projects.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n?.newTaskTitle ?? 'Task title',
              prefixIcon: const Icon(Icons.title),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (showPicker) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.projectLabel ?? 'Project',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                DropdownButton<String>(
                  value: _projectId,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final p in projects)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setState(() => _projectId = v),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _DateTimeField(
            icon: Icons.play_arrow,
            label: l10n?.taskStartDate ?? 'Start date',
            value: _start,
            onChanged: (v) => setState(() => _start = v),
          ),
          _DateTimeField(
            icon: Icons.flag,
            label: l10n?.taskDueDate ?? 'Due date',
            value: _due,
            onChanged: (v) => setState(() => _due = v),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: const Icon(Icons.check),
            label: Text(l10n?.createAction ?? 'Create'),
          ),
        ],
      ),
    );
  }
}

/// A single date + optional time picker row used by [AddTaskSheet].
class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;

  /// Local date-time, or null when unset. A midnight time means "all day".
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  bool _hasTime(DateTime d) => d.hour != 0 || d.minute != 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final df = MaterialLocalizations.of(context);
    final v = value;

    final dateLabel = v == null
        ? (l10n?.dateNotSet ?? 'Not set')
        : df.formatMediumDate(v);
    final timeLabel = v != null && _hasTime(v)
        ? df.formatTimeOfDay(TimeOfDay.fromDateTime(v))
        : (l10n?.allDay ?? 'All day');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: v ?? now,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 10),
              );
              if (picked == null) return;
              onChanged(
                DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  v?.hour ?? 0,
                  v?.minute ?? 0,
                ),
              );
            },
            child: Text(dateLabel),
          ),
          if (v != null)
            TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(v),
                );
                if (picked == null) return;
                onChanged(
                  DateTime(v.year, v.month, v.day, picked.hour, picked.minute),
                );
              },
              child: Text(timeLabel),
            ),
          if (v != null && _hasTime(v))
            IconButton(
              icon: const Icon(Icons.backspace_outlined, size: 16),
              tooltip: l10n?.clearTime ?? 'Clear time (all day)',
              onPressed: () => onChanged(DateTime(v.year, v.month, v.day)),
            ),
          if (v != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              tooltip: l10n?.dateClear ?? 'Clear',
              onPressed: () => onChanged(null),
            ),
        ],
      ),
    );
  }
}
