import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/gantt_interaction_controller.dart';
import '../../domain/task_bar.dart';
import '../../domain/time_axis.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';
import 'draggable_timeline_bar.dart';
import 'timeline_grid_painter.dart';

/// Gantt timeline with one task per row.
///
/// Rows are ordered by manual `ganttOrder` then creation time. The user drags
/// a row's label (left gutter) up or down to reorder, which is persisted via
/// [reorderGanttUseCaseProvider]. The day columns are fit to the available
/// width so every row's timeline stays aligned. Bars can still be dragged to
/// move/resize.
class GanttView extends ConsumerWidget {
  const GanttView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  static const double rowHeight = 44;
  static const double headerHeight = 28;
  static const double gutterWidth = 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(ganttBarsProvider(projectId));
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final origin = DateTime(
      view.visibleRange.start.year,
      view.visibleRange.start.month,
      view.visibleRange.start.day,
    );
    final dayCount = view.visibleRange.end.difference(origin).inDays + 1;

    Future<void> onApply(GanttDragIntent intent) =>
        ref.read(ganttInteractionControllerProvider.notifier).apply(intent);

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        if (bars.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)?.emptyTaskList ?? 'No tasks',
            ),
          );
        }

        // [newIndex] is already adjusted for the removed item at [oldIndex].
        Future<void> onReorderItem(int oldIndex, int newIndex) async {
          final ids = bars.map((b) => b.task.id).toList();
          final moved = ids.removeAt(oldIndex);
          ids.insert(newIndex, moved);
          await ref.read(reorderGanttUseCaseProvider).call(ids);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GanttHeader(
              origin: origin,
              dayCount: dayCount,
              gutterWidth: gutterWidth,
              height: headerHeight,
            ),
            const Divider(height: 1),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: bars.length,
                onReorderItem: onReorderItem,
                itemBuilder: (context, index) {
                  final bar = bars[index];
                  return _GanttRow(
                    key: ValueKey('gantt-row-${bar.task.id}'),
                    index: index,
                    bar: bar,
                    origin: origin,
                    dayCount: dayCount,
                    gutterWidth: gutterWidth,
                    rowHeight: rowHeight,
                    selected: bar.task.id == view.selectedTaskId,
                    isDesktop: isDesktop,
                    onSelect: onSelect,
                    onApply: onApply,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GanttHeader extends StatelessWidget {
  const _GanttHeader({
    required this.origin,
    required this.dayCount,
    required this.gutterWidth,
    required this.height,
  });

  final DateTime origin;
  final int dayCount;
  final double gutterWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat('d', l10n?.localeName);
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: gutterWidth,
            child: Center(
              child: Text(
                l10n?.calendarGantt ?? 'Gantt',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < dayCount; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        fmt.format(origin.add(Duration(days: i))),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttRow extends StatelessWidget {
  const _GanttRow({
    super.key,
    required this.index,
    required this.bar,
    required this.origin,
    required this.dayCount,
    required this.gutterWidth,
    required this.rowHeight,
    required this.selected,
    required this.isDesktop,
    required this.onSelect,
    required this.onApply,
  });

  final int index;
  final TaskBar bar;
  final DateTime origin;
  final int dayCount;
  final double gutterWidth;
  final double rowHeight;
  final bool selected;
  final bool isDesktop;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: gutterWidth,
            child: ReorderableDragStartListener(
              index: index,
              child: InkWell(
                onTap: () => onSelect(bar.task.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bar.task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pxPerDay = constraints.maxWidth / dayCount;
                final axis = TimeAxis(origin: origin, pxPerDay: pxPerDay);
                final left = axis.dayStartDx(bar.barStart);
                final right = axis.dayEndDx(bar.barEnd);
                final width = (right - left).clamp(
                  pxPerDay,
                  constraints.maxWidth,
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TimelineGridPainter(
                          dayCount: dayCount,
                          pxPerDay: pxPerDay,
                          lineColor: scheme.outlineVariant,
                          weekendShade: scheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    DraggableTimelineBar(
                      barKey: Key('gantt-bar-${bar.task.id}'),
                      bar: bar,
                      pxPerDay: pxPerDay,
                      left: left + 1,
                      width: (width - 2).clamp(
                        pxPerDay - 2,
                        constraints.maxWidth,
                      ),
                      top: 4,
                      height: rowHeight - 8,
                      minWidthPx: pxPerDay - 2,
                      selected: selected,
                      isDesktop: isDesktop,
                      onSelect: onSelect,
                      onApply: onApply,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
