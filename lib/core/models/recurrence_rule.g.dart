// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurrenceRule _$RecurrenceRuleFromJson(Map<String, dynamic> json) =>
    _RecurrenceRule(
      id: json['id'] as String,
      frequency:
          $enumDecodeNullable(
            _$RecurrenceFrequencyEnumMap,
            json['frequency'],
          ) ??
          RecurrenceFrequency.daily,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      byWeekday:
          (json['byWeekday'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      byMonthDay: (json['byMonthDay'] as num?)?.toInt(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecurrenceRuleToJson(_RecurrenceRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
      'interval': instance.interval,
      'byWeekday': instance.byWeekday,
      'byMonthDay': instance.byMonthDay,
      'endDate': instance.endDate?.toIso8601String(),
      'count': instance.count,
    };

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.daily: 'daily',
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.custom: 'custom',
};
