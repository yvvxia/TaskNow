import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/task_bar.dart';
import '../../domain/time_axis.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';
import 'timeline_grid_painter.dart';

/// Week view: 7 day columns with a top "all-day" swimlane where multi-day
/// task bars span across columns in greedy lanes (design §4).
class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.onSelect});

  final ValueChanged<String?> onSelect;

  static const double laneHeight = 34;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider);
    final origin = DateTime(
      view.visibleRange.start.year,
      view.visibleRange.start.month,
      view.visibleRange.start.day,
    );

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bars) {
        return LayoutBuilder(
          builder: (context, constraints) {
            const dayCount = 7;
            final colWidth = constraints.maxWidth / dayCount;
            final axis = TimeAxis(origin: origin, pxPerDay: colWidth);
            final laneCount = bars.isEmpty
                ? 1
                : (bars
                        .map((b) => b.rowIndex)
                        .reduce((a, b) => a > b ? a : b) +
                    1);
            final scheme = Theme.of(context).colorScheme;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WeekHeader(origin: origin, colWidth: colWidth),
                SizedBox(
                  height: laneCount * laneHeight + 8,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TimelineGridPainter(
                            dayCount: dayCount,
                            pxPerDay: colWidth,
                            lineColor: scheme.outlineVariant,
                            weekendShade: scheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      for (final bar in bars)
                        _WeekBar(
                          bar: bar,
                          axis: axis,
                          colWidth: colWidth,
                          selected: bar.task.id == view.selectedTaskId,
                          onTap: () => onSelect(bar.task.id),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(null),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        '${bars.length} task(s) this week',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.origin, required this.colWidth});

  final DateTime origin;
  final double colWidth;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('E d');
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            SizedBox(
              width: colWidth,
              child: Center(
                child: Text(
                  fmt.format(origin.add(Duration(days: i))),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({
    required this.bar,
    required this.axis,
    required this.colWidth,
    required this.selected,
    required this.onTap,
  });

  final TaskBar bar;
  final TimeAxis axis;
  final double colWidth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final left = axis.dateToDx(bar.barStart).clamp(0.0, 7 * colWidth);
    final rawRight = axis.dateToDx(bar.barEnd) + colWidth;
    final right = rawRight.clamp(0.0, 7 * colWidth);
    final width = (right - left).clamp(colWidth * 0.5, 7 * colWidth);
    final top = bar.rowIndex * WeekView.laneHeight + 4;

    return Positioned(
      left: left + 1,
      top: top,
      width: width - 2,
      height: WeekView.laneHeight - 6,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          key: Key('week-bar-${bar.task.id}'),
          decoration: BoxDecoration(
            color: bar.isOverdue ? bar.color.withValues(alpha: 0.55) : bar.color,
            borderRadius: BorderRadius.circular(6),
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.centerLeft,
          child: Text(
            bar.task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
