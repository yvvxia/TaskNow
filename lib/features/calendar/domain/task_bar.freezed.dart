// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_bar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskBar {

 Task get task; DateTime get barStart; DateTime get barEnd; int get rowIndex; bool get isOverdue; Color get color;
/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBarCopyWith<TaskBar> get copyWith => _$TaskBarCopyWithImpl<TaskBar>(this as TaskBar, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBar&&(identical(other.task, task) || other.task == task)&&(identical(other.barStart, barStart) || other.barStart == barStart)&&(identical(other.barEnd, barEnd) || other.barEnd == barEnd)&&(identical(other.rowIndex, rowIndex) || other.rowIndex == rowIndex)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,task,barStart,barEnd,rowIndex,isOverdue,color);

@override
String toString() {
  return 'TaskBar(task: $task, barStart: $barStart, barEnd: $barEnd, rowIndex: $rowIndex, isOverdue: $isOverdue, color: $color)';
}


}

/// @nodoc
abstract mixin class $TaskBarCopyWith<$Res>  {
  factory $TaskBarCopyWith(TaskBar value, $Res Function(TaskBar) _then) = _$TaskBarCopyWithImpl;
@useResult
$Res call({
 Task task, DateTime barStart, DateTime barEnd, int rowIndex, bool isOverdue, Color color
});


$TaskCopyWith<$Res> get task;

}
/// @nodoc
class _$TaskBarCopyWithImpl<$Res>
    implements $TaskBarCopyWith<$Res> {
  _$TaskBarCopyWithImpl(this._self, this._then);

  final TaskBar _self;
  final $Res Function(TaskBar) _then;

/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? task = null,Object? barStart = null,Object? barEnd = null,Object? rowIndex = null,Object? isOverdue = null,Object? color = null,}) {
  return _then(_self.copyWith(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,barStart: null == barStart ? _self.barStart : barStart // ignore: cast_nullable_to_non_nullable
as DateTime,barEnd: null == barEnd ? _self.barEnd : barEnd // ignore: cast_nullable_to_non_nullable
as DateTime,rowIndex: null == rowIndex ? _self.rowIndex : rowIndex // ignore: cast_nullable_to_non_nullable
as int,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}
/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskBar].
extension TaskBarPatterns on TaskBar {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskBar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskBar() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskBar value)  $default,){
final _that = this;
switch (_that) {
case _TaskBar():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskBar value)?  $default,){
final _that = this;
switch (_that) {
case _TaskBar() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Task task,  DateTime barStart,  DateTime barEnd,  int rowIndex,  bool isOverdue,  Color color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskBar() when $default != null:
return $default(_that.task,_that.barStart,_that.barEnd,_that.rowIndex,_that.isOverdue,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Task task,  DateTime barStart,  DateTime barEnd,  int rowIndex,  bool isOverdue,  Color color)  $default,) {final _that = this;
switch (_that) {
case _TaskBar():
return $default(_that.task,_that.barStart,_that.barEnd,_that.rowIndex,_that.isOverdue,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Task task,  DateTime barStart,  DateTime barEnd,  int rowIndex,  bool isOverdue,  Color color)?  $default,) {final _that = this;
switch (_that) {
case _TaskBar() when $default != null:
return $default(_that.task,_that.barStart,_that.barEnd,_that.rowIndex,_that.isOverdue,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _TaskBar implements TaskBar {
  const _TaskBar({required this.task, required this.barStart, required this.barEnd, required this.rowIndex, required this.isOverdue, required this.color});
  

@override final  Task task;
@override final  DateTime barStart;
@override final  DateTime barEnd;
@override final  int rowIndex;
@override final  bool isOverdue;
@override final  Color color;

/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskBarCopyWith<_TaskBar> get copyWith => __$TaskBarCopyWithImpl<_TaskBar>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskBar&&(identical(other.task, task) || other.task == task)&&(identical(other.barStart, barStart) || other.barStart == barStart)&&(identical(other.barEnd, barEnd) || other.barEnd == barEnd)&&(identical(other.rowIndex, rowIndex) || other.rowIndex == rowIndex)&&(identical(other.isOverdue, isOverdue) || other.isOverdue == isOverdue)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,task,barStart,barEnd,rowIndex,isOverdue,color);

@override
String toString() {
  return 'TaskBar(task: $task, barStart: $barStart, barEnd: $barEnd, rowIndex: $rowIndex, isOverdue: $isOverdue, color: $color)';
}


}

/// @nodoc
abstract mixin class _$TaskBarCopyWith<$Res> implements $TaskBarCopyWith<$Res> {
  factory _$TaskBarCopyWith(_TaskBar value, $Res Function(_TaskBar) _then) = __$TaskBarCopyWithImpl;
@override @useResult
$Res call({
 Task task, DateTime barStart, DateTime barEnd, int rowIndex, bool isOverdue, Color color
});


@override $TaskCopyWith<$Res> get task;

}
/// @nodoc
class __$TaskBarCopyWithImpl<$Res>
    implements _$TaskBarCopyWith<$Res> {
  __$TaskBarCopyWithImpl(this._self, this._then);

  final _TaskBar _self;
  final $Res Function(_TaskBar) _then;

/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? task = null,Object? barStart = null,Object? barEnd = null,Object? rowIndex = null,Object? isOverdue = null,Object? color = null,}) {
  return _then(_TaskBar(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,barStart: null == barStart ? _self.barStart : barStart // ignore: cast_nullable_to_non_nullable
as DateTime,barEnd: null == barEnd ? _self.barEnd : barEnd // ignore: cast_nullable_to_non_nullable
as DateTime,rowIndex: null == rowIndex ? _self.rowIndex : rowIndex // ignore: cast_nullable_to_non_nullable
as int,isOverdue: null == isOverdue ? _self.isOverdue : isOverdue // ignore: cast_nullable_to_non_nullable
as bool,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

/// Create a copy of TaskBar
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}

// dart format on
