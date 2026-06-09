import 'package:flutter/material.dart';

import '../../domain/gantt_drag_intent.dart';
import '../../domain/task_bar.dart';

/// A task bar on a horizontal day timeline (Gantt / week swimlane) that can be
/// dragged to move the whole task or dragged by its edges to resize it.
///
/// The widget renders its own [Positioned] inside the caller's [Stack] given a
/// base [left]/[width]/[top]/[height] (in pixels). Drags snap to whole days:
/// the live preview jumps day-by-day under the cursor and the same rounded
/// delta is what gets persisted via [onApply]. A drag that stays on the same
/// day (rounded delta 0) is a no-op; any cross-day drag always applies (no
/// snap-back).
///
/// Horizontal-drag recognizers (not pan) are used so the bar competes only on
/// the horizontal axis and wins cleanly against any surrounding vertical scroll
/// view instead of fighting it in the gesture arena.
class DraggableTimelineBar extends StatefulWidget {
  const DraggableTimelineBar({
    super.key,
    required this.bar,
    required this.pxPerDay,
    required this.left,
    required this.width,
    required this.top,
    required this.height,
    required this.selected,
    required this.isDesktop,
    required this.onSelect,
    required this.onApply,
    this.barKey,
    this.handleWidth = 14,
    double? minWidthPx,
  }) : minWidthPx = minWidthPx ?? pxPerDay - 2;

  final TaskBar bar;

  /// Optional key for the inner colored bar body (kept per-view for tests).
  final Key? barKey;

  /// Horizontal pixels per calendar day on this timeline.
  final double pxPerDay;

  /// Base geometry (before any live drag offset), in pixels.
  final double left;
  final double width;
  final double top;
  final double height;

  final bool selected;
  final bool isDesktop;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;

  /// Grab-zone width at each end that triggers a resize instead of a move.
  final double handleWidth;

  /// Minimum rendered width while resizing (defaults to one day minus 2px).
  final double minWidthPx;

  @override
  State<DraggableTimelineBar> createState() => _DraggableTimelineBarState();
}

enum _Edge { none, start, end }

class _DraggableTimelineBarState extends State<DraggableTimelineBar> {
  _Edge _edge = _Edge.none;
  double _dragDx = 0;
  bool _dragging = false;
  bool _armed = false; // mobile long-press gate

  bool get _canDrag => widget.isDesktop || _armed;

  void _start(Offset local) {
    if (!_canDrag) return;
    final w = widget.width;
    final _Edge edge;
    if (local.dx <= widget.handleWidth) {
      edge = _Edge.start;
    } else if (local.dx >= w - widget.handleWidth) {
      edge = _Edge.end;
    } else {
      edge = _Edge.none;
    }
    setState(() {
      _dragging = true;
      _edge = edge;
      _dragDx = 0;
    });
  }

  void _update(DragUpdateDetails d) {
    if (!_dragging) return;
    setState(() => _dragDx += d.primaryDelta ?? d.delta.dx);
  }

  Future<void> _end() async {
    final dx = _dragDx;
    final edge = _edge;
    final wasDragging = _dragging;
    setState(() {
      _dragging = false;
      _edge = _Edge.none;
      _dragDx = 0;
    });
    _armed = false;
    if (!wasDragging) return;

    final days = (dx / widget.pxPerDay).round();
    if (days == 0) return;

    final id = widget.bar.task.id;
    if (edge == _Edge.none) {
      await widget.onApply(
        MoveDrag(
          taskId: id,
          delta: Duration(days: days),
        ),
      );
      return;
    }

    final anchor = edge == _Edge.start
        ? widget.bar.barStart
        : widget.bar.barEnd;
    await widget.onApply(
      ResizeDrag(
        taskId: id,
        edge: edge == _Edge.start ? DragEdge.start : DragEdge.end,
        newDate: anchor.add(Duration(days: days)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.left;
    var width = widget.width;
    if (_dragging) {
      final snapped = (_dragDx / widget.pxPerDay).round() * widget.pxPerDay;
      switch (_edge) {
        case _Edge.none:
          left += snapped;
        case _Edge.start:
          left += snapped;
          width -= snapped;
        case _Edge.end:
          width += snapped;
      }
      width = width.clamp(widget.minWidthPx, double.infinity);
    }

    return Positioned(
      left: left,
      top: widget.top,
      width: width,
      height: widget.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(widget.bar.task.id),
        onLongPress: widget.isDesktop ? null : () => _armed = true,
        onHorizontalDragStart: (d) => _start(d.localPosition),
        onHorizontalDragUpdate: _update,
        onHorizontalDragEnd: (_) => _end(),
        child: Stack(
          children: [_body(context), _handle(_Edge.start), _handle(_Edge.end)],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final bar = widget.bar;
    return Container(
      key: widget.barKey ?? Key('timeline-bar-${bar.task.id}'),
      decoration: BoxDecoration(
        color: bar.isOverdue ? bar.color.withValues(alpha: 0.55) : bar.color,
        borderRadius: BorderRadius.circular(6),
        border: widget.selected
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
    );
  }

  /// Edge affordance: a bare [MouseRegion] shows a resize cursor on desktop. It
  /// never joins the gesture arena, so the drag still falls through to the
  /// bar's single horizontal-drag recognizer (which decides move vs resize by
  /// where the drag began).
  Widget _handle(_Edge edge) {
    return Positioned(
      key: Key('timeline-handle-${edge.name}-${widget.bar.task.id}'),
      left: edge == _Edge.start ? 0 : null,
      right: edge == _Edge.end ? 0 : null,
      top: 0,
      bottom: 0,
      width: widget.handleWidth,
      child: const MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: SizedBox.expand(),
      ),
    );
  }
}
