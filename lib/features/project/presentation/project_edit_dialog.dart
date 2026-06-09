import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../calendar/domain/gantt_layout.dart';

/// Palette offered when creating / editing a project. Stored as `#RRGGBB`.
const List<String> kProjectColorPalette = <String>[
  '#E53935', // red
  '#FB8C00', // orange
  '#FDD835', // yellow
  '#43A047', // green
  '#00ACC1', // cyan
  '#1E88E5', // blue
  '#5E35B1', // deep purple
  '#D81B60', // pink
  '#6D4C41', // brown
  '#546E7A', // blue grey
];

/// Result of the project edit dialog.
class ProjectEditResult {
  const ProjectEditResult(this.name, this.color);
  final String name;
  final String? color;
}

/// Shows a dialog to create or edit a project (name + color). Returns null on
/// cancel.
Future<ProjectEditResult?> showProjectEditDialog(
  BuildContext context, {
  String? initialName,
  String? initialColor,
}) {
  return showDialog<ProjectEditResult>(
    context: context,
    builder: (_) => _ProjectEditDialog(
      initialName: initialName,
      initialColor: initialColor,
    ),
  );
}

class _ProjectEditDialog extends StatefulWidget {
  const _ProjectEditDialog({this.initialName, this.initialColor});

  final String? initialName;
  final String? initialColor;

  @override
  State<_ProjectEditDialog> createState() => _ProjectEditDialogState();
}

class _ProjectEditDialogState extends State<_ProjectEditDialog> {
  late final TextEditingController _nameCtrl;
  late String _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _color = widget.initialColor ?? kProjectColorPalette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(ProjectEditResult(name, _color));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.initialName == null
            ? (l10n?.projectCreateTitle ?? 'New project')
            : (l10n?.projectEditTitle ?? 'Edit project'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n?.projectNameLabel ?? 'Project name',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.projectColorLabel ?? 'Color',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hex in kProjectColorPalette)
                _Swatch(
                  hex: hex,
                  selected: hex == _color,
                  onTap: () => setState(() => _color = hex),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.actionCancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n?.actionSave ?? 'Save'),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = GanttLayout.parseColor(hex) ?? Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
