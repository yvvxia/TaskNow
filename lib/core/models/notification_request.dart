import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_request.freezed.dart';

/// Describes a local notification to be scheduled by [INotificationService].
@freezed
abstract class NotificationRequest with _$NotificationRequest {
  const factory NotificationRequest({
    required int id,
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) = _NotificationRequest;
}
