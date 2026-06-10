import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/reminder.dart';
import '../../../core/models/task.dart';
import '../../../core/utils/result.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/reminder_template.dart';
import '../domain/set_task_reminders_usecase.dart';
import '../task_providers.dart';

/// Opens the per-task reminders editor and schedules notifications on save.
Future<void> showRemindersEditorDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _RemindersEditorDialog(task: task),
  );
}

class _RemindersEditorDialog extends ConsumerStatefulWidget {
  const _RemindersEditorDialog({required this.task});

  final Task task;

  @override
  ConsumerState<_RemindersEditorDialog> createState() =>
      _RemindersEditorDialogState();
}

class _RemindersEditorDialogState
    extends ConsumerState<_RemindersEditorDialog> {
  late List<ReminderTemplate> _templates;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ref
        .read(reminderRepositoryProvider)
        .getByTask(widget.task.id);

    final List<ReminderTemplate> templates;
    if (result case Ok<List<Reminder>>(:final value) when value.isNotEmpty) {
      templates = remindersToTemplates(value);
    } else if (widget.task.dueDate != null) {
      templates = defaultReminderTemplates();
    } else {
      templates = const [];
    }

    if (!mounted) return;
    setState(() {
      _templates = List.of(templates);
      _loading = false;
    });
  }

  String _label(ReminderTemplate template, AppLocalizations? l10n) {
    switch (template.type) {
      case ReminderType.beforeDue:
        final offset = template.offsetMin ?? 0;
        if (offset == 0) {
          return l10n?.remindersAtDue ?? 'At due time';
        }
        if (offset == 1440) {
          return l10n?.remindersOneDayBefore ?? '1 day before due';
        }
        return l10n?.remindersMinutesBefore(offset) ?? '$offset min before due';
      case ReminderType.atStart:
        return l10n?.remindersAtStart ?? 'At start time';
      case ReminderType.custom:
      case ReminderType.overdue:
        return l10n?.detailMenuReminders ?? 'Reminder';
    }
  }

  void _addTemplate(ReminderTemplate template) {
    if (_templates.contains(template)) return;
    setState(() => _templates = [..._templates, template]);
  }

  Future<void> _pickCustomMinutes() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final minutes = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.remindersCustomMinutesTitle ?? 'Minutes before due'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n?.remindersCustomMinutes ?? 'Custom…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value >= 0) {
                Navigator.of(ctx).pop(value);
              }
            },
            child: Text(l10n?.actionSave ?? 'Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (minutes != null) {
      _addTemplate(
        ReminderTemplate(type: ReminderType.beforeDue, offsetMin: minutes),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ref
        .read(setTaskRemindersUseCaseProvider)
        .call(widget.task, _templates);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result case Ok()) {
      ref.invalidate(taskRemindersProvider(widget.task.id));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAddAtStart = widget.task.startDate != null;
    final canAddBeforeDue = widget.task.dueDate != null;

    return AlertDialog(
      key: const Key('reminders-editor-dialog'),
      title: Text(l10n?.detailMenuReminders ?? 'Reminders'),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_templates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n?.remindersEmpty ?? 'No reminders set',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    for (var i = 0; i < _templates.length; i++)
                      ListTile(
                        key: Key('reminder-row-$i'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(_label(_templates[i], l10n)),
                        trailing: IconButton(
                          key: Key('reminder-remove-$i'),
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: l10n?.remindersRemove ?? 'Remove',
                          onPressed: () => setState(
                            () => _templates = List.of(_templates)..removeAt(i),
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                  MenuAnchor(
                    key: const Key('reminders-add-menu'),
                    menuChildren: [
                      if (canAddBeforeDue) ...[
                        for (final offset in const [0, 5, 10, 15, 30, 60])
                          MenuItemButton(
                            onPressed: () => _addTemplate(
                              ReminderTemplate(
                                type: ReminderType.beforeDue,
                                offsetMin: offset,
                              ),
                            ),
                            child: Text(
                              _label(
                                ReminderTemplate(
                                  type: ReminderType.beforeDue,
                                  offsetMin: offset,
                                ),
                                l10n,
                              ),
                            ),
                          ),
                        MenuItemButton(
                          onPressed: () => _addTemplate(
                            const ReminderTemplate(
                              type: ReminderType.beforeDue,
                              offsetMin: 1440,
                            ),
                          ),
                          child: Text(
                            l10n?.remindersOneDayBefore ?? '1 day before due',
                          ),
                        ),
                        MenuItemButton(
                          onPressed: _pickCustomMinutes,
                          child: Text(
                            l10n?.remindersCustomMinutes ?? 'Custom…',
                          ),
                        ),
                      ],
                      if (canAddAtStart)
                        MenuItemButton(
                          onPressed: () => _addTemplate(
                            const ReminderTemplate(type: ReminderType.atStart),
                          ),
                          child: Text(
                            l10n?.remindersAtStart ?? 'At start time',
                          ),
                        ),
                    ],
                    builder: (context, controller, child) {
                      return OutlinedButton.icon(
                        key: const Key('reminders-add'),
                        onPressed: canAddBeforeDue || canAddAtStart
                            ? () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              }
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n?.remindersAdd ?? 'Add reminder'),
                      );
                    },
                  ),
                  if (!canAddBeforeDue && !canAddAtStart)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n?.remindersNeedDate ??
                            'Set a start or due date to add reminders.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n?.actionCancel ?? 'Cancel'),
        ),
        FilledButton(
          key: const Key('reminders-save'),
          onPressed: _saving || _loading ? null : _save,
          child: Text(l10n?.actionSave ?? 'Save'),
        ),
      ],
    );
  }
}
