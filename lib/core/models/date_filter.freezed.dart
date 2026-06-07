// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'date_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DateFilter {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateFilter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DateFilter()';
}


}

/// @nodoc
class $DateFilterCopyWith<$Res>  {
$DateFilterCopyWith(DateFilter _, $Res Function(DateFilter) __);
}


/// Adds pattern-matching-related methods to [DateFilter].
extension DateFilterPatterns on DateFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DateOn value)?  on,TResult Function( DateRange value)?  range,TResult Function( DateOverlap value)?  overlap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DateOn() when on != null:
return on(_that);case DateRange() when range != null:
return range(_that);case DateOverlap() when overlap != null:
return overlap(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DateOn value)  on,required TResult Function( DateRange value)  range,required TResult Function( DateOverlap value)  overlap,}){
final _that = this;
switch (_that) {
case DateOn():
return on(_that);case DateRange():
return range(_that);case DateOverlap():
return overlap(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DateOn value)?  on,TResult? Function( DateRange value)?  range,TResult? Function( DateOverlap value)?  overlap,}){
final _that = this;
switch (_that) {
case DateOn() when on != null:
return on(_that);case DateRange() when range != null:
return range(_that);case DateOverlap() when overlap != null:
return overlap(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime day)?  on,TResult Function( DateTimeRange range)?  range,TResult Function( DateTimeRange range)?  overlap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DateOn() when on != null:
return on(_that.day);case DateRange() when range != null:
return range(_that.range);case DateOverlap() when overlap != null:
return overlap(_that.range);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime day)  on,required TResult Function( DateTimeRange range)  range,required TResult Function( DateTimeRange range)  overlap,}) {final _that = this;
switch (_that) {
case DateOn():
return on(_that.day);case DateRange():
return range(_that.range);case DateOverlap():
return overlap(_that.range);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime day)?  on,TResult? Function( DateTimeRange range)?  range,TResult? Function( DateTimeRange range)?  overlap,}) {final _that = this;
switch (_that) {
case DateOn() when on != null:
return on(_that.day);case DateRange() when range != null:
return range(_that.range);case DateOverlap() when overlap != null:
return overlap(_that.range);case _:
  return null;

}
}

}

/// @nodoc


class DateOn implements DateFilter {
  const DateOn(this.day);
  

 final  DateTime day;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DateOnCopyWith<DateOn> get copyWith => _$DateOnCopyWithImpl<DateOn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateOn&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode => Object.hash(runtimeType,day);

@override
String toString() {
  return 'DateFilter.on(day: $day)';
}


}

/// @nodoc
abstract mixin class $DateOnCopyWith<$Res> implements $DateFilterCopyWith<$Res> {
  factory $DateOnCopyWith(DateOn value, $Res Function(DateOn) _then) = _$DateOnCopyWithImpl;
@useResult
$Res call({
 DateTime day
});




}
/// @nodoc
class _$DateOnCopyWithImpl<$Res>
    implements $DateOnCopyWith<$Res> {
  _$DateOnCopyWithImpl(this._self, this._then);

  final DateOn _self;
  final $Res Function(DateOn) _then;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? day = null,}) {
  return _then(DateOn(
null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class DateRange implements DateFilter {
  const DateRange(this.range);
  

 final  DateTimeRange range;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DateRangeCopyWith<DateRange> get copyWith => _$DateRangeCopyWithImpl<DateRange>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateRange&&(identical(other.range, range) || other.range == range));
}


@override
int get hashCode => Object.hash(runtimeType,range);

@override
String toString() {
  return 'DateFilter.range(range: $range)';
}


}

/// @nodoc
abstract mixin class $DateRangeCopyWith<$Res> implements $DateFilterCopyWith<$Res> {
  factory $DateRangeCopyWith(DateRange value, $Res Function(DateRange) _then) = _$DateRangeCopyWithImpl;
@useResult
$Res call({
 DateTimeRange range
});




}
/// @nodoc
class _$DateRangeCopyWithImpl<$Res>
    implements $DateRangeCopyWith<$Res> {
  _$DateRangeCopyWithImpl(this._self, this._then);

  final DateRange _self;
  final $Res Function(DateRange) _then;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? range = null,}) {
  return _then(DateRange(
null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateTimeRange,
  ));
}


}

/// @nodoc


class DateOverlap implements DateFilter {
  const DateOverlap(this.range);
  

 final  DateTimeRange range;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DateOverlapCopyWith<DateOverlap> get copyWith => _$DateOverlapCopyWithImpl<DateOverlap>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DateOverlap&&(identical(other.range, range) || other.range == range));
}


@override
int get hashCode => Object.hash(runtimeType,range);

@override
String toString() {
  return 'DateFilter.overlap(range: $range)';
}


}

/// @nodoc
abstract mixin class $DateOverlapCopyWith<$Res> implements $DateFilterCopyWith<$Res> {
  factory $DateOverlapCopyWith(DateOverlap value, $Res Function(DateOverlap) _then) = _$DateOverlapCopyWithImpl;
@useResult
$Res call({
 DateTimeRange range
});




}
/// @nodoc
class _$DateOverlapCopyWithImpl<$Res>
    implements $DateOverlapCopyWith<$Res> {
  _$DateOverlapCopyWithImpl(this._self, this._then);

  final DateOverlap _self;
  final $Res Function(DateOverlap) _then;

/// Create a copy of DateFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? range = null,}) {
  return _then(DateOverlap(
null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as DateTimeRange,
  ));
}


}

// dart format on
