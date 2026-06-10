import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/enums/enums.dart';
import '../../domain/gantt_drag_intent.dart';
import '../../domain/task_bar.dart';
import 'timed_grid.dart';

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
/// view instead of fighting it in the gesture arena. On mobile, a long-press is
/// required before dragging so horizontal scrolling of the timeline is not
/// blocked.
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
    this.onContextMenu,
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

  /// Desktop right-click context menu (edit / delete).
  final void Function(Offset globalPos)? onContextMenu;

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
  _Edge _pendingEdge = _Edge.none;
  int _pendingDays = 0;
  String? _pendingTaskId;
  DateTime? _pendingStart;
  DateTime? _pendingEnd;

  bool get _canDrag => widget.isDesktop || _armed;
  bool get _hasPendingPreview =>
      _pendingTaskId == widget.bar.task.id && _pendingDays != 0;

  /// Effective resize-handle width; narrowed on very short bars so the centre
  /// always remains a move zone.
  double get _effectiveHandleWidth {
    if (widget.width <= 0) return 0;
    return math.min(widget.handleWidth, widget.width / 4);
  }

  @override
  void didUpdateWidget(covariant DraggableTimelineBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingTaskId == null) return;
    if (_pendingTaskId != widget.bar.task.id) {
      _clearPendingPreview();
      return;
    }
    final pendingStart = _pendingStart;
    final pendingEnd = _pendingEnd;
    if (pendingStart != null &&
        pendingEnd != null &&
        _sameCalendarDay(widget.bar.barStart, pendingStart) &&
        _sameCalendarDay(widget.bar.barEnd, pendingEnd)) {
      _clearPendingPreview();
    }
  }

  void _start(Offset local) {
    if (!_canDrag) return;
    final w = widget.width;
    final handle = _effectiveHandleWidth;
    final _Edge edge;
    if (handle > 0 && local.dx <= handle) {
      edge = _Edge.start;
    } else if (handle > 0 && local.dx >= w - handle) {
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

  void _updateFromLongPress(LongPressMoveUpdateDetails d) {
    if (!_dragging) return;
    setState(() => _dragDx = d.offsetFromOrigin.dx);
  }

  void _cancel() {
    if (!_dragging && !_armed) return;
    setState(() {
      _dragging = false;
      _armed = false;
      _edge = _Edge.none;
      _dragDx = 0;
    });
  }

  Future<void> _end() async {
    final dx = _dragDx;
    final edge = _edge;
    final wasDragging = _dragging;
    if (!wasDragging) {
      _armed = false;
      return;
    }

    final id = widget.bar.task.id;
    final days = _clampedDays(edge, (dx / widget.pxPerDay).round());
    setState(() {
      _dragging = false;
      _armed = false;
      _edge = _Edge.none;
      _dragDx = 0;
      if (days == 0) {
        _clearPendingPreview();
      } else {
        _setPendingPreview(id, edge, days);
      }
    });
    if (days == 0) return;

    if (edge == _Edge.none) {
      try {
        await widget.onApply(
          MoveDrag(
            taskId: id,
            delta: Duration(days: days),
          ),
        );
      } catch (_) {
        if (mounted) setState(_clearPendingPreview);
        rethrow;
      }
      return;
    }

    final anchor = edge == _Edge.start
        ? widget.bar.barStart
        : widget.bar.barEnd;
    try {
      await widget.onApply(
        ResizeDrag(
          taskId: id,
          edge: edge == _Edge.start ? DragEdge.start : DragEdge.end,
          newDate: anchor.add(Duration(days: days)),
        ),
      );
    } catch (_) {
      if (mounted) setState(_clearPendingPreview);
      rethrow;
    }
  }

  int _clampedDays(_Edge edge, int days) {
    if (edge == _Edge.none || days == 0) return days;
    final spanDays = math.max(
      1,
      _dateOnly(
            widget.bar.barEnd,
          ).difference(_dateOnly(widget.bar.barStart)).inDays +
          1,
    );
    return switch (edge) {
      _Edge.start => math.min(days, spanDays - 1),
      _Edge.end => math.max(days, 1 - spanDays),
      _Edge.none => days,
    };
  }

  void _setPendingPreview(String taskId, _Edge edge, int days) {
    _pendingTaskId = taskId;
    _pendingEdge = edge;
    _pendingDays = days;
    switch (edge) {
      case _Edge.none:
        _pendingStart = widget.bar.barStart.add(Duration(days: days));
        _pendingEnd = widget.bar.barEnd.add(Duration(days: days));
      case _Edge.start:
        _pendingStart = widget.bar.barStart.add(Duration(days: days));
        _pendingEnd = widget.bar.barEnd;
      case _Edge.end:
        _pendingStart = widget.bar.barStart;
        _pendingEnd = widget.bar.barEnd.add(Duration(days: days));
    }
  }

  void _clearPendingPreview() {
    _pendingTaskId = null;
    _pendingEdge = _Edge.none;
    _pendingDays = 0;
    _pendingStart = null;
    _pendingEnd = null;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  ({double left, double width}) _applyPreviewGeometry({
    required double left,
    required double width,
    required _Edge edge,
    required int days,
  }) {
    final snapped = days * widget.pxPerDay;
    switch (edge) {
      case _Edge.none:
        left += snapped;
      case _Edge.start:
        left += snapped;
        width -= snapped;
      case _Edge.end:
        width += snapped;
    }
    return (left: left, width: width.clamp(widget.minWidthPx, double.infinity));
  }

  @override
  Widget build(BuildContext context) {
    var left = widget.left;
    var width = widget.width;
    if (_dragging) {
      final preview = _applyPreviewGeometry(
        left: left,
        width: width,
        edge: _edge,
        days: _clampedDays(_edge, (_dragDx / widget.pxPerDay).round()),
      );
      left = preview.left;
      width = preview.width;
    } else if (_hasPendingPreview) {
      final preview = _applyPreviewGeometry(
        left: left,
        width: width,
        edge: _pendingEdge,
        days: _pendingDays,
      );
      left = preview.left;
      width = preview.width;
    }

    final handle = _effectiveHandleWidth;

    return Positioned(
      left: left,
      top: widget.top,
      width: width,
      height: widget.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.isDesktop
            ? () => widget.onSelect(widget.bar.task.id)
            : null,
        onLongPressStart: widget.isDesktop
            ? null
            : (d) {
                HapticFeedback.mediumImpact();
                setState(() => _armed = true);
                _start(d.localPosition);
              },
        onLongPressMoveUpdate: widget.isDesktop ? null : _updateFromLongPress,
        onLongPressEnd: widget.isDesktop ? null : (_) => _end(),
        onLongPressCancel: widget.isDesktop ? null : _cancel,
        onSecondaryTapDown: widget.isDesktop && widget.onContextMenu != null
            ? (d) => widget.onContextMenu!(d.globalPosition)
            : null,
        onHorizontalDragStart: widget.isDesktop
            ? (d) => _start(d.localPosition)
            : null,
        onHorizontalDragUpdate: widget.isDesktop ? _update : null,
        onHorizontalDragEnd: widget.isDesktop ? (_) => _end() : null,
        onHorizontalDragCancel: widget.isDesktop ? _cancel : null,
        child: Stack(
          children: [
            _body(context),
            if (handle > 0) _handle(_Edge.start, handle),
            if (handle > 0) _handle(_Edge.end, handle),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final bar = widget.bar;
    final isComplete = bar.task.status == TaskStatus.complete;
    final active = _armed || _dragging || _hasPendingPreview;
    final body = Container(
      key: widget.barKey ?? Key('timeline-bar-${bar.task.id}'),
      decoration: BoxDecoration(
        color: isComplete
            ? bar.color.withValues(alpha: 0.55)
            : bar.isOverdue
            ? bar.color.withValues(alpha: 0.55)
            : bar.color,
        borderRadius: BorderRadius.circular(6),
        border: widget.selected
            ? Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              )
            : null,
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        bar.task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: taskBarTitleStyle(isComplete: isComplete),
      ),
    );
    if (!active) return body;
    return Transform.scale(
      scale: 1.03,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(6),
        color: Colors.transparent,
        child: body,
      ),
    );
  }

  /// Edge affordance: a bare [MouseRegion] shows a resize cursor on desktop. It
  /// never joins the gesture arena, so the drag still falls through to the
  /// bar's single horizontal-drag recognizer (which decides move vs resize by
  /// where the drag began).
  Widget _handle(_Edge edge, double width) {
    return Positioned(
      key: Key('timeline-handle-${edge.name}-${widget.bar.task.id}'),
      left: edge == _Edge.start ? 0 : null,
      right: edge == _Edge.end ? 0 : null,
      top: 0,
      bottom: 0,
      width: width,
      child: const MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: SizedBox.expand(),
      ),
    );
  }
}
