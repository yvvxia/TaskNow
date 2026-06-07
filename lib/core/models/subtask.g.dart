// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subtask _$SubtaskFromJson(Map<String, dynamic> json) => _Subtask(
  id: json['id'] as String,
  title: json['title'] as String,
  isDone: json['isDone'] as bool? ?? false,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SubtaskToJson(_Subtask instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'isDone': instance.isDone,
  'sortOrder': instance.sortOrder,
};
