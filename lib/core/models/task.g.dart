// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  title: json['title'] as String,
  notes: json['notes'] as String?,
  projectId: json['projectId'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  priority:
      $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
      Priority.medium,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.incomplete,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  recurrenceRuleId: json['recurrenceRuleId'] as String?,
  recurrenceParent: json['recurrenceParent'] as String?,
  autoCompleteOnSubtasks: json['autoCompleteOnSubtasks'] as bool? ?? false,
  tagIds:
      (json['tagIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Subtask>[],
  recurrence: json['recurrence'] == null
      ? null
      : RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  syncVersion: (json['syncVersion'] as num?)?.toInt() ?? 0,
  deviceId: json['deviceId'] as String?,
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'notes': instance.notes,
  'projectId': instance.projectId,
  'startDate': instance.startDate?.toIso8601String(),
  'dueDate': instance.dueDate?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'priority': _$PriorityEnumMap[instance.priority]!,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'sortOrder': instance.sortOrder,
  'recurrenceRuleId': instance.recurrenceRuleId,
  'recurrenceParent': instance.recurrenceParent,
  'autoCompleteOnSubtasks': instance.autoCompleteOnSubtasks,
  'tagIds': instance.tagIds,
  'subtasks': instance.subtasks,
  'recurrence': instance.recurrence,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'syncVersion': instance.syncVersion,
  'deviceId': instance.deviceId,
};

const _$PriorityEnumMap = {
  Priority.high: 'high',
  Priority.medium: 'medium',
  Priority.low: 'low',
};

const _$TaskStatusEnumMap = {
  TaskStatus.incomplete: 'incomplete',
  TaskStatus.complete: 'complete',
  TaskStatus.overdue: 'overdue',
};
