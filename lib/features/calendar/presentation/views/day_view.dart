import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/models/task.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../task/presentation/add_task_sheet.dart';
import '../../../task/task_providers.dart';
import '../../domain/day_overlap_layout.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/gantt_interaction_controller.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';
import 'timed_grid.dart';

/// Drag payload for moving an all-day chip onto the timed grid.
class _AllDayDragData {
  const _AllDayDragData(this.taskId, this.currentStartLocal);
  final String taskId;
  final DateTime currentStartLocal;
}

/// Drag payload for an unscheduled task pulled from the quick-arrange panel.
class _QuickArrangeData {
  const _QuickArrangeData(this.taskId);
  final String taskId;
}

/// Day view: a 24-hour vertical axis in **local** time.
///
/// Tasks with a local midnight start/end render in the top all-day band.
/// Timed tasks render as blocks on the hour grid. Overlapping tasks are laid
/// out side-by-side. Long-press a block to move it vertically (whole block) or
/// near its top/bottom edge to resize start/end. Long-press empty grid space to
/// create a task at that time. All-day chips can be dragged onto the grid to
/// assign a concrete time.
class DayView extends ConsumerStatefulWidget {
  const DayView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  bool _quickOpen = false;

  @override
  Widget build(BuildContext context) {
    final onSelect = widget.onSelect;
    final projectId = widget.projectId;
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider(projectId));
    final day = DateTime(view.anchor.year, view.anchor.month, view.anchor.day);
    final nextDay = day.add(const Duration(days: 1));
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    Future<void> onApply(GanttDragIntent intent) =>
        ref.read(ganttInteractionControllerProvider.notifier).apply(intent);
    void onSchedule(String taskId, DateTime startLocal) {
      ref
          .read(ganttInteractionControllerProvider.notifier)
          .scheduleAt(
            taskId,
            startLocal,
            startLocal.add(const Duration(hours: 1)),
          );
    }

    void onCreateAt(double localY) {
      final minutes = snapMinutes(
        (localY / TimedGridMetrics.hourHeight * 60).round(),
        TimedGridMetrics.snapMinutes,
      ).clamp(0, 24 * 60 - TimedGridMetrics.snapMinutes);
      final startLocal = day.add(Duration(minutes: minutes));
      showAddTaskSheet(
        context,
        onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
        initialStart: startLocal,
        initialDue: startLocal.add(const Duration(hours: 1)),
        projectId: projectId,
      );
    }

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        final dayBars = bars
            .where(
              (b) =>
                  b.barStart.toLocal().isBefore(nextDay) &&
                  !b.barEnd.toLocal().isBefore(day),
            )
            .toList();
        final allDay = dayBars.where(isAllDayBar).toList();
        final timed = dayBars.where((b) => !isAllDayBar(b)).toList();
        final scheme = Theme.of(context).colorScheme;
        final labelStyle =
            Theme.of(context).textTheme.labelSmall ??
            const TextStyle(fontSize: 11);

        final segments = timed.map((b) {
          final mins = barMinutesForDay(b, day);
          return TimedBarSegment(
            id: b.task.id,
            startMin: mins.startMin,
            endMin: mins.endMin,
          );
        }).toList();
        final placements = DayOverlapLayout.assign(segments);

        final timeline = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allDay.isNotEmpty)
              SizedBox(
                height: TimedGridMetrics.allDayHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  children: [
                    for (final b in allDay)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _AllDayChip(
                          bar: b,
                          isDesktop: isDesktop,
                          onTap: () => onSelect(b.task.id),
                        ),
                      ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 24 * TimedGridMetrics.hourHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const areaLeft = TimedGridMetrics.gutter + 4;
                      final areaWidth = constraints.maxWidth - areaLeft - 8;

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: HourAxisPainter(
                                hourHeight: TimedGridMetrics.hourHeight,
                                lineColor: scheme.outlineVariant,
                                labelStyle: labelStyle,
                                gridStartX: TimedGridMetrics.gutter,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onLongPressStart: (d) =>
                                  onCreateAt(d.localPosition.dy),
                            ),
                          ),
                          Positioned.fill(
                            child: _TimedGridDropTarget(
                              day: day,
                              onApply: onApply,
                            ),
                          ),
                          Positioned.fill(
                            child: _QuickArrangeDropTarget(
                              day: day,
                              onSchedule: onSchedule,
                            ),
                          ),
                          for (final b in timed)
                            _positionedBlock(
                              bar: b,
                              day: day,
                              placement: placements[b.task.id]!,
                              areaLeft: areaLeft,
                              areaWidth: areaWidth,
                              selected: b.task.id == view.selectedTaskId,
                              onSelect: onSelect,
                              onApply: onApply,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
        return _withQuickArrange(
          timeline: timeline,
          projectId: projectId,
          isDesktop: isDesktop,
          onSelect: onSelect,
        );
      },
    );
  }

  /// Overlays the [timeline] with the swipe-in quick-arrange panel of
  /// unscheduled tasks. A right-edge gesture opens the panel; tasks are dragged
  /// onto the grid (handled by [_QuickArrangeDropTarget]).
  Widget _withQuickArrange({
    required Widget timeline,
    required String? projectId,
    required bool isDesktop,
    required ValueChanged<String?> onSelect,
  }) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        Positioned.fill(child: timeline),
        if (!_quickOpen)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 20,
            child: GestureDetector(
              key: const Key('quick-arrange-edge'),
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! < 0) {
                  setState(() => _quickOpen = true);
                }
              },
              onTap: () => setState(() => _quickOpen = true),
            ),
          ),
        if (_quickOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _quickOpen = false),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 260,
            child: _QuickArrangePanel(
              projectId: projectId,
              isDesktop: isDesktop,
              l10n: l10n,
              onClose: () => setState(() => _quickOpen = false),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _positionedBlock({
  required TaskBar bar,
  required DateTime day,
  required OverlapPlacement placement,
  required double areaLeft,
  required double areaWidth,
  required bool selected,
  required ValueChanged<String?> onSelect,
  required Future<void> Function(GanttDragIntent) onApply,
}) {
  final bounds = overlapBlockBounds(
    areaLeft: areaLeft,
    areaWidth: areaWidth,
    column: placement.column,
    columns: placement.columns,
  );
  return TimedTaskBlock(
    bar: bar,
    day: day,
    selected: selected,
    onSelect: onSelect,
    onApply: onApply,
    left: bounds.left,
    width: bounds.width,
  );
}

/// Accepts an all-day chip dropped onto the hour grid and assigns a start time.
class _TimedGridDropTarget extends StatelessWidget {
  const _TimedGridDropTarget({required this.day, required this.onApply});

  final DateTime day;
  final Future<void> Function(GanttDragIntent) onApply;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_AllDayDragData>(
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localY = box.globalToLocal(details.offset).dy;
        final minutes = snapMinutes(
          (localY / TimedGridMetrics.hourHeight * 60).round(),
          TimedGridMetrics.snapMinutes,
        );
        final newStartLocal = day.add(Duration(minutes: minutes));
        final delta = newStartLocal.difference(details.data.currentStartLocal);
        if (delta.inMinutes != 0) {
          onApply(MoveDrag(taskId: details.data.taskId, delta: delta));
        }
      },
      builder: (context, candidate, rejected) {
        if (candidate.isEmpty) return const SizedBox.expand();
        return Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        );
      },
    );
  }
}

/// Accepts an unscheduled task dropped from the quick-arrange panel and
/// schedules it at the dropped time (1-hour default duration).
class _QuickArrangeDropTarget extends StatelessWidget {
  const _QuickArrangeDropTarget({required this.day, required this.onSchedule});

  final DateTime day;
  final void Function(String taskId, DateTime startLocal) onSchedule;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_QuickArrangeData>(
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localY = box.globalToLocal(details.offset).dy;
        final minutes = snapMinutes(
          (localY / TimedGridMetrics.hourHeight * 60).round(),
          TimedGridMetrics.snapMinutes,
        ).clamp(0, 24 * 60 - TimedGridMetrics.snapMinutes);
        onSchedule(details.data.taskId, day.add(Duration(minutes: minutes)));
      },
      builder: (context, candidate, rejected) {
        if (candidate.isEmpty) return const SizedBox.expand();
        return Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
        );
      },
    );
  }
}

/// Slide-in panel listing unscheduled tasks that can be dragged onto the grid.
class _QuickArrangePanel extends ConsumerWidget {
  const _QuickArrangePanel({
    required this.projectId,
    required this.isDesktop,
    required this.l10n,
    required this.onClose,
  });

  final String? projectId;
  final bool isDesktop;
  final AppLocalizations? l10n;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks =
        ref.watch(unscheduledTasksProvider(projectId)).asData?.value ??
        const <Task>[];
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n?.calendarQuickArrange ?? 'Quick arrange',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n?.calendarQuickArrangeHint ??
                    'Drag a task onto the timeline to schedule it',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        l10n?.calendarQuickArrangeEmpty ??
                            'No unscheduled tasks',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        for (final t in tasks)
                          _QuickArrangeChip(task: t, isDesktop: isDesktop),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A draggable chip for an unscheduled task in the quick-arrange panel.
class _QuickArrangeChip extends StatelessWidget {
  const _QuickArrangeChip({required this.task, required this.isDesktop});

  final Task task;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chip = Container(
      key: Key('quick-arrange-${task.id}'),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );

    final data = _QuickArrangeData(task.id);
    final feedback = Material(
      color: Colors.transparent,
      child: Opacity(opacity: 0.9, child: SizedBox(width: 200, child: chip)),
    );
    final whileDragging = Opacity(opacity: 0.3, child: chip);

    if (isDesktop) {
      return Draggable<_QuickArrangeData>(
        data: data,
        feedback: feedback,
        childWhenDragging: whileDragging,
        child: chip,
      );
    }
    return LongPressDraggable<_QuickArrangeData>(
      data: data,
      feedback: feedback,
      childWhenDragging: whileDragging,
      child: chip,
    );
  }
}

/// All-day chip in the top band. Can be dragged onto the timed grid below.
class _AllDayChip extends StatelessWidget {
  const _AllDayChip({
    required this.bar,
    required this.isDesktop,
    required this.onTap,
  });

  final TaskBar bar;
  final bool isDesktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = bar.task.status == TaskStatus.complete;
    final chip = Container(
      key: Key('day-allday-${bar.task.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete ? bar.color.withValues(alpha: 0.55) : bar.color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        bar.task.title,
        style: taskBarTitleStyle(isComplete: isComplete),
      ),
    );

    final data = _AllDayDragData(bar.task.id, bar.barStart.toLocal());
    final feedback = Material(
      color: Colors.transparent,
      child: Opacity(opacity: 0.9, child: chip),
    );
    final whileDragging = Opacity(opacity: 0.3, child: chip);
    final tappable = GestureDetector(onTap: onTap, child: chip);

    if (isDesktop) {
      return Draggable(
        data: data,
        feedback: feedback,
        childWhenDragging: whileDragging,
        child: tappable,
      );
    }
    return LongPressDraggable(
      data: data,
      feedback: feedback,
      childWhenDragging: whileDragging,
      child: tappable,
    );
  }
}
