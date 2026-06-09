import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Shows a dialog to create a tag (name only). Returns the trimmed name, or
/// null when cancelled.
Future<String?> showTagCreateDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _TagCreateDialog(),
  );
}

class _TagCreateDialog extends StatefulWidget {
  const _TagCreateDialog();

  @override
  State<_TagCreateDialog> createState() => _TagCreateDialogState();
}

class _TagCreateDialogState extends State<_TagCreateDialog> {
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n?.tagCreateTitle ?? 'New tag'),
      content: TextField(
        controller: _nameCtrl,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n?.tagNameLabel ?? 'Tag name',
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
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
