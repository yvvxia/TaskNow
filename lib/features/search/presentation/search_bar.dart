import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search_controller.dart';

/// Top search field with debounced keyword updates.
class TaskSearchBar extends ConsumerStatefulWidget {
  const TaskSearchBar({super.key});

  @override
  ConsumerState<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends ConsumerState<TaskSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        key: const Key('search-bar-field'),
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search tasks…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  key: const Key('search-bar-clear'),
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchControllerProvider.notifier).setKeyword('');
                    setState(() {});
                  },
                ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (value) {
          ref.read(searchControllerProvider.notifier).setKeyword(value);
          setState(() {});
        },
      ),
    );
  }
}
