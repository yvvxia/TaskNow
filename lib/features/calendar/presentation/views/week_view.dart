import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/enums.dart';
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

/// Week view: 7 day columns on a shared 24-hour vertical grid.
///
/// A left gutter shows hour labels. Timed tasks render as blocks sized by
/// duration; overlapping tasks within a day are laid out side-by-side.
/// All-day tasks appear in a band above the grid. Tap a block to open task
/// detail; long-press empty grid space to create a task at that time.
class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider(projectId));
    final origin = DateTime(
      view.visibleRange.start.year,
      view.visibleRange.start.month,
      view.visibleRange.start.day,
    );
    Future<void> onApply(GanttDragIntent intent) =>
        ref.read(ganttInteractionControllerProvider.notifier).apply(intent);
    void onOpenDay(DateTime day) =>
        ref.read(calendarViewStateProvider.notifier).openDay(day);

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        final days = [
          for (var i = 0; i < 7; i++) origin.add(Duration(days: i)),
        ];
        final dayBars = [
          for (final day in days)
            bars.where((b) => _overlapsDay(b, day)).toList(),
        ];
        final hasAllDay = dayBars.any((list) => list.any(isAllDayBar));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekHeaderRow(days: days, onOpenDay: onOpenDay),
            if (hasAllDay) ...[
              _WeekAllDayRow(days: days, dayBars: dayBars, onSelect: onSelect),
              const Divider(height: 1),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 24 * TimedGridMetrics.hourHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: TimedGridMetrics.gutter,
                        child: CustomPaint(
                          size: Size(
                            TimedGridMetrics.gutter,
                            24 * TimedGridMetrics.hourHeight,
                          ),
                          painter: HourAxisPainter(
                            hourHeight: TimedGridMetrics.hourHeight,
                            lineColor: Theme.of(
                              context,
                            ).colorScheme.outlineVariant,
                            labelStyle:
                                Theme.of(context).textTheme.labelSmall ??
                                const TextStyle(fontSize: 11),
                            drawGridLines: false,
                          ),
                        ),
                      ),
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: _WeekTimedColumn(
                            day: days[i],
                            bars: dayBars[i]
                                .where((b) => !isAllDayBar(b))
                                .toList(),
                            isLast: i == 6,
                            selectedTaskId: view.selectedTaskId,
                            onSelect: onSelect,
                            onApply: onApply,
                            onOpenDay: onOpenDay,
                            projectId: projectId,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _overlapsDay(TaskBar bar, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return bar.barStart.isBefore(dayEnd) && !bar.barEnd.isBefore(dayStart);
  }
}

class _WeekHeaderRow extends StatelessWidget {
  const _WeekHeaderRow({required this.days, required this.onOpenDay});

  final List<DateTime> days;
  final ValueChanged<DateTime> onOpenDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final headerFmt = DateFormat('E\nd', l10n?.localeName);
    final now = DateTime.now();

    return Row(
      children: [
        const SizedBox(width: TimedGridMetrics.gutter),
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onOpenDay(days[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    right: i == 6
                        ? BorderSide.none
                        : BorderSide(color: scheme.outlineVariant, width: 0.5),
                  ),
                  color: _isToday(days[i], now)
                      ? scheme.primary.withValues(alpha: 0.12)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: Text(
                  headerFmt.format(days[i]),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: _isToday(days[i], now)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _isToday(days[i], now) ? scheme.primary : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static bool _isToday(DateTime day, DateTime now) =>
      day.year == now.year && day.month == now.month && day.day == now.day;
}

class _WeekAllDayRow extends StatelessWidget {
  const _WeekAllDayRow({
    required this.days,
    required this.dayBars,
    required this.onSelect,
  });

  final List<DateTime> days;
  final List<List<TaskBar>> dayBars;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: TimedGridMetrics.allDayHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: TimedGridMetrics.gutter),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: i == 6
                        ? BorderSide.none
                        : BorderSide(color: scheme.outlineVariant, width: 0.5),
                  ),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  children: [
                    for (final b in dayBars[i].where(isAllDayBar))
                      Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: _WeekAllDayChip(
                          bar: b,
                          onTap: () => onSelect(b.task.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekAllDayChip extends StatelessWidget {
  const _WeekAllDayChip({required this.bar, required this.onTap});

  final TaskBar bar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = bar.task.status == TaskStatus.complete;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('week-allday-${bar.task.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isComplete ? bar.color.withValues(alpha: 0.55) : bar.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          bar.task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: taskBarTitleStyle(isComplete: isComplete, fontSize: 10),
        ),
      ),
    );
  }
}

class _WeekTimedColumn extends ConsumerWidget {
  const _WeekTimedColumn({
    required this.day,
    required this.bars,
    required this.isLast,
    required this.selectedTaskId,
    required this.onSelect,
    required this.onApply,
    required this.onOpenDay,
    required this.projectId,
  });

  final DateTime day;
  final List<TaskBar> bars;
  final bool isLast;
  final String? selectedTaskId;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;
  final ValueChanged<DateTime> onOpenDay;
  final String? projectId;

  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final l10n = AppLocalizations.of(context);
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'create',
          child: Text(l10n?.calendarCreateTaskHere ?? 'Create task'),
        ),
        PopupMenuItem(
          value: 'open',
          child: Text(l10n?.calendarOpenDay ?? 'Open day'),
        ),
      ],
    );
    if (!context.mounted) return;
    if (selected == 'create') {
      showAddTaskSheet(
        context,
        onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
        initialStart: DateTime(day.year, day.month, day.day),
        initialDue: DateTime(day.year, day.month, day.day),
        projectId: projectId,
      );
    } else if (selected == 'open') {
      onOpenDay(day);
    }
  }

  void _onCreateAt(BuildContext context, WidgetRef ref, double localY) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final segments = bars.map((b) {
      final mins = barMinutesForDay(b, day);
      return TimedBarSegment(
        id: b.task.id,
        startMin: mins.startMin,
        endMin: mins.endMin,
      );
    }).toList();
    final placements = DayOverlapLayout.assign(segments);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const areaLeft = 2.0;
          final areaWidth = constraints.maxWidth - areaLeft - 2;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DayColumnGridPainter(
                    hourHeight: TimedGridMetrics.hourHeight,
                    lineColor: scheme.outlineVariant,
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPressStart: (d) =>
                      _onCreateAt(context, ref, d.localPosition.dy),
                  onSecondaryTapDown: (d) =>
                      _showContextMenu(context, ref, d.globalPosition),
                ),
              ),
              for (final b in bars)
                _positionedBlock(
                  bar: b,
                  day: day,
                  placement: placements[b.task.id]!,
                  areaLeft: areaLeft,
                  areaWidth: areaWidth,
                  selected: b.task.id == selectedTaskId,
                  onSelect: onSelect,
                  onApply: onApply,
                ),
            ],
          );
        },
      ),
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
