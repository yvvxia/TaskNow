import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/enums.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Minimal placeholder Reminder entity. Module 05 (notification) fleshes this
/// out with scheduling details.
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String taskId,
    required DateTime triggerAt,
    @Default(ReminderType.beforeDue) ReminderType type,
    @Default(false) bool isFired,

    /// For [ReminderType.beforeDue]: minutes before the due date.
    int? offsetMin,

    /// Platform notification id (int) used to cancel the scheduled notification.
    int? notifId,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
