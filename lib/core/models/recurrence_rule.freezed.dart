// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurrence_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurrenceRule {

 String get id; RecurrenceFrequency get frequency; int get interval;/// ISO weekdays (Mon=1 … Sun=7) for [RecurrenceFrequency.weekly].
 List<int> get byWeekday;/// Day-of-month for [RecurrenceFrequency.monthly].
 int? get byMonthDay;/// Optional end date (null = never-ending).
 DateTime? get endDate;/// Optional maximum number of occurrences (null = unbounded).
 int? get count;
/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<RecurrenceRule> get copyWith => _$RecurrenceRuleCopyWithImpl<RecurrenceRule>(this as RecurrenceRule, _$identity);

  /// Serializes this RecurrenceRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurrenceRule&&(identical(other.id, id) || other.id == id)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other.byWeekday, byWeekday)&&(identical(other.byMonthDay, byMonthDay) || other.byMonthDay == byMonthDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,frequency,interval,const DeepCollectionEquality().hash(byWeekday),byMonthDay,endDate,count);

@override
String toString() {
  return 'RecurrenceRule(id: $id, frequency: $frequency, interval: $interval, byWeekday: $byWeekday, byMonthDay: $byMonthDay, endDate: $endDate, count: $count)';
}


}

/// @nodoc
abstract mixin class $RecurrenceRuleCopyWith<$Res>  {
  factory $RecurrenceRuleCopyWith(RecurrenceRule value, $Res Function(RecurrenceRule) _then) = _$RecurrenceRuleCopyWithImpl;
@useResult
$Res call({
 String id, RecurrenceFrequency frequency, int interval, List<int> byWeekday, int? byMonthDay, DateTime? endDate, int? count
});




}
/// @nodoc
class _$RecurrenceRuleCopyWithImpl<$Res>
    implements $RecurrenceRuleCopyWith<$Res> {
  _$RecurrenceRuleCopyWithImpl(this._self, this._then);

  final RecurrenceRule _self;
  final $Res Function(RecurrenceRule) _then;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? frequency = null,Object? interval = null,Object? byWeekday = null,Object? byMonthDay = freezed,Object? endDate = freezed,Object? count = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,byWeekday: null == byWeekday ? _self.byWeekday : byWeekday // ignore: cast_nullable_to_non_nullable
as List<int>,byMonthDay: freezed == byMonthDay ? _self.byMonthDay : byMonthDay // ignore: cast_nullable_to_non_nullable
as int?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurrenceRule].
extension RecurrenceRulePatterns on RecurrenceRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurrenceRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurrenceRule value)  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurrenceRule value)?  $default,){
final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RecurrenceFrequency frequency,  int interval,  List<int> byWeekday,  int? byMonthDay,  DateTime? endDate,  int? count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
return $default(_that.id,_that.frequency,_that.interval,_that.byWeekday,_that.byMonthDay,_that.endDate,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RecurrenceFrequency frequency,  int interval,  List<int> byWeekday,  int? byMonthDay,  DateTime? endDate,  int? count)  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRule():
return $default(_that.id,_that.frequency,_that.interval,_that.byWeekday,_that.byMonthDay,_that.endDate,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RecurrenceFrequency frequency,  int interval,  List<int> byWeekday,  int? byMonthDay,  DateTime? endDate,  int? count)?  $default,) {final _that = this;
switch (_that) {
case _RecurrenceRule() when $default != null:
return $default(_that.id,_that.frequency,_that.interval,_that.byWeekday,_that.byMonthDay,_that.endDate,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurrenceRule implements RecurrenceRule {
  const _RecurrenceRule({required this.id, this.frequency = RecurrenceFrequency.daily, this.interval = 1, final  List<int> byWeekday = const <int>[], this.byMonthDay, this.endDate, this.count}): _byWeekday = byWeekday;
  factory _RecurrenceRule.fromJson(Map<String, dynamic> json) => _$RecurrenceRuleFromJson(json);

@override final  String id;
@override@JsonKey() final  RecurrenceFrequency frequency;
@override@JsonKey() final  int interval;
/// ISO weekdays (Mon=1 … Sun=7) for [RecurrenceFrequency.weekly].
 final  List<int> _byWeekday;
/// ISO weekdays (Mon=1 … Sun=7) for [RecurrenceFrequency.weekly].
@override@JsonKey() List<int> get byWeekday {
  if (_byWeekday is EqualUnmodifiableListView) return _byWeekday;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byWeekday);
}

/// Day-of-month for [RecurrenceFrequency.monthly].
@override final  int? byMonthDay;
/// Optional end date (null = never-ending).
@override final  DateTime? endDate;
/// Optional maximum number of occurrences (null = unbounded).
@override final  int? count;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurrenceRuleCopyWith<_RecurrenceRule> get copyWith => __$RecurrenceRuleCopyWithImpl<_RecurrenceRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurrenceRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurrenceRule&&(identical(other.id, id) || other.id == id)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&const DeepCollectionEquality().equals(other._byWeekday, _byWeekday)&&(identical(other.byMonthDay, byMonthDay) || other.byMonthDay == byMonthDay)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,frequency,interval,const DeepCollectionEquality().hash(_byWeekday),byMonthDay,endDate,count);

@override
String toString() {
  return 'RecurrenceRule(id: $id, frequency: $frequency, interval: $interval, byWeekday: $byWeekday, byMonthDay: $byMonthDay, endDate: $endDate, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RecurrenceRuleCopyWith<$Res> implements $RecurrenceRuleCopyWith<$Res> {
  factory _$RecurrenceRuleCopyWith(_RecurrenceRule value, $Res Function(_RecurrenceRule) _then) = __$RecurrenceRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, RecurrenceFrequency frequency, int interval, List<int> byWeekday, int? byMonthDay, DateTime? endDate, int? count
});




}
/// @nodoc
class __$RecurrenceRuleCopyWithImpl<$Res>
    implements _$RecurrenceRuleCopyWith<$Res> {
  __$RecurrenceRuleCopyWithImpl(this._self, this._then);

  final _RecurrenceRule _self;
  final $Res Function(_RecurrenceRule) _then;

/// Create a copy of RecurrenceRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? frequency = null,Object? interval = null,Object? byWeekday = null,Object? byMonthDay = freezed,Object? endDate = freezed,Object? count = freezed,}) {
  return _then(_RecurrenceRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as RecurrenceFrequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,byWeekday: null == byWeekday ? _self._byWeekday : byWeekday // ignore: cast_nullable_to_non_nullable
as List<int>,byMonthDay: freezed == byMonthDay ? _self.byMonthDay : byMonthDay // ignore: cast_nullable_to_non_nullable
as int?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
