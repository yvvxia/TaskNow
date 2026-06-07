import '../models/notification_action.dart';
import '../models/notification_request.dart';

/// Notification service contract (module 05), implemented by the platform layer.
abstract interface class INotificationService {
  Future<bool> requestPermission();

  Future<void> schedule(NotificationRequest request);

  Future<void> cancel(int notificationId);

  Future<void> cancelForTask(String taskId);

  /// Platform notification ids currently scheduled but not yet delivered.
  Future<List<int>> pending();

  /// Stream of user interactions with notification actions.
  Stream<NotificationAction> get onAction;
}
