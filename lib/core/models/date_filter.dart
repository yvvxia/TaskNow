import 'package:flutter/material.dart' show DateTimeRange;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_filter.freezed.dart';

/// Date constraint for [TaskQuery]. Module 04 search & calendar overlap reads.
@freezed
sealed class DateFilter with _$DateFilter {
  /// Tasks due (or starting) on a single calendar day.
  const factory DateFilter.on(DateTime day) = DateOn;

  /// Tasks whose due date falls within the inclusive range.
  const factory DateFilter.range(DateTimeRange range) = DateRange;

  /// Tasks whose effective date span intersects the range (calendar / Gantt).
  const factory DateFilter.overlap(DateTimeRange range) = DateOverlap;
}
