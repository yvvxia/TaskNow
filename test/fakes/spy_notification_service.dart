import 'dart:async';

import 'package:plan_list/core/contracts/i_notification_service.dart';
import 'package:plan_list/core/models/notification_action.dart';
import 'package:plan_list/core/models/notification_request.dart';

/// Records every call to the notification service for assertions, and lets
/// tests inject [NotificationAction] events via [emitAction].
class SpyNotificationService implements INotificationService {
  final List<String> cancelledTaskIds = [];
  final List<int> cancelledIds = [];
  final List<NotificationRequest> scheduledRequests = [];
  final _pendingIds = <int>{};
  final _actionController = StreamController<NotificationAction>.broadcast();

  /// Convenience alias matching the design doc's `scheduled` accessor.
  List<NotificationRequest> get scheduled => scheduledRequests;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule(NotificationRequest request) async {
    scheduledRequests.add(request);
    _pendingIds.add(request.id);
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelledIds.add(notificationId);
    _pendingIds.remove(notificationId);
  }

  @override
  Future<void> cancelForTask(String taskId) async {
    cancelledTaskIds.add(taskId);
    scheduledRequests.removeWhere((r) {
      if (r.taskId == taskId) {
        _pendingIds.remove(r.id);
        return true;
      }
      return false;
    });
  }

  @override
  Future<List<int>> pending() async => _pendingIds.toList();

  @override
  Stream<NotificationAction> get onAction => _actionController.stream;

  /// Pushes a [NotificationAction] to [onAction] subscribers.
  void emitAction(NotificationAction action) => _actionController.add(action);

  void dispose() => _actionController.close();
}
