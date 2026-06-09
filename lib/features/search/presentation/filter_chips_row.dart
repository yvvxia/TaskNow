import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/clock.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums/enums.dart';
import '../../../core/enums/status_filter.dart';
import '../../../core/models/project.dart';
import '../../../core/models/tag.dart';
import '../../../l10n/app_localizations.dart';
import '../search_controller.dart';
import 'date_filter_sheet.dart';

/// Horizontal filter chips for status, priority, tags, projects, and date.
class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);
    final now = ref.watch(clockProvider)();
    final tagsAsync = ref.watch(_tagsProvider);
    final projectsAsync = ref.watch(_projectsProvider);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      key: const Key('filter-chips-row'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _GroupLabel(l10n?.filterSectionStatus ?? 'Status'),
          _StatusMenuChip(
            selected: query.statusFilter,
            onSelected: controller.setStatus,
          ),
          const SizedBox(width: 8),
          _GroupLabel(l10n?.filterSectionPriority ?? 'Priority'),
          ...Priority.values.map(
            (p) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                key: Key('priority-chip-${p.name}'),
                label: Text(priorityLabel(p, l10n)),
                selected: query.effectivePriorities?.contains(p) ?? false,
                onSelected: (_) => controller.togglePriority(p),
              ),
            ),
          ),
          _GroupLabel(l10n?.filterSectionDate ?? 'Date'),
          FilterChip(
            key: const Key('date-filter-chip'),
            label: Text(dateFilterLabel(query.dateFilter, now, l10n)),
            selected: query.dateFilter != null,
            onSelected: (_) async {
              final picked = await DateFilterSheet.show(context, now: now);
              if (picked != null || query.dateFilter != null) {
                controller.setDate(picked);
              }
            },
          ),
          const SizedBox(width: 8),
          _GroupLabel(l10n?.filterSectionTags ?? 'Tags'),
          ...tagsAsync.maybeWhen(
            data: (tags) => tags.map(
              (tag) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  key: Key('tag-chip-${tag.id}'),
                  label: Text(tag.name),
                  selected: query.tagIds.contains(tag.id),
                  onSelected: (_) => controller.toggleTag(tag.id),
                ),
              ),
            ),
            orElse: () => const <Widget>[],
          ),
          _GroupLabel(l10n?.filterSectionProjects ?? 'Projects'),
          ...projectsAsync.maybeWhen(
            data: (projects) => projects.map(
              (project) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  key: Key('project-chip-${project.id}'),
                  label: Text(project.name),
                  selected: query.effectiveProjectIds.contains(project.id),
                  onSelected: (_) => controller.toggleProject(project.id),
                ),
              ),
            ),
            orElse: () => const <Widget>[],
          ),
          ActionChip(
            key: const Key('clear-filters-chip'),
            label: Text(l10n?.searchClearFilters ?? 'Clear'),
            onPressed: controller.clear,
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatusMenuChip extends StatelessWidget {
  const _StatusMenuChip({required this.selected, required this.onSelected});

  final StatusFilter selected;
  final ValueChanged<StatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StatusFilter>(
      key: const Key('status-filter-chip'),
      initialValue: selected,
      onSelected: onSelected,
      child: Chip(
        label: Text(statusFilterLabel(selected, AppLocalizations.of(context))),
        avatar: const Icon(Icons.filter_list, size: 18),
      ),
      itemBuilder: (context) => StatusFilter.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(statusFilterLabel(s, AppLocalizations.of(context))),
            ),
          )
          .toList(),
    );
  }
}

final _tagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});

final _projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});
