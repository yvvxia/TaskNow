import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../task/presentation/add_task_sheet.dart';
import '../../../task/task_providers.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/gantt_interaction_controller.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';
import 'timed_grid.dart';

/// Payload for dragging a month chip: which task, and the day cell it was
/// grabbed from (so the drop computes a whole-day shift).
class _MonthDragData {
  const _MonthDragData(this.taskId, this.sourceDay);
  final String taskId;
  final DateTime sourceDay;
}

/// Month grid view. Each day cell shows up to a height-dependent number of
/// short task bars; remaining tasks collapse into a "+k more" affordance
/// (design §4).
class MonthView extends ConsumerWidget {
  const MonthView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  static const double _dayLabelHeight = 18;
  static const double _chipHeight = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider(projectId));

    final month = DateTime(view.anchor.year, view.anchor.month);
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final gridStart = DateTime(
      firstOfMonth.year,
      firstOfMonth.month,
      firstOfMonth.day - (firstOfMonth.weekday - DateTime.monday),
    );
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastOfMonth = DateTime(month.year, month.month, daysInMonth);
    final totalDays = lastOfMonth.difference(gridStart).inDays + 1;
    final weeks = (totalDays / 7).ceil();
    final cellCount = weeks * 7;

    final isDesktop = MediaQuery.of(context).size.width >= 600;
    Future<void> onApply(GanttDragIntent intent) =>
        ref.read(ganttInteractionControllerProvider.notifier).apply(intent);
    void onCreateInDay(DateTime day) => showAddTaskSheet(
      context,
      onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
      initialStart: day,
      initialDue: day,
      projectId: projectId,
    );
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekdayHeader(
              localeName: AppLocalizations.of(context)?.localeName,
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                ),
                itemCount: cellCount,
                itemBuilder: (context, index) {
                  final day = DateTime(
                    gridStart.year,
                    gridStart.month,
                    gridStart.day + index,
                  );
                  final inMonth = day.month == month.month;
                  final dayBars = bars
                      .where((b) => _overlapsDay(b, day))
                      .toList();
                  return _DayCell(
                    day: day,
                    inMonth: inMonth,
                    bars: dayBars,
                    isDesktop: isDesktop,
                    onSelect: onSelect,
                    onApply: onApply,
                    onCreateInDay: onCreateInDay,
                    onOpenDay: onOpenDay,
                  );
                },
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({this.localeName});

  final String? localeName;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime.utc(2026, 1, 5);
    final fmt = DateFormat.E(localeName);
    final labels = [
      for (var i = 0; i < 7; i++) fmt.format(monday.add(Duration(days: i))),
    ];
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.bars,
    required this.isDesktop,
    required this.onSelect,
    required this.onApply,
    required this.onCreateInDay,
    required this.onOpenDay,
  });

  final DateTime day;
  final bool inMonth;
  final List<TaskBar> bars;
  final bool isDesktop;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;
  final ValueChanged<DateTime> onCreateInDay;
  final ValueChanged<DateTime> onOpenDay;

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
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
    if (selected == 'create') {
      onCreateInDay(DateTime(day.year, day.month, day.day));
    } else if (selected == 'open') {
      onOpenDay(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cellDay = DateTime(day.year, day.month, day.day);
    return DragTarget<_MonthDragData>(
      onAcceptWithDetails: (details) {
        final days = cellDay.difference(details.data.sourceDay).inDays;
        if (days != 0) {
          onApply(
            MoveDrag(
              taskId: details.data.taskId,
              delta: Duration(days: days),
            ),
          );
        }
      },
      builder: (context, candidate, rejected) {
        final highlighted = candidate.isNotEmpty;
        // Tapping empty space in the cell opens the day view for that day.
        // Right-click (secondary tap) opens a menu to create a task. Taps on a
        // chip are handled by the chip's own gesture detector (deeper in the
        // tree wins the tap), so this only fires for blank areas.
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => onOpenDay(cellDay),
          onSecondaryTapDown: (d) =>
              _showContextMenu(context, d.globalPosition),
          onLongPressStart: isDesktop
              ? null
              : (d) => _showContextMenu(context, d.globalPosition),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: highlighted ? scheme.primary : scheme.outlineVariant,
                width: highlighted ? 1.5 : 0.5,
              ),
              color: highlighted
                  ? scheme.primary.withValues(alpha: 0.08)
                  : inMonth
                  ? null
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.all(2),
            child: _cellContent(context),
          ),
        );
      },
    );
  }

  Widget _cellContent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: MonthView._dayLabelHeight,
          child: Row(
            children: [
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: inMonth ? FontWeight.bold : FontWeight.normal,
                  color: inMonth ? null : scheme.onSurfaceVariant,
                ),
              ),
              if (bars.length > 1) ...[
                const Spacer(),
                Text(
                  '${bars.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Scroll within the cell so every task is reachable even when there
        // are more than the cell can show at once.
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false, overscroll: false),
            child: ListView(
              padding: EdgeInsets.zero,
              primary: false,
              children: [
                for (final bar in bars)
                  _MiniBar(
                    bar: bar,
                    day: day,
                    isDesktop: isDesktop,
                    onTap: () => onSelect(bar.task.id),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.bar,
    required this.day,
    required this.isDesktop,
    required this.onTap,
  });

  final TaskBar bar;
  final DateTime day;
  final bool isDesktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isComplete = bar.task.status == TaskStatus.complete;
    final chip = Container(
      key: Key('month-bar-${bar.task.id}'),
      height: MonthView._chipHeight - 3,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isComplete
            ? bar.color.withValues(alpha: 0.55)
            : bar.isOverdue
            ? bar.color.withValues(alpha: 0.55)
            : bar.color,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        bar.task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: taskBarTitleStyle(isComplete: isComplete, fontSize: 9),
      ),
    );

    final data = _MonthDragData(
      bar.task.id,
      DateTime(day.year, day.month, day.day),
    );
    final feedback = Material(
      color: Colors.transparent,
      child: Opacity(opacity: 0.9, child: SizedBox(width: 110, child: chip)),
    );
    final whileDragging = Opacity(opacity: 0.3, child: chip);
    final tappable = GestureDetector(onTap: onTap, child: chip);

    // Desktop: drag immediately with the mouse. Touch: long-press to arm so
    // plain drags still scroll the month grid (matches the timeline views).
    if (isDesktop) {
      return Draggable<_MonthDragData>(
        data: data,
        feedback: feedback,
        childWhenDragging: whileDragging,
        child: tappable,
      );
    }
    return LongPressDraggable<_MonthDragData>(
      data: data,
      feedback: feedback,
      childWhenDragging: whileDragging,
      child: tappable,
    );
  }
}

/// Formats the month label, e.g. "June 2026". Exposed for the header.
String monthLabel(DateTime anchor, [String? localeName]) =>
    DateFormat.yMMMM(localeName).format(anchor);
