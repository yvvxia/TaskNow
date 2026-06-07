// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarViewState {

 CalendarViewType get type; DateTime get anchor; DateTimeRange get visibleRange; String? get selectedTaskId;
/// Create a copy of CalendarViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarViewStateCopyWith<CalendarViewState> get copyWith => _$CalendarViewStateCopyWithImpl<CalendarViewState>(this as CalendarViewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarViewState&&(identical(other.type, type) || other.type == type)&&(identical(other.anchor, anchor) || other.anchor == anchor)&&(identical(other.visibleRange, visibleRange) || other.visibleRange == visibleRange)&&(identical(other.selectedTaskId, selectedTaskId) || other.selectedTaskId == selectedTaskId));
}


@override
int get hashCode => Object.hash(runtimeType,type,anchor,visibleRange,selectedTaskId);

@override
String toString() {
  return 'CalendarViewState(type: $type, anchor: $anchor, visibleRange: $visibleRange, selectedTaskId: $selectedTaskId)';
}


}

/// @nodoc
abstract mixin class $CalendarViewStateCopyWith<$Res>  {
  factory $CalendarViewStateCopyWith(CalendarViewState value, $Res Function(CalendarViewState) _then) = _$CalendarViewStateCopyWithImpl;
@useResult
$Res call({
 CalendarViewType type, DateTime anchor, DateTimeRange visibleRange, String? selectedTaskId
});




}
/// @nodoc
class _$CalendarViewStateCopyWithImpl<$Res>
    implements $CalendarViewStateCopyWith<$Res> {
  _$CalendarViewStateCopyWithImpl(this._self, this._then);

  final CalendarViewState _self;
  final $Res Function(CalendarViewState) _then;

/// Create a copy of CalendarViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? anchor = null,Object? visibleRange = null,Object? selectedTaskId = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CalendarViewType,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as DateTime,visibleRange: null == visibleRange ? _self.visibleRange : visibleRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,selectedTaskId: freezed == selectedTaskId ? _self.selectedTaskId : selectedTaskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarViewState].
extension CalendarViewStatePatterns on CalendarViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarViewState value)  $default,){
final _that = this;
switch (_that) {
case _CalendarViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarViewState value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarViewType type,  DateTime anchor,  DateTimeRange visibleRange,  String? selectedTaskId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarViewState() when $default != null:
return $default(_that.type,_that.anchor,_that.visibleRange,_that.selectedTaskId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarViewType type,  DateTime anchor,  DateTimeRange visibleRange,  String? selectedTaskId)  $default,) {final _that = this;
switch (_that) {
case _CalendarViewState():
return $default(_that.type,_that.anchor,_that.visibleRange,_that.selectedTaskId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarViewType type,  DateTime anchor,  DateTimeRange visibleRange,  String? selectedTaskId)?  $default,) {final _that = this;
switch (_that) {
case _CalendarViewState() when $default != null:
return $default(_that.type,_that.anchor,_that.visibleRange,_that.selectedTaskId);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarViewState implements CalendarViewState {
  const _CalendarViewState({required this.type, required this.anchor, required this.visibleRange, this.selectedTaskId});
  

@override final  CalendarViewType type;
@override final  DateTime anchor;
@override final  DateTimeRange visibleRange;
@override final  String? selectedTaskId;

/// Create a copy of CalendarViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarViewStateCopyWith<_CalendarViewState> get copyWith => __$CalendarViewStateCopyWithImpl<_CalendarViewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarViewState&&(identical(other.type, type) || other.type == type)&&(identical(other.anchor, anchor) || other.anchor == anchor)&&(identical(other.visibleRange, visibleRange) || other.visibleRange == visibleRange)&&(identical(other.selectedTaskId, selectedTaskId) || other.selectedTaskId == selectedTaskId));
}


@override
int get hashCode => Object.hash(runtimeType,type,anchor,visibleRange,selectedTaskId);

@override
String toString() {
  return 'CalendarViewState(type: $type, anchor: $anchor, visibleRange: $visibleRange, selectedTaskId: $selectedTaskId)';
}


}

/// @nodoc
abstract mixin class _$CalendarViewStateCopyWith<$Res> implements $CalendarViewStateCopyWith<$Res> {
  factory _$CalendarViewStateCopyWith(_CalendarViewState value, $Res Function(_CalendarViewState) _then) = __$CalendarViewStateCopyWithImpl;
@override @useResult
$Res call({
 CalendarViewType type, DateTime anchor, DateTimeRange visibleRange, String? selectedTaskId
});




}
/// @nodoc
class __$CalendarViewStateCopyWithImpl<$Res>
    implements _$CalendarViewStateCopyWith<$Res> {
  __$CalendarViewStateCopyWithImpl(this._self, this._then);

  final _CalendarViewState _self;
  final $Res Function(_CalendarViewState) _then;

/// Create a copy of CalendarViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? anchor = null,Object? visibleRange = null,Object? selectedTaskId = freezed,}) {
  return _then(_CalendarViewState(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CalendarViewType,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as DateTime,visibleRange: null == visibleRange ? _self.visibleRange : visibleRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,selectedTaskId: freezed == selectedTaskId ? _self.selectedTaskId : selectedTaskId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
