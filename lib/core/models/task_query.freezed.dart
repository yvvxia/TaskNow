// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskQuery {

 String? get keyword; DateFilter? get dateFilter; StatusFilter get statusFilter; Set<Priority>? get priorities; Set<String> get projectIds; bool get includeCompleted; bool get includeDeleted; String? get text; TaskStatus? get status; Priority? get priority; String? get projectId; List<String> get tagIds; TaskSort get sort;
/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskQueryCopyWith<TaskQuery> get copyWith => _$TaskQueryCopyWithImpl<TaskQuery>(this as TaskQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskQuery&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.dateFilter, dateFilter) || other.dateFilter == dateFilter)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&const DeepCollectionEquality().equals(other.priorities, priorities)&&const DeepCollectionEquality().equals(other.projectIds, projectIds)&&(identical(other.includeCompleted, includeCompleted) || other.includeCompleted == includeCompleted)&&(identical(other.includeDeleted, includeDeleted) || other.includeDeleted == includeDeleted)&&(identical(other.text, text) || other.text == text)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,dateFilter,statusFilter,const DeepCollectionEquality().hash(priorities),const DeepCollectionEquality().hash(projectIds),includeCompleted,includeDeleted,text,status,priority,projectId,const DeepCollectionEquality().hash(tagIds),sort);

@override
String toString() {
  return 'TaskQuery(keyword: $keyword, dateFilter: $dateFilter, statusFilter: $statusFilter, priorities: $priorities, projectIds: $projectIds, includeCompleted: $includeCompleted, includeDeleted: $includeDeleted, text: $text, status: $status, priority: $priority, projectId: $projectId, tagIds: $tagIds, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $TaskQueryCopyWith<$Res>  {
  factory $TaskQueryCopyWith(TaskQuery value, $Res Function(TaskQuery) _then) = _$TaskQueryCopyWithImpl;
@useResult
$Res call({
 String? keyword, DateFilter? dateFilter, StatusFilter statusFilter, Set<Priority>? priorities, Set<String> projectIds, bool includeCompleted, bool includeDeleted, String? text, TaskStatus? status, Priority? priority, String? projectId, List<String> tagIds, TaskSort sort
});


$DateFilterCopyWith<$Res>? get dateFilter;

}
/// @nodoc
class _$TaskQueryCopyWithImpl<$Res>
    implements $TaskQueryCopyWith<$Res> {
  _$TaskQueryCopyWithImpl(this._self, this._then);

  final TaskQuery _self;
  final $Res Function(TaskQuery) _then;

/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = freezed,Object? dateFilter = freezed,Object? statusFilter = null,Object? priorities = freezed,Object? projectIds = null,Object? includeCompleted = null,Object? includeDeleted = null,Object? text = freezed,Object? status = freezed,Object? priority = freezed,Object? projectId = freezed,Object? tagIds = null,Object? sort = null,}) {
  return _then(_self.copyWith(
keyword: freezed == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String?,dateFilter: freezed == dateFilter ? _self.dateFilter : dateFilter // ignore: cast_nullable_to_non_nullable
as DateFilter?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as StatusFilter,priorities: freezed == priorities ? _self.priorities : priorities // ignore: cast_nullable_to_non_nullable
as Set<Priority>?,projectIds: null == projectIds ? _self.projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as Set<String>,includeCompleted: null == includeCompleted ? _self.includeCompleted : includeCompleted // ignore: cast_nullable_to_non_nullable
as bool,includeDeleted: null == includeDeleted ? _self.includeDeleted : includeDeleted // ignore: cast_nullable_to_non_nullable
as bool,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TaskSort,
  ));
}
/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateFilterCopyWith<$Res>? get dateFilter {
    if (_self.dateFilter == null) {
    return null;
  }

  return $DateFilterCopyWith<$Res>(_self.dateFilter!, (value) {
    return _then(_self.copyWith(dateFilter: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskQuery].
extension TaskQueryPatterns on TaskQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskQuery value)  $default,){
final _that = this;
switch (_that) {
case _TaskQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskQuery value)?  $default,){
final _that = this;
switch (_that) {
case _TaskQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? keyword,  DateFilter? dateFilter,  StatusFilter statusFilter,  Set<Priority>? priorities,  Set<String> projectIds,  bool includeCompleted,  bool includeDeleted,  String? text,  TaskStatus? status,  Priority? priority,  String? projectId,  List<String> tagIds,  TaskSort sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskQuery() when $default != null:
return $default(_that.keyword,_that.dateFilter,_that.statusFilter,_that.priorities,_that.projectIds,_that.includeCompleted,_that.includeDeleted,_that.text,_that.status,_that.priority,_that.projectId,_that.tagIds,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? keyword,  DateFilter? dateFilter,  StatusFilter statusFilter,  Set<Priority>? priorities,  Set<String> projectIds,  bool includeCompleted,  bool includeDeleted,  String? text,  TaskStatus? status,  Priority? priority,  String? projectId,  List<String> tagIds,  TaskSort sort)  $default,) {final _that = this;
switch (_that) {
case _TaskQuery():
return $default(_that.keyword,_that.dateFilter,_that.statusFilter,_that.priorities,_that.projectIds,_that.includeCompleted,_that.includeDeleted,_that.text,_that.status,_that.priority,_that.projectId,_that.tagIds,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? keyword,  DateFilter? dateFilter,  StatusFilter statusFilter,  Set<Priority>? priorities,  Set<String> projectIds,  bool includeCompleted,  bool includeDeleted,  String? text,  TaskStatus? status,  Priority? priority,  String? projectId,  List<String> tagIds,  TaskSort sort)?  $default,) {final _that = this;
switch (_that) {
case _TaskQuery() when $default != null:
return $default(_that.keyword,_that.dateFilter,_that.statusFilter,_that.priorities,_that.projectIds,_that.includeCompleted,_that.includeDeleted,_that.text,_that.status,_that.priority,_that.projectId,_that.tagIds,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _TaskQuery extends TaskQuery {
  const _TaskQuery({this.keyword, this.dateFilter, this.statusFilter = StatusFilter.all, final  Set<Priority>? priorities, final  Set<String> projectIds = const <String>{}, this.includeCompleted = true, this.includeDeleted = false, this.text, this.status, this.priority, this.projectId, final  List<String> tagIds = const <String>[], this.sort = TaskSort.dueDate}): _priorities = priorities,_projectIds = projectIds,_tagIds = tagIds,super._();
  

@override final  String? keyword;
@override final  DateFilter? dateFilter;
@override@JsonKey() final  StatusFilter statusFilter;
 final  Set<Priority>? _priorities;
@override Set<Priority>? get priorities {
  final value = _priorities;
  if (value == null) return null;
  if (_priorities is EqualUnmodifiableSetView) return _priorities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}

 final  Set<String> _projectIds;
@override@JsonKey() Set<String> get projectIds {
  if (_projectIds is EqualUnmodifiableSetView) return _projectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_projectIds);
}

@override@JsonKey() final  bool includeCompleted;
@override@JsonKey() final  bool includeDeleted;
@override final  String? text;
@override final  TaskStatus? status;
@override final  Priority? priority;
@override final  String? projectId;
 final  List<String> _tagIds;
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

@override@JsonKey() final  TaskSort sort;

/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskQueryCopyWith<_TaskQuery> get copyWith => __$TaskQueryCopyWithImpl<_TaskQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskQuery&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.dateFilter, dateFilter) || other.dateFilter == dateFilter)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter)&&const DeepCollectionEquality().equals(other._priorities, _priorities)&&const DeepCollectionEquality().equals(other._projectIds, _projectIds)&&(identical(other.includeCompleted, includeCompleted) || other.includeCompleted == includeCompleted)&&(identical(other.includeDeleted, includeDeleted) || other.includeDeleted == includeDeleted)&&(identical(other.text, text) || other.text == text)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,keyword,dateFilter,statusFilter,const DeepCollectionEquality().hash(_priorities),const DeepCollectionEquality().hash(_projectIds),includeCompleted,includeDeleted,text,status,priority,projectId,const DeepCollectionEquality().hash(_tagIds),sort);

@override
String toString() {
  return 'TaskQuery(keyword: $keyword, dateFilter: $dateFilter, statusFilter: $statusFilter, priorities: $priorities, projectIds: $projectIds, includeCompleted: $includeCompleted, includeDeleted: $includeDeleted, text: $text, status: $status, priority: $priority, projectId: $projectId, tagIds: $tagIds, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$TaskQueryCopyWith<$Res> implements $TaskQueryCopyWith<$Res> {
  factory _$TaskQueryCopyWith(_TaskQuery value, $Res Function(_TaskQuery) _then) = __$TaskQueryCopyWithImpl;
@override @useResult
$Res call({
 String? keyword, DateFilter? dateFilter, StatusFilter statusFilter, Set<Priority>? priorities, Set<String> projectIds, bool includeCompleted, bool includeDeleted, String? text, TaskStatus? status, Priority? priority, String? projectId, List<String> tagIds, TaskSort sort
});


@override $DateFilterCopyWith<$Res>? get dateFilter;

}
/// @nodoc
class __$TaskQueryCopyWithImpl<$Res>
    implements _$TaskQueryCopyWith<$Res> {
  __$TaskQueryCopyWithImpl(this._self, this._then);

  final _TaskQuery _self;
  final $Res Function(_TaskQuery) _then;

/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = freezed,Object? dateFilter = freezed,Object? statusFilter = null,Object? priorities = freezed,Object? projectIds = null,Object? includeCompleted = null,Object? includeDeleted = null,Object? text = freezed,Object? status = freezed,Object? priority = freezed,Object? projectId = freezed,Object? tagIds = null,Object? sort = null,}) {
  return _then(_TaskQuery(
keyword: freezed == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String?,dateFilter: freezed == dateFilter ? _self.dateFilter : dateFilter // ignore: cast_nullable_to_non_nullable
as DateFilter?,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as StatusFilter,priorities: freezed == priorities ? _self._priorities : priorities // ignore: cast_nullable_to_non_nullable
as Set<Priority>?,projectIds: null == projectIds ? _self._projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as Set<String>,includeCompleted: null == includeCompleted ? _self.includeCompleted : includeCompleted // ignore: cast_nullable_to_non_nullable
as bool,includeDeleted: null == includeDeleted ? _self.includeDeleted : includeDeleted // ignore: cast_nullable_to_non_nullable
as bool,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TaskSort,
  ));
}

/// Create a copy of TaskQuery
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DateFilterCopyWith<$Res>? get dateFilter {
    if (_self.dateFilter == null) {
    return null;
  }

  return $DateFilterCopyWith<$Res>(_self.dateFilter!, (value) {
    return _then(_self.copyWith(dateFilter: value));
  });
}
}

// dart format on
