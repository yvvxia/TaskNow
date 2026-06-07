// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  triggerAt: DateTime.parse(json['triggerAt'] as String),
  type:
      $enumDecodeNullable(_$ReminderTypeEnumMap, json['type']) ??
      ReminderType.beforeDue,
  isFired: json['isFired'] as bool? ?? false,
  offsetMin: (json['offsetMin'] as num?)?.toInt(),
  notifId: (json['notifId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'triggerAt': instance.triggerAt.toIso8601String(),
  'type': _$ReminderTypeEnumMap[instance.type]!,
  'isFired': instance.isFired,
  'offsetMin': instance.offsetMin,
  'notifId': instance.notifId,
};

const _$ReminderTypeEnumMap = {
  ReminderType.beforeDue: 'beforeDue',
  ReminderType.atStart: 'atStart',
  ReminderType.custom: 'custom',
  ReminderType.overdue: 'overdue',
};
