import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/task_draft.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:liveline/data/data_providers.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';
import 'package:liveline/features/calendar/presentation/calendar_providers.dart';
import 'package:liveline/features/task/task_providers.dart';

import '../fakes/fake_project_repository.dart';
import '../fakes/fake_reminder_repository.dart';
import '../fakes/fake_settings_store.dart';
import '../fakes/spy_notification_service.dart';

/// End-to-end flow across the task, notification and calendar modules wired on
/// a real in-memory database (`design/07-testing-strategy.md` §6): creating a
/// task through the use case schedules its reminder (observed via the spy) and
/// the task then surfaces as a bar in the calendar's visible range.
void main() {
  late AppDatabase db;
  late SpyNotificationService notif;
  late FakeReminderRepository reminders;
  late FakeSettingsStore settings;
  late FakeProjectRepository projects;
  late ProviderContainer container;

  // Far-future anchor so the computed reminder always sits after the real
  // wall clock (the calculator drops reminders already in the past).
  final anchor = DateTime.utc(2099, 6, 7, 9);

  setUp(() {
    db = newTestDb();
    notif = SpyNotificationService();
    reminders = FakeReminderRepository();
    settings = FakeSettingsStore();
    projects = FakeProjectRepository();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        taskRepositoryProvider.overrideWithValue(DriftTaskRepository(db)),
        reminderRepositoryProvider.overrideWithValue(reminders),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(settings),
        projectRepositoryProvider.overrideWithValue(projects),
        clockProvider.overrideWith(
          (ref) =>
              () => anchor,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    notif.dispose();
    settings.dispose();
    await db.close();
  });

  test('create task → schedules reminder → appears in calendar range', () async {
    final result = await container
        .read(createTaskUseCaseProvider)
        .call(
          TaskDraft(
            title: 'Write design doc',
            startDate: DateTime.utc(2099, 6, 12),
            dueDate: DateTime.utc(2099, 6, 15, 17),
          ),
        );
    expect(result, isA<Ok>());

    // A reminder was scheduled 15 minutes (default advance) before the due
    // date, recorded by the spy notification service.
    expect(notif.scheduled, hasLength(1));
    expect(
      notif.scheduled.single.scheduledAt,
      DateTime.utc(2099, 6, 15, 16, 45),
    );

    // The task is also persisted in the reminder repository.
    final stored = await reminders.dueBefore(DateTime.utc(2100));
    expect(stored.valueOrNull, hasLength(1));

    // And it surfaces as a bar in the calendar's current (month) window.
    // Keep the stream provider alive while we await its first value, otherwise
    // Riverpod auto-disposes it before the future resolves.
    final sub = container.listen(visibleBarsProvider(null), (_, _) {});
    addTearDown(sub.close);
    final bars = await container.read(visibleBarsProvider(null).future);
    expect(bars, hasLength(1));
    expect(bars.single.task.title, 'Write design doc');
  });

  test('completing the task cancels its scheduled reminder', () async {
    final created = await container
        .read(createTaskUseCaseProvider)
        .call(
          TaskDraft(
            title: 'Submit report',
            dueDate: DateTime.utc(2099, 6, 20, 12),
          ),
        );
    final task = (created as Ok).value;
    expect(notif.scheduled, hasLength(1));

    await container.read(completeTaskUseCaseProvider).call(task.id);

    // Completing a task cancels its notifications for that task id.
    expect(notif.cancelledTaskIds, contains(task.id));
    expect(notif.scheduled, isEmpty);
  });
}
