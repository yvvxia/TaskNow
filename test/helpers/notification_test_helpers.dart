import 'package:plan_list/features/notification/application/reminder_scheduler.dart';
import 'package:plan_list/features/notification/domain/reminder_calculator.dart';

import 'fake_settings_store.dart';
import 'fakes.dart';

ReminderScheduler makeTestReminderScheduler({
  required FakeTaskRepository repo,
  required FakeReminderRepository reminders,
  required SpyNotificationService notif,
  FakeSettingsStore? settings,
}) {
  return ReminderScheduler(
    const ReminderCalculator(),
    reminders,
    notif,
    settings ?? FakeSettingsStore(),
    repo,
    FakeProjectRepository(),
  );
}
