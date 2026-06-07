import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

/// Desktop top bar that lets the user quickly add a task by typing a title
/// and pressing Enter.
class QuickAddBar extends StatefulWidget {
  const QuickAddBar({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            _submit();
          }
        },
        child: TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.addTaskHint ??
                'Add a task… (press Enter)',
            prefixIcon: const Icon(Icons.add),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submit,
            ),
          ),
          onSubmitted: (v) => _submit(),
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }
}
