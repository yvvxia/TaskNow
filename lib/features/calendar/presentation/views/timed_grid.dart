import 'package:flutter/material.dart';

import '../../../../core/enums/enums.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/task_bar.dart';

/// Shared constants for day/week timed grids.
abstract final class TimedGridMetrics {
  static const double hourHeight = 48;
  static const double gutter = 56;
  static const double allDayHeight = 40;
  static const int snapMinutes = 15;
  static const double blockGap = 2;
}

/// Paints a 24-hour vertical axis with hour labels in the left gutter.
class HourAxisPainter extends CustomPainter {
  HourAxisPainter({
    required this.hourHeight,
    required this.lineColor,
    required this.labelStyle,
    this.drawGridLines = true,
    this.gridStartX = 0,
  });

  final double hourHeight;
  final Color lineColor;
  final TextStyle labelStyle;
  final bool drawGridLines;
  final double gridStartX;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var h = 0; h < 24; h++) {
      final y = h * hourHeight;
      if (drawGridLines) {
        canvas.drawLine(Offset(gridStartX, y), Offset(size.width, y), line);
      }
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
  bool shouldRepaint(covariant HourAxisPainter oldDelegate) =>
      oldDelegate.hourHeight != hourHeight ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.drawGridLines != drawGridLines ||
      oldDelegate.gridStartX != gridStartX;
}

/// Paints hour lines inside a day column (no labels).
class DayColumnGridPainter extends CustomPainter {
  DayColumnGridPainter({required this.hourHeight, required this.lineColor});

  final double hourHeight;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var h = 0; h < 24; h++) {
      final y = h * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant DayColumnGridPainter oldDelegate) =>
      oldDelegate.hourHeight != hourHeight ||
      oldDelegate.lineColor != lineColor;
}

/// Title style for a task bar, including completed strikethrough.
TextStyle taskBarTitleStyle({
  required bool isComplete,
  double fontSize = 12,
  Color color = Colors.white,
}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    decoration: isComplete ? TextDecoration.lineThrough : null,
    decorationColor: color,
    decorationThickness: 1.5,
  );
}

/// Computes horizontal bounds for a block within an overlap layout.
({double left, double width}) overlapBlockBounds({
  required double areaLeft,
  required double areaWidth,
  required int column,
  required int columns,
}) {
  final columnWidth = areaWidth / columns;
  final left = areaLeft + column * columnWidth + TimedGridMetrics.blockGap;
  final width = columnWidth - TimedGridMetrics.blockGap * 2;
  return (left: left, width: width.clamp(0, double.infinity));
}

/// A timed task block on the hour grid. Long-press to move (middle) or resize
/// (top/bottom edge). Tap opens task detail.
class TimedTaskBlock extends StatefulWidget {
  const TimedTaskBlock({
    super.key,
    required this.bar,
    required this.day,
    required this.selected,
    required this.onSelect,
    required this.onApply,
    required this.left,
    required this.width,
  });

  final TaskBar bar;
  final DateTime day;
  final bool selected;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;
  final double left;
  final double width;

  @override
  State<TimedTaskBlock> createState() => _TimedTaskBlockState();
}

enum _VEdge { none, top, bottom }

class _TimedTaskBlockState extends State<TimedTaskBlock> {
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

  double get baseTop => _startMin / 60 * TimedGridMetrics.hourHeight;

  double get baseHeight =>
      ((_endMin - _startMin) / 60 * TimedGridMetrics.hourHeight).clamp(
        24.0,
        24 * TimedGridMetrics.hourHeight,
      );

  void _pressStart(Offset local) {
    final h = baseHeight;
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

    final rawMinutes = (dy / TimedGridMetrics.hourHeight * 60).round();
    final snapped = snapMinutes(rawMinutes, TimedGridMetrics.snapMinutes);
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
    var top = baseTop;
    var height = baseHeight;
    if (_dragging) {
      final snappedMinutes = snapMinutes(
        (_dragDy / TimedGridMetrics.hourHeight * 60).round(),
        TimedGridMetrics.snapMinutes,
      );
      final snappedDy = snappedMinutes / 60 * TimedGridMetrics.hourHeight;
      switch (_edge) {
        case _VEdge.none:
          top += snappedDy;
        case _VEdge.top:
          top += snappedDy;
          height -= snappedDy;
        case _VEdge.bottom:
          height += snappedDy;
      }
      height = height.clamp(24.0, 24 * TimedGridMetrics.hourHeight);
    }

    final isComplete = widget.bar.task.status == TaskStatus.complete;

    return Positioned(
      left: widget.left,
      width: widget.width,
      top: top,
      height: height,
      child: GestureDetector(
        onTap: () => widget.onSelect(widget.bar.task.id),
        onLongPressStart: (d) => _pressStart(d.localPosition),
        onLongPressMoveUpdate: _pressMove,
        onLongPressEnd: (_) => _pressEnd(),
        child: Container(
          key: Key('timed-block-${widget.bar.task.id}'),
          decoration: BoxDecoration(
            color: isComplete
                ? widget.bar.color.withValues(alpha: 0.55)
                : widget.bar.color,
            borderRadius: BorderRadius.circular(6),
            border: widget.selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          alignment: Alignment.topLeft,
          child: Text(
            widget.bar.task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: taskBarTitleStyle(isComplete: isComplete),
          ),
        ),
      ),
    );
  }
}

int snapMinutes(int minutes, int step) {
  if (step <= 0) return minutes;
  return (minutes / step).round() * step;
}

/// Computes [startMin] and [endMin] for a [TaskBar] clipped to [day].
({int startMin, int endMin}) barMinutesForDay(TaskBar bar, DateTime day) {
  final s = bar.barStart.toLocal();
  final e = bar.barEnd.toLocal();
  final dayEnd = day.add(const Duration(days: 1));
  final startMin = s.isBefore(day) ? 0 : s.hour * 60 + s.minute;
  final endMin = !e.isBefore(dayEnd) ? 24 * 60 : e.hour * 60 + e.minute;
  return (startMin: startMin, endMin: endMin);
}

/// A task is all-day when both local start and end are at local midnight.
bool isAllDayBar(TaskBar bar) {
  final s = bar.barStart.toLocal();
  final e = bar.barEnd.toLocal();
  return s.hour == 0 && s.minute == 0 && e.hour == 0 && e.minute == 0;
}
