/// Which edge of a bar a [ResizeDrag] operates on.
enum DragEdge { start, end }

/// A user drag gesture on the Gantt / timeline, resolved to an intent that
/// [GanttInteractionController] applies against the repository.
sealed class GanttDragIntent {
  const GanttDragIntent();
}

/// Drag over empty space: create a new task spanning [start]..[end].
final class CreateDrag extends GanttDragIntent {
  const CreateDrag({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Drag a whole bar: shift both start and due by [delta], preserving duration.
final class MoveDrag extends GanttDragIntent {
  const MoveDrag({required this.taskId, required this.delta});

  final String taskId;
  final Duration delta;
}

/// Drag a bar edge: move one boundary ([edge]) to [newDate].
final class ResizeDrag extends GanttDragIntent {
  const ResizeDrag({
    required this.taskId,
    required this.edge,
    required this.newDate,
  });

  final String taskId;
  final DragEdge edge;
  final DateTime newDate;
}
