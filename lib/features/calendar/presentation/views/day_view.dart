import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../task/presentation/add_task_sheet.dart';
import '../../../task/task_providers.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/gantt_interaction_controller.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';

/// Drag payload for moving an all-day chip onto the timed grid.
class _AllDayDragData {
  const _AllDayDragData(this.taskId, this.currentStartLocal);
  final String taskId;
  final DateTime currentStartLocal;
}

/// Day view: a 24-hour vertical axis in **local** time.
///
/// Tasks with a local midnight start/end render in the top all-day band.
/// Timed tasks render as blocks on the hour grid. Long-press a block to move
/// it vertically (whole block) or near its top/bottom edge to resize start/end.
/// Deltas snap to [snapMinutes] while dragging. All-day chips can be dragged
/// onto the grid to assign a concrete time.
class DayView extends ConsumerWidget {
  const DayView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  static const double hourHeight = 48;
  static const double gutter = 56;
  static const double allDayHeight = 40;

  /// Vertical drag snaps to this many minutes (15 = quarter-hour grid).
  static const int snapMinutes = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider(projectId));
    final day = DateTime(view.anchor.year, view.anchor.month, view.anchor.day);
    final nextDay = day.add(const Duration(days: 1));
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    Future<void> onApply(GanttDragIntent intent) =>
        ref.read(ganttInteractionControllerProvider.notifier).apply(intent);
    void onCreateAt(double localY) {
      final minutes = _snapMinutes(
        (localY / hourHeight * 60).round(),
        snapMinutes,
      ).clamp(0, 24 * 60 - snapMinutes);
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
        final allDay = dayBars.where((b) => _isAllDay(b)).toList();
        final timed = dayBars.where((b) => !_isAllDay(b)).toList();
        final scheme = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allDay.isNotEmpty)
              SizedBox(
                height: allDayHeight,
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
                  height: 24 * hourHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HourGridPainter(
                            hourHeight: hourHeight,
                            gutter: gutter,
                            lineColor: scheme.outlineVariant,
                            labelStyle:
                                Theme.of(context).textTheme.labelSmall ??
                                const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      // Tap empty grid space to create a timed task at that
                      // time. Sits below the blocks (which handle their own
                      // taps) and below the drop target (which only reacts to
                      // dragged chips), so empty taps fall through to here.
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: (d) => onCreateAt(d.localPosition.dy),
                        ),
                      ),
                      Positioned.fill(
                        child: _TimedGridDropTarget(day: day, onApply: onApply),
                      ),
                      for (final b in timed)
                        _DayBlock(
                          bar: b,
                          day: day,
                          selected: b.task.id == view.selectedTaskId,
                          onSelect: onSelect,
                          onApply: onApply,
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

  /// A task is all-day when both local start and end are at local midnight
  /// (date-only tasks created via the date picker).
  static bool _isAllDay(TaskBar bar) {
    final s = bar.barStart.toLocal();
    final e = bar.barEnd.toLocal();
    return s.hour == 0 && s.minute == 0 && e.hour == 0 && e.minute == 0;
  }
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
        final minutes = _snapMinutes(
          (localY / DayView.hourHeight * 60).round(),
          DayView.snapMinutes,
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

/// A timed task block on the day grid. Long-press to arm, then drag vertically
/// to move (middle) or resize (top/bottom edge). Snaps live to [DayView.snapMinutes].
class _DayBlock extends StatefulWidget {
  const _DayBlock({
    required this.bar,
    required this.day,
    required this.selected,
    required this.onSelect,
    required this.onApply,
  });

  final TaskBar bar;
  final DateTime day;
  final bool selected;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;

  @override
  State<_DayBlock> createState() => _DayBlockState();
}

enum _VEdge { none, top, bottom }

class _DayBlockState extends State<_DayBlock> {
  static const double _handleHeight = 12;

  _VEdge _edge = _VEdge.none;
  double _dragDy = 0;
  bool _dragging = false;

  int get _startMin {
    final s = widget.bar.barStart.toLocal();
    if (s.isBefore(widget.day)) return 0;
    return s.hour * 60 + s.minute;
  }

  int get _endMin {
    final e = widget.bar.barEnd.toLocal();
    final dayEnd = widget.day.add(const Duration(days: 1));
    if (!e.isBefore(dayEnd)) return 24 * 60;
    return e.hour * 60 + e.minute;
  }

  double get _baseTop => _startMin / 60 * DayView.hourHeight;
  double get _baseHeight => ((_endMin - _startMin) / 60 * DayView.hourHeight)
      .clamp(24.0, 24 * DayView.hourHeight);

  void _pressStart(Offset local) {
    final h = _baseHeight;
    final _VEdge edge;
    if (local.dy <= _handleHeight) {
      edge = _VEdge.top;
    } else if (local.dy >= h - _handleHeight) {
      edge = _VEdge.bottom;
    } else {
      edge = _VEdge.none;
    }
    setState(() {
      _dragging = true;
      _edge = edge;
      _dragDy = 0;
    });
  }

  void _pressMove(LongPressMoveUpdateDetails d) {
    if (!_dragging) return;
    setState(() => _dragDy = d.localOffsetFromOrigin.dy);
  }

  Future<void> _pressEnd() async {
    final dy = _dragDy;
    final edge = _edge;
    setState(() {
      _dragging = false;
      _edge = _VEdge.none;
      _dragDy = 0;
    });

    final rawMinutes = (dy / DayView.hourHeight * 60).round();
    final snapped = _snapMinutes(rawMinutes, DayView.snapMinutes);
    if (snapped == 0) return;

    final id = widget.bar.task.id;
    if (edge == _VEdge.none) {
      await widget.onApply(
        MoveDrag(
          taskId: id,
          delta: Duration(minutes: snapped),
        ),
      );
      return;
    }

    final anchor = edge == _VEdge.top
        ? widget.bar.barStart.toLocal()
        : widget.bar.barEnd.toLocal();
    final newLocal = anchor.add(Duration(minutes: snapped));
    await widget.onApply(
      ResizeDrag(
        taskId: id,
        edge: edge == _VEdge.top ? DragEdge.start : DragEdge.end,
        newDate: newLocal.toUtc(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var top = _baseTop;
    var height = _baseHeight;
    if (_dragging) {
      final snappedMinutes = _snapMinutes(
        (_dragDy / DayView.hourHeight * 60).round(),
        DayView.snapMinutes,
      );
      final snappedDy = snappedMinutes / 60 * DayView.hourHeight;
      switch (_edge) {
        case _VEdge.none:
          top += snappedDy;
        case _VEdge.top:
          top += snappedDy;
          height -= snappedDy;
        case _VEdge.bottom:
          height += snappedDy;
      }
      height = height.clamp(24.0, 24 * DayView.hourHeight);
    }

    return Positioned(
      left: DayView.gutter + 4,
      right: 8,
      top: top,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onSelect(widget.bar.task.id),
        onLongPressStart: (d) => _pressStart(d.localPosition),
        onLongPressMoveUpdate: _pressMove,
        onLongPressEnd: (_) => _pressEnd(),
        child: Container(
          key: Key('day-block-${widget.bar.task.id}'),
          decoration: BoxDecoration(
            color: widget.bar.color,
            borderRadius: BorderRadius.circular(6),
            border: widget.selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.topLeft,
          child: Text(
            widget.bar.task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
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
    final chip = Container(
      key: Key('day-allday-${bar.task.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bar.color,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        bar.task.title,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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

int _snapMinutes(int minutes, int step) {
  if (step <= 0) return minutes;
  return (minutes / step).round() * step;
}

class _HourGridPainter extends CustomPainter {
  _HourGridPainter({
    required this.hourHeight,
    required this.gutter,
    required this.lineColor,
    required this.labelStyle,
  });

  final double hourHeight;
  final double gutter;
  final Color lineColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var h = 0; h < 24; h++) {
      final y = h * hourHeight;
      canvas.drawLine(Offset(gutter, y), Offset(size.width, y), line);
      final tp = TextPainter(
        text: TextSpan(
          text: '${h.toString().padLeft(2, '0')}:00',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _HourGridPainter oldDelegate) =>
      oldDelegate.hourHeight != hourHeight ||
      oldDelegate.lineColor != lineColor;
}
