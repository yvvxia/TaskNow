import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../../core/contracts/i_notification_service.dart';
import '../../core/di/providers.dart';
import '../../../platform/notifications/notification_service_factory.dart';
import 'application/reminder_scheduler.dart';
import 'application/snooze_reminder_usecase.dart';
import 'domain/reminder_calculator.dart';

final reminderCalculatorProvider = Provider<ReminderCalculator>(
  (ref) => const ReminderCalculator(),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(
    ref.watch(reminderCalculatorProvider),
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsStoreProvider),
    ref.watch(taskRepositoryProvider),
    ref.watch(projectRepositoryProvider),
  ),
);

final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>(
  (ref) => SnoozeReminderUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(notificationServiceProvider),
  ),
);

/// Default production notification service (overridable in tests).
final defaultNotificationServiceProvider = Provider<INotificationService>(
  (ref) => createPlatformNotificationService(),
);

/// Helper for tests: override [notificationServiceProvider] with a spy/fake.
Override notificationServiceOverride(INotificationService service) =>
    notificationServiceProvider.overrideWithValue(service);
