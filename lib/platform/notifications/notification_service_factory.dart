import '../../core/contracts/i_notification_service.dart';
import 'flutter_local_notification_service.dart';
import 'windows_notification_service.dart';

/// Creates the platform-appropriate [INotificationService] implementation.
INotificationService createPlatformNotificationService() {
  if (const bool.fromEnvironment('FLUTTER_TEST')) {
    return WindowsNotificationService();
  }
  return FlutterLocalNotificationService();
}
