import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'recurrence_rule.freezed.dart';
part 'recurrence_rule.g.dart';

/// Recurrence rule describing how a task repeats. Persisted in the
/// `recurrence_rules` table; consumed by the recurrence engine (module 02).
@freezed
abstract class RecurrenceRule with _$RecurrenceRule {
  const factory RecurrenceRule({
    required String id,
    @Default(RecurrenceFrequency.daily) RecurrenceFrequency frequency,
    @Default(1) int interval,

    /// ISO weekdays (Mon=1 … Sun=7) for [RecurrenceFrequency.weekly].
    @Default(<int>[]) List<int> byWeekday,

    /// Day-of-month for [RecurrenceFrequency.monthly].
    int? byMonthDay,

    /// Optional end date (null = never-ending).
    DateTime? endDate,

    /// Optional maximum number of occurrences (null = unbounded).
    int? count,
  }) = _RecurrenceRule;

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceRuleFromJson(json);
}
