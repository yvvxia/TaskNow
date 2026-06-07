import 'dart:async';

import '../../core/contracts/i_notification_service.dart';
import '../../core/models/notification_action.dart';
import '../../core/models/notification_request.dart';

/// Test-friendly Windows notification stub that records calls without OS toasts.
class WindowsNotificationService implements INotificationService {
  final List<NotificationRequest> scheduledRequests = [];
  final List<int> cancelledIds = [];
  final List<String> cancelledTaskIds = [];
  final _pendingIds = <int>{};
  final _actionController = StreamController<NotificationAction>.broadcast();

  @override
  Stream<NotificationAction> get onAction => _actionController.stream;

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

  void emitAction(NotificationAction action) {
    if (!_actionController.isClosed) {
      _actionController.add(action);
    }
  }

  Future<void> dispose() async {
    await _actionController.close();
  }
}
