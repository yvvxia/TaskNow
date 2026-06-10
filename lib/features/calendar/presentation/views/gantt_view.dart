import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../../../core/di/clock.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../task/domain/delete_task_usecase.dart';
import '../../../task/presentation/add_task_sheet.dart';
import '../../../task/task_providers.dart';
import '../../domain/gantt_axis_window.dart';
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
/// [reorderGanttUseCaseProvider]. The horizontal axis spans all dated tasks
/// with a fixed pixels-per-day column width and synchronized horizontal
/// scrolling across the header and every row.
class GanttView extends ConsumerStatefulWidget {
  const GanttView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  static const double rowHeight = 44;
  static const double headerHeight = 28;
  static const double desktopGutterWidth = 150;

  /// On mobile the left column shrinks to a bare drag handle; the task name is
  /// shown directly on the colored bar to save horizontal space.
  static const double mobileGutterWidth = 36;
  static const double mobilePxPerDay = 48;
  static const double desktopPxPerDay = 56;

  static double pxPerDayFor(bool isDesktop) =>
      isDesktop ? desktopPxPerDay : mobilePxPerDay;

  static double gutterWidthFor(bool isDesktop) =>
      isDesktop ? desktopGutterWidth : mobileGutterWidth;

  /// Maps a horizontal position inside the axis to a calendar day.
  static DateTime dayFromLocalDx({
    required DateTime origin,
    required int dayCount,
    required double pxPerDay,
    required double localX,
  }) {
    final index = (localX / pxPerDay).floor().clamp(0, dayCount - 1);
    return origin.add(Duration(days: index));
  }

  @override
  ConsumerState<GanttView> createState() => _GanttViewState();
}

class _GanttViewState extends ConsumerState<GanttView> {
  final _scrollGroup = LinkedScrollControllerGroup();
  late final ScrollController _headerScrollController;
  late final ScrollController _gridScrollController;

  @override
  void initState() {
    super.initState();
    _headerScrollController = _scrollGroup.addAndGet();
    _gridScrollController = _scrollGroup.addAndGet();
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _createAt(DateTime day) {
    showAddTaskSheet(
      context,
      onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
      initialStart: day,
      initialDue: day,
      projectId: widget.projectId,
    );
  }

  Future<void> _showTaskMenu(Offset globalPos, TaskBar bar) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        globalPos.dx,
        globalPos.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Text(l10n?.actionEdit ?? 'Edit'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(l10n?.actionDelete ?? 'Delete'),
        ),
      ],
    );
    if (!mounted) return;
    switch (selected) {
      case 'edit':
        widget.onSelect(bar.task.id);
      case 'delete':
        await _confirmDelete(bar);
    }
  }

  Future<void> _confirmDelete(TaskBar bar) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.deleteTaskTitle ?? 'Delete task?'),
        content: Text(
          l10n?.deleteTaskMessage(bar.task.title) ??
              'This will permanently remove "${bar.task.title}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(deleteTaskUseCaseProvider)
          .call(bar.task.id, DeleteScope.thisOnly);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(ganttBarsProvider(widget.projectId));
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final pxPerDay = GanttView.pxPerDayFor(isDesktop);
    final gutterWidth = GanttView.gutterWidthFor(isDesktop);
    final now = ref.watch(clockProvider)();

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

        final axis = GanttAxisWindow.fromBars(bars, now: now);
        final axisWidth = axis.widthPx(pxPerDay);
        final scheme = Theme.of(context).colorScheme;

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
              origin: axis.origin,
              dayCount: axis.dayCount,
              axisWidth: axisWidth,
              gutterWidth: gutterWidth,
              height: GanttView.headerHeight,
              showLabel: isDesktop,
              scrollController: _headerScrollController,
            ),
            const Divider(height: 1),
            // A local Overlay (default Clip.hardEdge) bounds the reorder drag
            // proxy to the list region, so a row dragged upward can't overflow
            // and cover the header.
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: gutterWidth),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _gridScrollController,
                                child: SizedBox(
                                  width: axisWidth,
                                  height: constraints.maxHeight,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: TimelineGridPainter(
                                            dayCount: axis.dayCount,
                                            pxPerDay: pxPerDay,
                                            lineColor: scheme.outlineVariant,
                                            weekendShade: scheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: _GanttBlankGesture(
                                          isDesktop: isDesktop,
                                          origin: axis.origin,
                                          dayCount: axis.dayCount,
                                          pxPerDay: pxPerDay,
                                          onCreateAt: _createAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) => ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: bars.length,
                          onReorderItem: onReorderItem,
                          itemBuilder: (context, index) {
                            final bar = bars[index];
                            return _GanttRow(
                              key: ValueKey('gantt-row-${bar.task.id}'),
                              index: index,
                              bar: bar,
                              origin: axis.origin,
                              dayCount: axis.dayCount,
                              axisWidth: axisWidth,
                              pxPerDay: pxPerDay,
                              gutterWidth: gutterWidth,
                              rowHeight: GanttView.rowHeight,
                              selected: bar.task.id == view.selectedTaskId,
                              isDesktop: isDesktop,
                              scrollGroup: _scrollGroup,
                              onSelect: widget.onSelect,
                              onApply: onApply,
                              onCreateAt: _createAt,
                              onContextMenu: (pos) => _showTaskMenu(pos, bar),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Blank-area gesture layer for creating tasks on the Gantt timeline.
class _GanttBlankGesture extends StatelessWidget {
  const _GanttBlankGesture({
    required this.isDesktop,
    required this.origin,
    required this.dayCount,
    required this.pxPerDay,
    required this.onCreateAt,
  });

  final bool isDesktop;
  final DateTime origin;
  final int dayCount;
  final double pxPerDay;
  final void Function(DateTime day) onCreateAt;

  void _onCreate(Offset localPosition) {
    onCreateAt(
      GanttView.dayFromLocalDx(
        origin: origin,
        dayCount: dayCount,
        pxPerDay: pxPerDay,
        localX: localPosition.dx,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: isDesktop ? (d) => _onCreate(d.localPosition) : null,
      onLongPressStart: isDesktop ? null : (d) => _onCreate(d.localPosition),
    );
  }
}

class _GanttHeader extends StatelessWidget {
  const _GanttHeader({
    required this.origin,
    required this.dayCount,
    required this.axisWidth,
    required this.gutterWidth,
    required this.height,
    required this.showLabel,
    required this.scrollController,
  });

  final DateTime origin;
  final int dayCount;
  final double axisWidth;
  final double gutterWidth;
  final double height;
  final bool showLabel;
  final ScrollController scrollController;

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
            child: showLabel
                ? Center(
                    child: Text(
                      l10n?.calendarGantt ?? 'Gantt',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
                : null,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              child: SizedBox(
                width: axisWidth,
                child: Row(
                  children: [
                    for (var i = 0; i < dayCount; i++)
                      SizedBox(
                        width: axisWidth / dayCount,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttRow extends StatefulWidget {
  const _GanttRow({
    super.key,
    required this.index,
    required this.bar,
    required this.origin,
    required this.dayCount,
    required this.axisWidth,
    required this.pxPerDay,
    required this.gutterWidth,
    required this.rowHeight,
    required this.selected,
    required this.isDesktop,
    required this.scrollGroup,
    required this.onSelect,
    required this.onApply,
    required this.onCreateAt,
    required this.onContextMenu,
  });

  final int index;
  final TaskBar bar;
  final DateTime origin;
  final int dayCount;
  final double axisWidth;
  final double pxPerDay;
  final double gutterWidth;
  final double rowHeight;
  final bool selected;
  final bool isDesktop;
  final LinkedScrollControllerGroup scrollGroup;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;
  final void Function(DateTime day) onCreateAt;
  final void Function(Offset globalPos) onContextMenu;

  @override
  State<_GanttRow> createState() => _GanttRowState();
}

class _GanttRowState extends State<_GanttRow> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollGroup.addAndGet();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final axis = TimeAxis(origin: widget.origin, pxPerDay: widget.pxPerDay);
    final left = axis.dayStartDx(widget.bar.barStart);
    final right = axis.dayEndDx(widget.bar.barEnd);
    final width = (right - left).clamp(widget.pxPerDay, widget.axisWidth);

    return SizedBox(
      height: widget.rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: widget.gutterWidth,
            child: ReorderableDragStartListener(
              index: widget.index,
              child: InkWell(
                onTap: widget.isDesktop
                    ? () => widget.onSelect(widget.bar.task.id)
                    : null,
                child: widget.isDesktop
                    ? Padding(
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
                                widget.bar.task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.drag_indicator,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: SizedBox(
                width: widget.axisWidth,
                height: widget.rowHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _GanttBlankGesture(
                        isDesktop: widget.isDesktop,
                        origin: widget.origin,
                        dayCount: widget.dayCount,
                        pxPerDay: widget.pxPerDay,
                        onCreateAt: widget.onCreateAt,
                      ),
                    ),
                    DraggableTimelineBar(
                      barKey: Key('gantt-bar-${widget.bar.task.id}'),
                      bar: widget.bar,
                      pxPerDay: widget.pxPerDay,
                      left: left + 1,
                      width: (width - 2).clamp(
                        widget.pxPerDay - 2,
                        widget.axisWidth,
                      ),
                      top: 4,
                      height: widget.rowHeight - 8,
                      minWidthPx: widget.pxPerDay - 2,
                      selected: widget.selected,
                      isDesktop: widget.isDesktop,
                      onSelect: widget.onSelect,
                      onApply: widget.onApply,
                      onContextMenu: widget.isDesktop
                          ? widget.onContextMenu
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
