import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/providers.dart';
import '../../../core/models/task.dart';
import '../../../core/models/task_draft.dart';
import '../../task/task_providers.dart';
import 'gantt_drag_intent.dart';

part 'gantt_interaction_controller.g.dart';

/// Applies [GanttDragIntent]s against the task repository via the module-02
/// create/update use cases. Invalid intents (`start > due`) are dropped so the
/// UI snaps the bar back without persisting anything.
@riverpod
class GanttInteractionController extends _$GanttInteractionController {
  @override
  void build() {}

  Future<void> apply(GanttDragIntent intent) async {
    switch (intent) {
      case CreateDrag(:final start, :final end):
        await _create(start, end);
      case MoveDrag(:final taskId, :final delta):
        await _move(taskId, delta);
      case ResizeDrag(:final taskId, :final edge, :final newDate):
        await _resize(taskId, edge, newDate);
    }
  }

  Future<void> _create(DateTime start, DateTime end) async {
    final lo = start.isAfter(end) ? end : start;
    final hi = start.isAfter(end) ? start : end;
    await ref.read(createTaskUseCaseProvider).call(
          TaskDraft(title: 'New task', startDate: lo, dueDate: hi),
        );
  }

  Future<void> _move(String taskId, Duration delta) async {
    final task = await _find(taskId);
    if (task == null) return;
    final newStart = task.startDate?.add(delta);
    final newDue = task.dueDate?.add(delta);
    if (newStart != null && newDue != null && newDue.isBefore(newStart)) return;
    await ref.read(updateTaskUseCaseProvider).call(
          task.copyWith(startDate: newStart, dueDate: newDue),
        );
  }

  Future<void> _resize(String taskId, DragEdge edge, DateTime newDate) async {
    final task = await _find(taskId);
    if (task == null) return;
    final candidate = switch (edge) {
      DragEdge.start => task.copyWith(startDate: newDate),
      DragEdge.end => task.copyWith(dueDate: newDate),
    };
    final start = candidate.startDate;
    final due = candidate.dueDate;
    if (start != null && due != null && due.isBefore(start)) return; // revert
    await ref.read(updateTaskUseCaseProvider).call(candidate);
  }

  Future<Task?> _find(String taskId) async {
    final result = await ref.read(taskRepositoryProvider).findById(taskId);
    return result.valueOrNull;
  }
}
