import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_action.freezed.dart';

/// Emitted when the user interacts with a notification action
/// (e.g. "mark done", "snooze").
@freezed
abstract class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String taskId,
    required String actionId,
  }) = _NotificationAction;
}
