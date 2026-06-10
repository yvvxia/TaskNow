import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../l10n/app_localizations.dart';

/// Markdown note editor with edit/preview toggle. Edit mode uses a multiline
/// [TextField]; preview mode renders the stored Markdown via [MarkdownBody].
class NoteEditor extends StatefulWidget {
  const NoteEditor({
    super.key,
    required this.controller,
    required this.onSave,
  });

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n?.detailSectionNotes ?? 'Notes',
                style: theme.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ToggleButtons(
              key: const Key('notes-mode-toggle'),
              isSelected: [!_preview, _preview],
              onPressed: (index) => setState(() => _preview = index == 1),
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
              children: [
                Tooltip(
                  message: l10n?.notesEdit ?? 'Edit',
                  child: const Icon(Icons.edit_outlined, size: 18),
                ),
                Tooltip(
                  message: l10n?.notesPreview ?? 'Preview',
                  child: const Icon(Icons.visibility_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _preview
                ? SingleChildScrollView(
                    key: const Key('notes-preview'),
                    padding: const EdgeInsets.all(12),
                    child: MarkdownBody(
                      data: widget.controller.text.isEmpty
                          ? '_${l10n?.notesPlaceholder ?? 'Write your notes in Markdown…'}_'
                          : widget.controller.text,
                      selectable: true,
                    ),
                  )
                : TextField(
                    key: const Key('notes-editor'),
                    controller: widget.controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText:
                          l10n?.notesPlaceholder ??
                          'Write your notes in Markdown…',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onEditingComplete: widget.onSave,
                    onTapOutside: (_) => widget.onSave(),
                  ),
          ),
        ),
      ],
    );
  }
}
