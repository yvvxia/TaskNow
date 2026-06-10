import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project.dart';
import '../../../core/models/task_draft.dart';
import '../../../core/utils/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../calendar/domain/gantt_layout.dart';
import '../../project/presentation/project_edit_dialog.dart';
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
  List<String> tagIds = const [],
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
      tagIds: tagIds,
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
    this.tagIds = const [],
  });

  final Future<void> Function(TaskDraft draft) onCreate;
  final DateTime? initialStart;
  final DateTime? initialDue;

  /// When non-null the task is created in this project and no picker is shown.
  final String? projectId;

  /// Tag ids pre-applied to the created task (e.g. when adding from a tag view).
  final List<String> tagIds;

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

  String _selectedProjectName(List<Project> projects) {
    for (final p in projects) {
      if (p.id == _projectId) return p.name;
    }
    return '';
  }

  /// Opens the project picker as its own modal sheet.
  ///
  /// The keyboard is dismissed first so the add-task sheet settles into its
  /// resting position before the picker animates up; otherwise the soft
  /// keyboard collapsing mid-open leaves the two sheets misaligned.
  Future<void> _pickProject() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final projects =
        ref.read(projectListProvider).asData?.value ?? const <Project>[];
    final result = await showModalBottomSheet<_ProjectPickResult>(
      context: context,
      showDragHandle: true,
      builder: (_) =>
          _ProjectPickerSheet(projects: projects, selectedId: _projectId),
    );
    if (result == null || !mounted) return;
    switch (result) {
      case _ProjectPicked(:final id):
        setState(() => _projectId = id);
      case _ProjectCreateNew():
        final edit = await showProjectEditDialog(context);
        if (edit == null || !mounted) return;
        final created = await ref
            .read(createProjectUseCaseProvider)
            .call(edit.name, color: edit.color);
        if (!mounted) return;
        if (created case Ok(:final value)) {
          setState(() => _projectId = value.id);
        }
    }
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
        tagIds: widget.tagIds,
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
            InkWell(
              onTap: _pickProject,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.folder_outlined, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n?.projectLabel ?? 'Project',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _selectedProjectName(projects),
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
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

/// Result of the project picker sheet: either an existing project was chosen
/// or the user asked to create a new one.
sealed class _ProjectPickResult {
  const _ProjectPickResult();
}

class _ProjectPicked extends _ProjectPickResult {
  const _ProjectPicked(this.id);
  final String id;
}

class _ProjectCreateNew extends _ProjectPickResult {
  const _ProjectCreateNew();
}

/// Modal sheet listing existing projects plus a "create new project" action.
///
/// Shown by [AddTaskSheet] instead of an inline dropdown so that opening it
/// while the keyboard is up no longer leaves the picker overlay stranded above
/// the collapsing add-task sheet.
class _ProjectPickerSheet extends StatelessWidget {
  const _ProjectPickerSheet({required this.projects, required this.selectedId});

  final List<Project> projects;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n?.projectSelectTitle ?? 'Select project',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in projects)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 8,
                      backgroundColor:
                          GanttLayout.parseColor(p.color) ??
                          GanttLayout.projectColor(p.id),
                    ),
                    title: Text(p.name),
                    trailing: p.id == selectedId
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop(_ProjectPicked(p.id)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n?.projectCreateTitle ?? 'New project'),
            onTap: () => Navigator.of(context).pop(const _ProjectCreateNew()),
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
