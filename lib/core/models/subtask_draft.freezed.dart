// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubtaskDraft {

 String get title; bool get isDone; int get sortOrder;
/// Create a copy of SubtaskDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskDraftCopyWith<SubtaskDraft> get copyWith => _$SubtaskDraftCopyWithImpl<SubtaskDraft>(this as SubtaskDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,title,isDone,sortOrder);

@override
String toString() {
  return 'SubtaskDraft(title: $title, isDone: $isDone, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $SubtaskDraftCopyWith<$Res>  {
  factory $SubtaskDraftCopyWith(SubtaskDraft value, $Res Function(SubtaskDraft) _then) = _$SubtaskDraftCopyWithImpl;
@useResult
$Res call({
 String title, bool isDone, int sortOrder
});




}
/// @nodoc
class _$SubtaskDraftCopyWithImpl<$Res>
    implements $SubtaskDraftCopyWith<$Res> {
  _$SubtaskDraftCopyWithImpl(this._self, this._then);

  final SubtaskDraft _self;
  final $Res Function(SubtaskDraft) _then;

/// Create a copy of SubtaskDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? isDone = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskDraft].
extension SubtaskDraftPatterns on SubtaskDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskDraft value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskDraft value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  bool isDone,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskDraft() when $default != null:
return $default(_that.title,_that.isDone,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  bool isDone,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _SubtaskDraft():
return $default(_that.title,_that.isDone,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  bool isDone,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskDraft() when $default != null:
return $default(_that.title,_that.isDone,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _SubtaskDraft implements SubtaskDraft {
  const _SubtaskDraft({required this.title, this.isDone = false, this.sortOrder = 0});
  

@override final  String title;
@override@JsonKey() final  bool isDone;
@override@JsonKey() final  int sortOrder;

/// Create a copy of SubtaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskDraftCopyWith<_SubtaskDraft> get copyWith => __$SubtaskDraftCopyWithImpl<_SubtaskDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,title,isDone,sortOrder);

@override
String toString() {
  return 'SubtaskDraft(title: $title, isDone: $isDone, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$SubtaskDraftCopyWith<$Res> implements $SubtaskDraftCopyWith<$Res> {
  factory _$SubtaskDraftCopyWith(_SubtaskDraft value, $Res Function(_SubtaskDraft) _then) = __$SubtaskDraftCopyWithImpl;
@override @useResult
$Res call({
 String title, bool isDone, int sortOrder
});




}
/// @nodoc
class __$SubtaskDraftCopyWithImpl<$Res>
    implements _$SubtaskDraftCopyWith<$Res> {
  __$SubtaskDraftCopyWithImpl(this._self, this._then);

  final _SubtaskDraft _self;
  final $Res Function(_SubtaskDraft) _then;

/// Create a copy of SubtaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? isDone = null,Object? sortOrder = null,}) {
  return _then(_SubtaskDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
