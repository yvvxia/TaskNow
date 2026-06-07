// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reminder {

 String get id; String get taskId; DateTime get triggerAt; ReminderType get type; bool get isFired;/// For [ReminderType.beforeDue]: minutes before the due date.
 int? get offsetMin;/// Platform notification id (int) used to cancel the scheduled notification.
 int? get notifId;
/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderCopyWith<Reminder> get copyWith => _$ReminderCopyWithImpl<Reminder>(this as Reminder, _$identity);

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.triggerAt, triggerAt) || other.triggerAt == triggerAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.isFired, isFired) || other.isFired == isFired)&&(identical(other.offsetMin, offsetMin) || other.offsetMin == offsetMin)&&(identical(other.notifId, notifId) || other.notifId == notifId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taskId,triggerAt,type,isFired,offsetMin,notifId);

@override
String toString() {
  return 'Reminder(id: $id, taskId: $taskId, triggerAt: $triggerAt, type: $type, isFired: $isFired, offsetMin: $offsetMin, notifId: $notifId)';
}


}

/// @nodoc
abstract mixin class $ReminderCopyWith<$Res>  {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) _then) = _$ReminderCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, DateTime triggerAt, ReminderType type, bool isFired, int? offsetMin, int? notifId
});




}
/// @nodoc
class _$ReminderCopyWithImpl<$Res>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._self, this._then);

  final Reminder _self;
  final $Res Function(Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? triggerAt = null,Object? type = null,Object? isFired = null,Object? offsetMin = freezed,Object? notifId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReminderType,isFired: null == isFired ? _self.isFired : isFired // ignore: cast_nullable_to_non_nullable
as bool,offsetMin: freezed == offsetMin ? _self.offsetMin : offsetMin // ignore: cast_nullable_to_non_nullable
as int?,notifId: freezed == notifId ? _self.notifId : notifId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Reminder].
extension ReminderPatterns on Reminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reminder value)  $default,){
final _that = this;
switch (_that) {
case _Reminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reminder value)?  $default,){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  DateTime triggerAt,  ReminderType type,  bool isFired,  int? offsetMin,  int? notifId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.taskId,_that.triggerAt,_that.type,_that.isFired,_that.offsetMin,_that.notifId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  DateTime triggerAt,  ReminderType type,  bool isFired,  int? offsetMin,  int? notifId)  $default,) {final _that = this;
switch (_that) {
case _Reminder():
return $default(_that.id,_that.taskId,_that.triggerAt,_that.type,_that.isFired,_that.offsetMin,_that.notifId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  DateTime triggerAt,  ReminderType type,  bool isFired,  int? offsetMin,  int? notifId)?  $default,) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.taskId,_that.triggerAt,_that.type,_that.isFired,_that.offsetMin,_that.notifId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reminder implements Reminder {
  const _Reminder({required this.id, required this.taskId, required this.triggerAt, this.type = ReminderType.beforeDue, this.isFired = false, this.offsetMin, this.notifId});
  factory _Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  DateTime triggerAt;
@override@JsonKey() final  ReminderType type;
@override@JsonKey() final  bool isFired;
/// For [ReminderType.beforeDue]: minutes before the due date.
@override final  int? offsetMin;
/// Platform notification id (int) used to cancel the scheduled notification.
@override final  int? notifId;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderCopyWith<_Reminder> get copyWith => __$ReminderCopyWithImpl<_Reminder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.triggerAt, triggerAt) || other.triggerAt == triggerAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.isFired, isFired) || other.isFired == isFired)&&(identical(other.offsetMin, offsetMin) || other.offsetMin == offsetMin)&&(identical(other.notifId, notifId) || other.notifId == notifId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taskId,triggerAt,type,isFired,offsetMin,notifId);

@override
String toString() {
  return 'Reminder(id: $id, taskId: $taskId, triggerAt: $triggerAt, type: $type, isFired: $isFired, offsetMin: $offsetMin, notifId: $notifId)';
}


}

/// @nodoc
abstract mixin class _$ReminderCopyWith<$Res> implements $ReminderCopyWith<$Res> {
  factory _$ReminderCopyWith(_Reminder value, $Res Function(_Reminder) _then) = __$ReminderCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, DateTime triggerAt, ReminderType type, bool isFired, int? offsetMin, int? notifId
});




}
/// @nodoc
class __$ReminderCopyWithImpl<$Res>
    implements _$ReminderCopyWith<$Res> {
  __$ReminderCopyWithImpl(this._self, this._then);

  final _Reminder _self;
  final $Res Function(_Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? triggerAt = null,Object? type = null,Object? isFired = null,Object? offsetMin = freezed,Object? notifId = freezed,}) {
  return _then(_Reminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,triggerAt: null == triggerAt ? _self.triggerAt : triggerAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReminderType,isFired: null == isFired ? _self.isFired : isFired // ignore: cast_nullable_to_non_nullable
as bool,offsetMin: freezed == offsetMin ? _self.offsetMin : offsetMin // ignore: cast_nullable_to_non_nullable
as int?,notifId: freezed == notifId ? _self.notifId : notifId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
