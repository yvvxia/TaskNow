// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationRequest {

 int get id; String get taskId; String get title; String get body; DateTime get scheduledAt;
/// Create a copy of NotificationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationRequestCopyWith<NotificationRequest> get copyWith => _$NotificationRequestCopyWithImpl<NotificationRequest>(this as NotificationRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,taskId,title,body,scheduledAt);

@override
String toString() {
  return 'NotificationRequest(id: $id, taskId: $taskId, title: $title, body: $body, scheduledAt: $scheduledAt)';
}


}

/// @nodoc
abstract mixin class $NotificationRequestCopyWith<$Res>  {
  factory $NotificationRequestCopyWith(NotificationRequest value, $Res Function(NotificationRequest) _then) = _$NotificationRequestCopyWithImpl;
@useResult
$Res call({
 int id, String taskId, String title, String body, DateTime scheduledAt
});




}
/// @nodoc
class _$NotificationRequestCopyWithImpl<$Res>
    implements $NotificationRequestCopyWith<$Res> {
  _$NotificationRequestCopyWithImpl(this._self, this._then);

  final NotificationRequest _self;
  final $Res Function(NotificationRequest) _then;

/// Create a copy of NotificationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? body = null,Object? scheduledAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationRequest].
extension NotificationRequestPatterns on NotificationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationRequest value)  $default,){
final _that = this;
switch (_that) {
case _NotificationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String taskId,  String title,  String body,  DateTime scheduledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationRequest() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.body,_that.scheduledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String taskId,  String title,  String body,  DateTime scheduledAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationRequest():
return $default(_that.id,_that.taskId,_that.title,_that.body,_that.scheduledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String taskId,  String title,  String body,  DateTime scheduledAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationRequest() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.body,_that.scheduledAt);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationRequest implements NotificationRequest {
  const _NotificationRequest({required this.id, required this.taskId, required this.title, required this.body, required this.scheduledAt});
  

@override final  int id;
@override final  String taskId;
@override final  String title;
@override final  String body;
@override final  DateTime scheduledAt;

/// Create a copy of NotificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationRequestCopyWith<_NotificationRequest> get copyWith => __$NotificationRequestCopyWithImpl<_NotificationRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,taskId,title,body,scheduledAt);

@override
String toString() {
  return 'NotificationRequest(id: $id, taskId: $taskId, title: $title, body: $body, scheduledAt: $scheduledAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationRequestCopyWith<$Res> implements $NotificationRequestCopyWith<$Res> {
  factory _$NotificationRequestCopyWith(_NotificationRequest value, $Res Function(_NotificationRequest) _then) = __$NotificationRequestCopyWithImpl;
@override @useResult
$Res call({
 int id, String taskId, String title, String body, DateTime scheduledAt
});




}
/// @nodoc
class __$NotificationRequestCopyWithImpl<$Res>
    implements _$NotificationRequestCopyWith<$Res> {
  __$NotificationRequestCopyWithImpl(this._self, this._then);

  final _NotificationRequest _self;
  final $Res Function(_NotificationRequest) _then;

/// Create a copy of NotificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? body = null,Object? scheduledAt = null,}) {
  return _then(_NotificationRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
