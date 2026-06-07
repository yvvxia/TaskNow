import 'dart:convert';

import '../../core/enums/enums.dart';
import '../../core/models/recurrence_rule.dart';
import '../db/app_database.dart';
import 'time_mapper.dart';

/// Pure, bidirectional mapping between [RecurrenceRuleRow] and [RecurrenceRule].
/// `byweekday` is persisted as a JSON integer array (e.g. `[1,3,5]`).
abstract final class RecurrenceRuleMapper {
  static RecurrenceRule toEntity(RecurrenceRuleRow row) {
    return RecurrenceRule(
      id: row.id,
      frequency: _freqFromIndex(row.frequency),
      interval: row.interval,
      byWeekday: _decodeWeekdays(row.byweekday),
      byMonthDay: row.byMonthDay,
      endDate: dateTimeFromUtcMsOrNull(row.endDate),
      count: row.count,
    );
  }

  static RecurrenceRuleRow toRow(RecurrenceRule rule) {
    return RecurrenceRuleRow(
      id: rule.id,
      frequency: rule.frequency.index,
      interval: rule.interval,
      byweekday: rule.byWeekday.isEmpty ? null : jsonEncode(rule.byWeekday),
      byMonthDay: rule.byMonthDay,
      endDate: rule.endDate.msUtcOrNull,
      count: rule.count,
    );
  }

  static List<int> _decodeWeekdays(String? json) {
    if (json == null || json.isEmpty) return const <int>[];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((e) => (e as num).toInt()).toList();
  }

  static RecurrenceFrequency _freqFromIndex(int index) {
    final i = index.clamp(0, RecurrenceFrequency.values.length - 1);
    return RecurrenceFrequency.values[i];
  }
}
