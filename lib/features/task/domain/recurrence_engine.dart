import '../../../core/enums/enums.dart';
import '../../../core/models/recurrence_rule.dart';
import '../../../core/models/subtask_draft.dart';
import '../../../core/models/task.dart';
import '../../../core/models/task_draft.dart';

/// Pure domain service that generates the next recurrence date and the next
/// task instance from a repeating task. No IO; safe to call in tests without
/// any repository setup.
final class RecurrenceEngine {
  const RecurrenceEngine();

  /// Returns the date of the next occurrence after [from], or [null] if the
  /// rule's end condition has been met.
  DateTime? nextDate(RecurrenceRule rule, DateTime from) {
    final DateTime candidate;
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        candidate = from.add(Duration(days: rule.interval));
      case RecurrenceFrequency.weekly:
        candidate = _nextWeekday(from, rule.byWeekday, rule.interval);
      case RecurrenceFrequency.monthly:
        candidate = _addMonths(from, rule.interval, rule.byMonthDay);
      case RecurrenceFrequency.custom:
        candidate = from.add(Duration(days: rule.interval));
    }

    if (rule.endDate != null && candidate.isAfter(rule.endDate!)) return null;
    return candidate;
  }

  /// Builds a [TaskDraft] for the next instance of [task] occurring after
  /// [after]. Returns [null] when the series has ended.
  TaskDraft? nextInstance(Task task, {required DateTime after}) {
    final rule = task.recurrence;
    if (rule == null) return null;

    final base = task.dueDate ?? task.startDate ?? after;
    final nextDue = nextDate(rule, base);
    if (nextDue == null) return null;

    // Preserve the start→due offset if both dates were set.
    final delta = (task.dueDate != null && task.startDate != null)
        ? task.dueDate!.difference(task.startDate!)
        : Duration.zero;

    return TaskDraft(
      title: task.title,
      notes: task.notes,
      projectId: task.projectId,
      startDate: delta == Duration.zero ? null : nextDue.subtract(delta),
      dueDate: nextDue,
      priority: task.priority,
      recurrence: rule,
      tagIds: List<String>.unmodifiable(task.tagIds),
      // Reset subtask done-state for next occurrence.
      subtasks: task.subtasks
          .map((s) => SubtaskDraft(title: s.title, sortOrder: s.sortOrder))
          .toList(),
      autoCompleteOnSubtasks: task.autoCompleteOnSubtasks,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Finds the next matching ISO weekday (Mon=1 … Sun=7) at or after [from].
  DateTime _nextWeekday(DateTime from, List<int> byWeekday, int intervalWeeks) {
    if (byWeekday.isEmpty) {
      return from.add(Duration(days: intervalWeeks * 7));
    }

    // Sort weekdays and look forward up to intervalWeeks*7 + 7 days.
    final sorted = List<int>.from(byWeekday)..sort();
    final maxDays = intervalWeeks * 7 + 7;
    for (var d = 1; d <= maxDays; d++) {
      final candidate = from.add(Duration(days: d));
      final isoWeekday = candidate.weekday; // 1=Mon … 7=Sun
      if (sorted.contains(isoWeekday)) {
        return candidate;
      }
    }
    // Fallback: just add intervalWeeks*7 days.
    return from.add(Duration(days: intervalWeeks * 7));
  }

  /// Returns [from] with [months] added, clamped to the last valid day.
  /// If [byMonthDay] is supplied it overrides the day-of-month.
  DateTime _addMonths(DateTime from, int months, int? byMonthDay) {
    var year = from.year;
    var month = from.month + months;
    while (month > 12) {
      month -= 12;
      year++;
    }

    final targetDay = byMonthDay ?? from.day;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = targetDay.clamp(1, lastDayOfMonth);

    return DateTime.utc(
      year,
      month,
      day,
      from.hour,
      from.minute,
      from.second,
      from.millisecond,
      from.microsecond,
    );
  }
}
