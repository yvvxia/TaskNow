import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/tag.dart';
import '../../../core/utils/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../tag/presentation/tag_create_dialog.dart';
import '../../tag/tag_providers.dart';

/// Inline tag chips with a menu to toggle existing tags or create a new one.
class TaskTagPicker extends ConsumerWidget {
  const TaskTagPicker({
    super.key,
    required this.selectedTagIds,
    required this.onChanged,
  });

  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onChanged;

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    final name = await showTagCreateDialog(context);
    if (name == null || !context.mounted) return;

    final result = await ref.read(createTagUseCaseProvider).call(name);
    if (!context.mounted) return;
    if (result case Ok(:final value)) {
      if (!selectedTagIds.contains(value.id)) {
        onChanged([...selectedTagIds, value.id]);
      }
    }
  }

  void _toggleTag(String tagId) {
    if (selectedTagIds.contains(tagId)) {
      onChanged(selectedTagIds.where((id) => id != tagId).toList());
    } else {
      onChanged([...selectedTagIds, tagId]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tagsAsync = ref.watch(tagListProvider);

    return tagsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (allTags) {
        final selected = allTags
            .where((t) => selectedTagIds.contains(t.id))
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.detailSectionTags ?? 'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...selected.map((tag) => _TagChip(
                  tag: tag,
                  onRemove: () => _toggleTag(tag.id),
                )),
                _AddTagButton(
                  allTags: allTags,
                  selectedTagIds: selectedTagIds,
                  onToggle: _toggleTag,
                  onCreate: () => _createTag(context, ref),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag, required this.onRemove});

  final Tag tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = tag.color != null
        ? Color(int.parse(tag.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primaryContainer;
    return InputChip(
      key: Key('tag-chip-${tag.id}'),
      label: Text(tag.name),
      backgroundColor: color.withValues(alpha: 0.3),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }
}

class _AddTagButton extends StatelessWidget {
  const _AddTagButton({
    required this.allTags,
    required this.selectedTagIds,
    required this.onToggle,
    required this.onCreate,
  });

  final List<Tag> allTags;
  final List<String> selectedTagIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      key: const Key('tag-picker-menu'),
      menuChildren: [
        ...allTags.map(
          (tag) => MenuItemButton(
            key: Key('tag-option-${tag.id}'),
            leadingIcon: Icon(
              selectedTagIds.contains(tag.id)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 18,
            ),
            child: Text(tag.name),
            onPressed: () => onToggle(tag.id),
          ),
        ),
        if (allTags.isNotEmpty) const Divider(),
        MenuItemButton(
          key: const Key('tag-create-option'),
          onPressed: onCreate,
          leadingIcon: const Icon(Icons.add, size: 18),
          child: Text(l10n?.tagCreateTitle ?? 'New tag'),
        ),
      ],
      builder: (context, controller, child) {
        return ActionChip(
          key: const Key('detail-add-tag'),
          avatar: const Icon(Icons.add, size: 16),
          label: Text(l10n?.detailAddTag ?? 'Add tag'),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }
}
