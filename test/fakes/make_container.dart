import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:plan_list/core/contracts/i_notification_service.dart';
import 'package:plan_list/core/contracts/i_project_repository.dart';
import 'package:plan_list/core/contracts/i_reminder_repository.dart';
import 'package:plan_list/core/contracts/i_settings_store.dart';
import 'package:plan_list/core/contracts/i_sync_engine.dart';
import 'package:plan_list/core/contracts/i_tag_repository.dart';
import 'package:plan_list/core/contracts/i_task_repository.dart';
import 'package:plan_list/core/di/clock.dart';
import 'package:plan_list/core/di/providers.dart';

import 'fake_project_repository.dart';
import 'fake_reminder_repository.dart';
import 'fake_settings_store.dart';
import 'fake_sync_engine.dart';
import 'fake_tag_repository.dart';
import 'fake_task_repository.dart';
import 'spy_notification_service.dart';

/// Default fixed clock used across tests for deterministic time logic
/// (`design/07-testing-strategy.md` §3).
final DateTime kTestNow = DateTime.utc(2026, 6, 7, 9);

/// Builds a [ProviderContainer] with the standard set of infrastructure
/// overrides replaced by in-memory fakes, so any module can be exercised in
/// isolation without touching a real DB or platform service.
///
/// Pass concrete fakes to assert on their recorded state; otherwise sensible
/// defaults are created. Remember to `addTearDown(container.dispose)`.
ProviderContainer makeContainer({
  ITaskRepository? tasks,
  IReminderRepository? reminders,
  INotificationService? notif,
  ISettingsStore? settings,
  IProjectRepository? projects,
  ITagRepository? tags,
  ISyncEngine? sync,
  DateTime? now,
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      taskRepositoryProvider.overrideWithValue(tasks ?? FakeTaskRepository()),
      reminderRepositoryProvider.overrideWithValue(
        reminders ?? FakeReminderRepository(),
      ),
      notificationServiceProvider.overrideWithValue(
        notif ?? SpyNotificationService(),
      ),
      settingsStoreProvider.overrideWithValue(settings ?? FakeSettingsStore()),
      projectRepositoryProvider.overrideWithValue(
        projects ?? FakeProjectRepository(),
      ),
      tagRepositoryProvider.overrideWithValue(tags ?? FakeTagRepository()),
      syncEngineProvider.overrideWithValue(sync ?? FakeSyncEngine()),
      clockProvider.overrideWith(
        (ref) =>
            () => now ?? kTestNow,
      ),
      ...overrides,
    ],
  );
}
