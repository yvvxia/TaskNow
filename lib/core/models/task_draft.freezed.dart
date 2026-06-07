// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDraft {

 String get title; String? get notes; String? get projectId; DateTime? get startDate; DateTime? get dueDate; Priority get priority; List<String> get tagIds; List<SubtaskDraft> get subtasks; RecurrenceRule? get recurrence; bool get autoCompleteOnSubtasks;
/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDraftCopyWith<TaskDraft> get copyWith => _$TaskDraftCopyWithImpl<TaskDraft>(this as TaskDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.autoCompleteOnSubtasks, autoCompleteOnSubtasks) || other.autoCompleteOnSubtasks == autoCompleteOnSubtasks));
}


@override
int get hashCode => Object.hash(runtimeType,title,notes,projectId,startDate,dueDate,priority,const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(subtasks),recurrence,autoCompleteOnSubtasks);

@override
String toString() {
  return 'TaskDraft(title: $title, notes: $notes, projectId: $projectId, startDate: $startDate, dueDate: $dueDate, priority: $priority, tagIds: $tagIds, subtasks: $subtasks, recurrence: $recurrence, autoCompleteOnSubtasks: $autoCompleteOnSubtasks)';
}


}

/// @nodoc
abstract mixin class $TaskDraftCopyWith<$Res>  {
  factory $TaskDraftCopyWith(TaskDraft value, $Res Function(TaskDraft) _then) = _$TaskDraftCopyWithImpl;
@useResult
$Res call({
 String title, String? notes, String? projectId, DateTime? startDate, DateTime? dueDate, Priority priority, List<String> tagIds, List<SubtaskDraft> subtasks, RecurrenceRule? recurrence, bool autoCompleteOnSubtasks
});


$RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class _$TaskDraftCopyWithImpl<$Res>
    implements $TaskDraftCopyWith<$Res> {
  _$TaskDraftCopyWithImpl(this._self, this._then);

  final TaskDraft _self;
  final $Res Function(TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? notes = freezed,Object? projectId = freezed,Object? startDate = freezed,Object? dueDate = freezed,Object? priority = null,Object? tagIds = null,Object? subtasks = null,Object? recurrence = freezed,Object? autoCompleteOnSubtasks = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskDraft>,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,autoCompleteOnSubtasks: null == autoCompleteOnSubtasks ? _self.autoCompleteOnSubtasks : autoCompleteOnSubtasks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TaskDraft
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


/// Adds pattern-matching-related methods to [TaskDraft].
extension TaskDraftPatterns on TaskDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDraft value)  $default,){
final _that = this;
switch (_that) {
case _TaskDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  Priority priority,  List<String> tagIds,  List<SubtaskDraft> subtasks,  RecurrenceRule? recurrence,  bool autoCompleteOnSubtasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.priority,_that.tagIds,_that.subtasks,_that.recurrence,_that.autoCompleteOnSubtasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  Priority priority,  List<String> tagIds,  List<SubtaskDraft> subtasks,  RecurrenceRule? recurrence,  bool autoCompleteOnSubtasks)  $default,) {final _that = this;
switch (_that) {
case _TaskDraft():
return $default(_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.priority,_that.tagIds,_that.subtasks,_that.recurrence,_that.autoCompleteOnSubtasks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? notes,  String? projectId,  DateTime? startDate,  DateTime? dueDate,  Priority priority,  List<String> tagIds,  List<SubtaskDraft> subtasks,  RecurrenceRule? recurrence,  bool autoCompleteOnSubtasks)?  $default,) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.title,_that.notes,_that.projectId,_that.startDate,_that.dueDate,_that.priority,_that.tagIds,_that.subtasks,_that.recurrence,_that.autoCompleteOnSubtasks);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDraft implements TaskDraft {
  const _TaskDraft({required this.title, this.notes, this.projectId, this.startDate, this.dueDate, this.priority = Priority.medium, final  List<String> tagIds = const <String>[], final  List<SubtaskDraft> subtasks = const <SubtaskDraft>[], this.recurrence, this.autoCompleteOnSubtasks = false}): _tagIds = tagIds,_subtasks = subtasks;
  

@override final  String title;
@override final  String? notes;
@override final  String? projectId;
@override final  DateTime? startDate;
@override final  DateTime? dueDate;
@override@JsonKey() final  Priority priority;
 final  List<String> _tagIds;
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

 final  List<SubtaskDraft> _subtasks;
@override@JsonKey() List<SubtaskDraft> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

@override final  RecurrenceRule? recurrence;
@override@JsonKey() final  bool autoCompleteOnSubtasks;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDraftCopyWith<_TaskDraft> get copyWith => __$TaskDraftCopyWithImpl<_TaskDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.autoCompleteOnSubtasks, autoCompleteOnSubtasks) || other.autoCompleteOnSubtasks == autoCompleteOnSubtasks));
}


@override
int get hashCode => Object.hash(runtimeType,title,notes,projectId,startDate,dueDate,priority,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_subtasks),recurrence,autoCompleteOnSubtasks);

@override
String toString() {
  return 'TaskDraft(title: $title, notes: $notes, projectId: $projectId, startDate: $startDate, dueDate: $dueDate, priority: $priority, tagIds: $tagIds, subtasks: $subtasks, recurrence: $recurrence, autoCompleteOnSubtasks: $autoCompleteOnSubtasks)';
}


}

/// @nodoc
abstract mixin class _$TaskDraftCopyWith<$Res> implements $TaskDraftCopyWith<$Res> {
  factory _$TaskDraftCopyWith(_TaskDraft value, $Res Function(_TaskDraft) _then) = __$TaskDraftCopyWithImpl;
@override @useResult
$Res call({
 String title, String? notes, String? projectId, DateTime? startDate, DateTime? dueDate, Priority priority, List<String> tagIds, List<SubtaskDraft> subtasks, RecurrenceRule? recurrence, bool autoCompleteOnSubtasks
});


@override $RecurrenceRuleCopyWith<$Res>? get recurrence;

}
/// @nodoc
class __$TaskDraftCopyWithImpl<$Res>
    implements _$TaskDraftCopyWith<$Res> {
  __$TaskDraftCopyWithImpl(this._self, this._then);

  final _TaskDraft _self;
  final $Res Function(_TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? notes = freezed,Object? projectId = freezed,Object? startDate = freezed,Object? dueDate = freezed,Object? priority = null,Object? tagIds = null,Object? subtasks = null,Object? recurrence = freezed,Object? autoCompleteOnSubtasks = null,}) {
  return _then(_TaskDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskDraft>,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,autoCompleteOnSubtasks: null == autoCompleteOnSubtasks ? _self.autoCompleteOnSubtasks : autoCompleteOnSubtasks // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TaskDraft
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
