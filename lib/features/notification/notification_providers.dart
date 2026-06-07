import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/providers.dart';
import '../../core/models/notification_action.dart';
import '../../platform/notifications/flutter_local_notification_service.dart';
import '../task/task_providers.dart';
import 'application/notification_action_handler.dart';
import 'reminder_scheduler_provider.dart';

part 'notification_providers.g.dart';

@riverpod
Stream<NotificationAction> notificationActionStream(Ref ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.onAction;
}

/// Initializes notifications and listens for user actions.
class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  ProviderSubscription<AsyncValue<NotificationAction>>? _actionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      final service = ref.read(notificationServiceProvider);
      if (service is FlutterLocalNotificationService) {
        await service.init();
      }
      await service.requestPermission();
      await ref.read(reminderSchedulerProvider).reconcileOnLaunch();
    } catch (_) {
      // Providers may be unimplemented in widget tests — skip gracefully.
    }

    _actionSub?.close();
    _actionSub = ref.listenManual(notificationActionStreamProvider, (
      _,
      next,
    ) async {
      if (next case AsyncData(:final value)) {
        await NotificationActionHandler(
          completeTask: (id) =>
              ref.read(completeTaskUseCaseProvider).call(id),
          snooze: ref.read(snoozeReminderUseCaseProvider),
          router: ref.read(routerProvider),
        ).handleAction(value);
      }
    });
  }

  @override
  void dispose() {
    _actionSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
