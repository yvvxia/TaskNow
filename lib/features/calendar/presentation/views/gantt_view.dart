import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/gantt_drag_intent.dart';
import '../../domain/task_bar.dart';
import '../../domain/time_axis.dart';
import '../../domain/gantt_interaction_controller.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';
import 'timeline_grid_painter.dart';

/// Self-rendered Gantt timeline: task rows (lanes) × horizontal day axis.
///
/// Supports drag-to-create on empty space, drag-to-move whole bars, and
/// drag-the-edge to resize. On mobile a long-press arms drag mode to avoid
/// fighting the scroll gesture (design §6).
class GanttView extends ConsumerWidget {
  const GanttView({super.key, required this.onSelect});

  /// Called with a task id when a bar is tapped (null to clear).
  final ValueChanged<String?> onSelect;

  static const double pxPerDay = 48;
  static const double rowHeight = 40;
  static const double headerHeight = 28;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider);

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bars) {
        final origin = DateTime(
          view.visibleRange.start.year,
          view.visibleRange.start.month,
          view.visibleRange.start.day,
        );
        final dayCount = view.visibleRange.end
                .difference(origin)
                .inDays +
            1;
        final axis = TimeAxis(origin: origin, pxPerDay: pxPerDay);
        final laneCount = bars.isEmpty
            ? 1
            : (bars.map((b) => b.rowIndex).reduce((a, b) => a > b ? a : b) + 1);
        final contentWidth = dayCount * pxPerDay;
        final bodyHeight = laneCount * rowHeight;
        final isDesktop = MediaQuery.of(context).size.width >= 600;

        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportBodyHeight = (constraints.maxHeight - headerHeight)
                .clamp(0.0, bodyHeight + 200)
                .toDouble();
            return Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Drag gestures on the timeline are reserved for
                // create/move/resize, so the timeline itself is not
                // drag-scrollable (it would otherwise steal those gestures).
                // Window navigation is handled by the prev/next controls.
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DayHeader(
                        origin: origin,
                        dayCount: dayCount,
                        pxPerDay: pxPerDay,
                        height: headerHeight,
                      ),
                      SizedBox(
                        height: viewportBodyHeight,
                        child: SingleChildScrollView(
                          child: _GanttBody(
                            bars: bars,
                            axis: axis,
                            dayCount: dayCount,
                            rowHeight: rowHeight,
                            width: contentWidth,
                            height: bodyHeight,
                            selectedTaskId: view.selectedTaskId,
                            isDesktop: isDesktop,
                            onSelect: onSelect,
                            onApply: (intent) => ref
                                .read(ganttInteractionControllerProvider.notifier)
                                .apply(intent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.origin,
    required this.dayCount,
    required this.pxPerDay,
    required this.height,
  });

  final DateTime origin;
  final int dayCount;
  final double pxPerDay;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('E\nd');
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var i = 0; i < dayCount; i++)
            SizedBox(
              width: pxPerDay,
              child: Center(
                child: Text(
                  fmt.format(origin.add(Duration(days: i))),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GanttBody extends StatefulWidget {
  const _GanttBody({
    required this.bars,
    required this.axis,
    required this.dayCount,
    required this.rowHeight,
    required this.width,
    required this.height,
    required this.selectedTaskId,
    required this.isDesktop,
    required this.onSelect,
    required this.onApply,
  });

  final List<TaskBar> bars;
  final TimeAxis axis;
  final int dayCount;
  final double rowHeight;
  final double width;
  final double height;
  final String? selectedTaskId;
  final bool isDesktop;
  final ValueChanged<String?> onSelect;
  final Future<void> Function(GanttDragIntent) onApply;

  @override
  State<_GanttBody> createState() => _GanttBodyState();
}

enum _Edge { none, start, end }

class _GanttBodyState extends State<_GanttBody> {
  static const double _handleWidth = 10;

  // Active drag bookkeeping (one bar at a time).
  String? _dragId;
  _Edge _edge = _Edge.none;
  double _dragDx = 0;
  bool _armed = false; // mobile long-press gate

  // Background create drag.
  double? _createStartDx;
  double? _createCurrentDx;

  bool get _canDrag => widget.isDesktop || _armed;

  Rect _rectFor(TaskBar bar) {
    final left = widget.axis.dateToDx(bar.barStart);
    final right = widget.axis.dateToDx(bar.barEnd) + GanttView.pxPerDay;
    final top = bar.rowIndex * widget.rowHeight;
    return Rect.fromLTRB(left, top, right, top + widget.rowHeight);
  }

  // --- Whole-bar move -------------------------------------------------------

  void _moveStart(String id) {
    if (!_canDrag) return;
    setState(() {
      _dragId = id;
      _edge = _Edge.none;
      _dragDx = 0;
    });
  }

  void _moveUpdate(DragUpdateDetails d) {
    if (_dragId == null) return;
    setState(() => _dragDx += d.primaryDelta ?? d.delta.dx);
  }

  Future<void> _moveEnd(TaskBar bar) async {
    final id = _dragId;
    final dx = _dragDx;
    setState(() {
      _dragId = null;
      _dragDx = 0;
    });
    _armed = false;
    if (id == null) return;
    final days = (dx / GanttView.pxPerDay).round();
    if (days == 0) return;
    await widget.onApply(
      MoveDrag(taskId: id, delta: Duration(days: days)),
    );
  }

  // --- Edge resize ----------------------------------------------------------

  void _resizeStart(String id, _Edge edge) {
    if (!_canDrag) return;
    setState(() {
      _dragId = id;
      _edge = edge;
      _dragDx = 0;
    });
  }

  Future<void> _resizeEnd(TaskBar bar, _Edge edge) async {
    final id = _dragId;
    final dx = _dragDx;
    final wasEdge = _edge;
    setState(() {
      _dragId = null;
      _edge = _Edge.none;
      _dragDx = 0;
    });
    _armed = false;
    if (id == null || wasEdge != edge) return;
    final anchor = edge == _Edge.start ? bar.barStart : bar.barEnd;
    final newDate = widget.axis.snapToDay(
      widget.axis.dxToDate(widget.axis.dateToDx(anchor) + dx),
    );
    await widget.onApply(
      ResizeDrag(
        taskId: id,
        edge: edge == _Edge.start ? DragEdge.start : DragEdge.end,
        newDate: newDate,
      ),
    );
  }

  // --- Background create (long-press to avoid scroll conflict) --------------

  void _createBegin(Offset local) {
    _createStartDx = local.dx;
    _createCurrentDx = local.dx;
  }

  void _createMove(Offset local) => _createCurrentDx = local.dx;

  Future<void> _createFinish() async {
    final s = _createStartDx;
    final e = _createCurrentDx;
    _createStartDx = null;
    _createCurrentDx = null;
    if (s == null || e == null) return;
    final start = widget.axis.snapToDay(widget.axis.dxToDate(s));
    final end = widget.axis.snapToDay(widget.axis.dxToDate(e));
    await widget.onApply(CreateDrag(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Grid + empty-space create + tap-to-clear selection.
          //
          // Desktop creates with a direct horizontal drag (the deeper recognizer
          // wins over the horizontal scroll view). Mobile uses a long-press so
          // plain drags are free to scroll the timeline (design §6).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onSelect(null),
              onHorizontalDragStart: widget.isDesktop
                  ? (d) => _createBegin(d.localPosition)
                  : null,
              onHorizontalDragUpdate: widget.isDesktop
                  ? (d) => _createMove(d.localPosition)
                  : null,
              onHorizontalDragEnd: widget.isDesktop ? (_) => _createFinish() : null,
              onLongPressStart: widget.isDesktop
                  ? null
                  : (d) => _createBegin(d.localPosition),
              onLongPressMoveUpdate: widget.isDesktop
                  ? null
                  : (d) => _createMove(d.localPosition),
              onLongPressEnd: widget.isDesktop ? null : (_) => _createFinish(),
              child: CustomPaint(
                painter: TimelineGridPainter(
                  dayCount: widget.dayCount,
                  pxPerDay: GanttView.pxPerDay,
                  lineColor: scheme.outlineVariant,
                ),
              ),
            ),
          ),
          for (final bar in widget.bars) _buildBar(context, bar),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, TaskBar bar) {
    final rect = _rectFor(bar);
    final selected = bar.task.id == widget.selectedTaskId;
    final dragging = _dragId == bar.task.id;
    final width =
        (rect.width - 2).clamp(GanttView.pxPerDay - 2, double.infinity);
    // Live visual offset while moving the whole bar.
    final visualLeft = rect.left + 1 + (dragging && _edge == _Edge.none ? _dragDx : 0);

    return Positioned(
      left: visualLeft,
      top: rect.top + 4,
      width: width,
      height: widget.rowHeight - 8,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(bar.task.id),
        onLongPress: widget.isDesktop ? null : () => _armed = true,
        onHorizontalDragStart: (_) => _moveStart(bar.task.id),
        onHorizontalDragUpdate: _moveUpdate,
        onHorizontalDragEnd: (_) => _moveEnd(bar),
        child: Stack(
          children: [
            Container(
              key: Key('gantt-bar-${bar.task.id}'),
              decoration: BoxDecoration(
                color: bar.isOverdue
                    ? bar.color.withValues(alpha: 0.55)
                    : bar.color,
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
            _resizeHandle(bar, _Edge.start),
            _resizeHandle(bar, _Edge.end),
          ],
        ),
      ),
    );
  }

  Widget _resizeHandle(TaskBar bar, _Edge edge) {
    return Positioned(
      left: edge == _Edge.start ? 0 : null,
      right: edge == _Edge.end ? 0 : null,
      top: 0,
      bottom: 0,
      width: _handleWidth,
      child: GestureDetector(
        key: Key('gantt-handle-${edge.name}-${bar.task.id}'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _resizeStart(bar.task.id, edge),
        onHorizontalDragUpdate: _moveUpdate,
        onHorizontalDragEnd: (_) => _resizeEnd(bar, edge),
        child: const MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
