import 'package:flutter/material.dart';

/// Inclusive time-of-day range that may wrap past midnight.
class TimeRange {
  const TimeRange(this.startMinutes, this.endMinutes);

  final int startMinutes;
  final int endMinutes;

  bool containsMinutes(int minutesOfDay) {
    if (startMinutes <= endMinutes) {
      return minutesOfDay >= startMinutes && minutesOfDay < endMinutes;
    }
    // Wraps midnight, e.g. 22:00 – 08:00.
    return minutesOfDay >= startMinutes || minutesOfDay < endMinutes;
  }

  bool containsTimeOfDay(TimeOfDay time) =>
      containsMinutes(time.hour * 60 + time.minute);
}
