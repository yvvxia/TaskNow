// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

 String get id; String get title; String? get notes; String? get projectId; DateTime? get startDate; DateTime? get dueDate; DateTime? get createdAt; DateTime? get completedAt; Priority get priority; TaskStatus get status; int get sortOrder; String? get recurrenceRuleId; String? get recurrenceParent; bool get autoCompleteOnSubtasks;/// IDs of tags linked to this task (M2M via `task_tags`).
 List<String> get tagIds;/// Subtasks (checklist items). Not persisted in M2; carried in-memory by
/// use cases and the presentation layer.
 List<Subtask> get subtasks;/// Embedded recurrence rule. Not persisted via [recurrenceRuleId] column;
/// use cases seed this directly when they need recurrence logic.
 RecurrenceRule? get recurrence; DateTime? get updatedAt; DateTime? get deletedAt; int get syncVersion; String? get deviceId;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.recurrenceRuleId, recurrenceRuleId) || other.recurrenceRuleId == recurrenceRuleId)&&(identical(other.recurrenceParent, recurrenceParent) || other.recurrenceParent == recurrenceParent)&&(identical(other.autoCompleteOnSubtasks, autoCompleteOnSubtasks) || other.autoCompleteOnSubtasks == autoCompleteOnSubtasks)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,notes,projectId,startDate,dueDate,createdAt,completedAt,priority,status,sortOrder,recurrenceRuleId,recurrenceParent,autoCompleteOnSubtasks,const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(subtasks),recurrence,updatedAt,deletedAt,syncVersion,deviceId]);

@override
String toString() {
  return 'Task(id: $id, title: $title, notes: $notes, projectId: $projectId, startDate: $startDate, dueDate: $dueDate, createdAt: $createdAt, completedAt: $completedAt, priority: $priority, status: $status, sortOrder: $sortOrder, recurrenceRuleId: $recurrenceRuleId, recurrenceParent: $recurrenceParent, autoCompleteOnSubtasks: $autoCompleteOnSubtasks, tagIds: $tagIds, subtasks: $subtasks, recurrence: $recurrence, updatedAt: $updatedAt, deletedAt: $deletedAt, syncVersion: $syncVersion, deviceId: $deviceId)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? notes, String? projectId, DateTime? startDate, DateTime? dueDate, DateTime? createdAt, DateTime? completedAt, Priority priority, TaskStatus status, int sortOrder, String? recurrenceRuleId, String? recurrenceParent, bool autoCompleteOnSubtasks, List<String> tagIds, List<Subtask> subtasks, RecurrenceRule? recurrence, DateTime? updatedAt, DateTime? deletedAt, int syncVersion, String? deviceId
});


$RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? projectId = freezed,Object? startDate = freezed,Object? dueDate = freezed,Object? createdAt = freezed,Object? completedAt = freezed,Object? priority = null,Object? status = null,Object? sortOrder = null,Object? recurrenceRuleId = freezed,Object? recurrenceParent = freezed,Object? autoCompleteOnSubtasks = null,Object? tagIds = null,Object? subtasks = null,Object? recurrence = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? syncVersion = null,Object? deviceId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,recurrenceRuleId: freezed == recurrenceRuleId ? _self.recurrenceRuleId : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceParent: freezed == recurrenceParent ? _self.recurrenceParent : recurrenceParent // ignore: cast_nullable_to_non_nullable
as String?,autoCompleteOnSubtasks: null == autoCompleteOnSubtasks ? _self.autoCompleteOnSubtasks : autoCompleteOnSubtasks // ignore: cast_nullable_to_non_nullable
as bool,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt,  Priority priority,  TaskStatus status,  int sortOrder,  String? recurrenceRuleId,  String? recurrenceParent,  bool autoCompleteOnSubtasks,  List<String> tagIds,  List<Subtask> subtasks,  RecurrenceRule? recurrence,  DateTime? updatedAt,  DateTime? deletedAt,  int syncVersion,  String? deviceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.createdAt,_that.completedAt,_that.priority,_that.status,_that.sortOrder,_that.recurrenceRuleId,_that.recurrenceParent,_that.autoCompleteOnSubtasks,_that.tagIds,_that.subtasks,_that.recurrence,_that.updatedAt,_that.deletedAt,_that.syncVersion,_that.deviceId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt,  Priority priority,  TaskStatus status,  int sortOrder,  String? recurrenceRuleId,  String? recurrenceParent,  bool autoCompleteOnSubtasks,  List<String> tagIds,  List<Subtask> subtasks,  RecurrenceRule? recurrence,  DateTime? updatedAt,  DateTime? deletedAt,  int syncVersion,  String? deviceId)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.createdAt,_that.completedAt,_that.priority,_that.status,_that.sortOrder,_that.recurrenceRuleId,_that.recurrenceParent,_that.autoCompleteOnSubtasks,_that.tagIds,_that.subtasks,_that.recurrence,_that.updatedAt,_that.deletedAt,_that.syncVersion,_that.deviceId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  DateTime? createdAt,  DateTime? completedAt,  Priority priority,  TaskStatus status,  int sortOrder,  String? recurrenceRuleId,  String? recurrenceParent,  bool autoCompleteOnSubtasks,  List<String> tagIds,  List<Subtask> subtasks,  RecurrenceRule? recurrence,  DateTime? updatedAt,  DateTime? deletedAt,  int syncVersion,  String? deviceId)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.createdAt,_that.completedAt,_that.priority,_that.status,_that.sortOrder,_that.recurrenceRuleId,_that.recurrenceParent,_that.autoCompleteOnSubtasks,_that.tagIds,_that.subtasks,_that.recurrence,_that.updatedAt,_that.deletedAt,_that.syncVersion,_that.deviceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.id, required this.title, this.notes, this.projectId, this.startDate, this.dueDate, this.createdAt, this.completedAt, this.priority = Priority.medium, this.status = TaskStatus.incomplete, this.sortOrder = 0, this.recurrenceRuleId, this.recurrenceParent, this.autoCompleteOnSubtasks = false, final  List<String> tagIds = const <String>[], final  List<Subtask> subtasks = const <Subtask>[], this.recurrence, this.updatedAt, this.deletedAt, this.syncVersion = 0, this.deviceId}): _tagIds = tagIds,_subtasks = subtasks,super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? notes;
@override final  String? projectId;
@override final  DateTime? startDate;
@override final  DateTime? dueDate;
@override final  DateTime? createdAt;
@override final  DateTime? completedAt;
@override@JsonKey() final  Priority priority;
@override@JsonKey() final  TaskStatus status;
@override@JsonKey() final  int sortOrder;
@override final  String? recurrenceRuleId;
@override final  String? recurrenceParent;
@override@JsonKey() final  bool autoCompleteOnSubtasks;
/// IDs of tags linked to this task (M2M via `task_tags`).
 final  List<String> _tagIds;
/// IDs of tags linked to this task (M2M via `task_tags`).
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

/// Subtasks (checklist items). Not persisted in M2; carried in-memory by
/// use cases and the presentation layer.
 final  List<Subtask> _subtasks;
/// Subtasks (checklist items). Not persisted in M2; carried in-memory by
/// use cases and the presentation layer.
@override@JsonKey() List<Subtask> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

/// Embedded recurrence rule. Not persisted via [recurrenceRuleId] column;
/// use cases seed this directly when they need recurrence logic.
@override final  RecurrenceRule? recurrence;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int syncVersion;
@override final  String? deviceId;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.recurrenceRuleId, recurrenceRuleId) || other.recurrenceRuleId == recurrenceRuleId)&&(identical(other.recurrenceParent, recurrenceParent) || other.recurrenceParent == recurrenceParent)&&(identical(other.autoCompleteOnSubtasks, autoCompleteOnSubtasks) || other.autoCompleteOnSubtasks == autoCompleteOnSubtasks)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.syncVersion, syncVersion) || other.syncVersion == syncVersion)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,notes,projectId,startDate,dueDate,createdAt,completedAt,priority,status,sortOrder,recurrenceRuleId,recurrenceParent,autoCompleteOnSubtasks,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_subtasks),recurrence,updatedAt,deletedAt,syncVersion,deviceId]);

@override
String toString() {
  return 'Task(id: $id, title: $title, notes: $notes, projectId: $projectId, startDate: $startDate, dueDate: $dueDate, createdAt: $createdAt, completedAt: $completedAt, priority: $priority, status: $status, sortOrder: $sortOrder, recurrenceRuleId: $recurrenceRuleId, recurrenceParent: $recurrenceParent, autoCompleteOnSubtasks: $autoCompleteOnSubtasks, tagIds: $tagIds, subtasks: $subtasks, recurrence: $recurrence, updatedAt: $updatedAt, deletedAt: $deletedAt, syncVersion: $syncVersion, deviceId: $deviceId)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? notes, String? projectId, DateTime? startDate, DateTime? dueDate, DateTime? createdAt, DateTime? completedAt, Priority priority, TaskStatus status, int sortOrder, String? recurrenceRuleId, String? recurrenceParent, bool autoCompleteOnSubtasks, List<String> tagIds, List<Subtask> subtasks, RecurrenceRule? recurrence, DateTime? updatedAt, DateTime? deletedAt, int syncVersion, String? deviceId
});


@override $RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? projectId = freezed,Object? startDate = freezed,Object? dueDate = freezed,Object? createdAt = freezed,Object? completedAt = freezed,Object? priority = null,Object? status = null,Object? sortOrder = null,Object? recurrenceRuleId = freezed,Object? recurrenceParent = freezed,Object? autoCompleteOnSubtasks = null,Object? tagIds = null,Object? subtasks = null,Object? recurrence = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? syncVersion = null,Object? deviceId = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,recurrenceRuleId: freezed == recurrenceRuleId ? _self.recurrenceRuleId : recurrenceRuleId // ignore: cast_nullable_to_non_nullable
as String?,recurrenceParent: freezed == recurrenceParent ? _self.recurrenceParent : recurrenceParent // ignore: cast_nullable_to_non_nullable
as String?,autoCompleteOnSubtasks: null == autoCompleteOnSubtasks ? _self.autoCompleteOnSubtasks : autoCompleteOnSubtasks // ignore: cast_nullable_to_non_nullable
as bool,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncVersion: null == syncVersion ? _self.syncVersion : syncVersion // ignore: cast_nullable_to_non_nullable
as int,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}

// dart format on
