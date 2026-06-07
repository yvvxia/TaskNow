import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/features/notification/application/notification_action_handler.dart';
import 'package:plan_list/features/notification/application/snooze_reminder_usecase.dart';
import 'package:plan_list/features/notification/domain/notification_action_type.dart';
import 'package:plan_list/features/notification/reminder_scheduler_provider.dart';
import 'package:plan_list/features/task/task_providers.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  test('parseNotificationActionType maps action ids', () {
    expect(
      parseNotificationActionType('markDone'),
      NotificationActionType.markDone,
    );
    expect(parseNotificationActionType('done'), NotificationActionType.markDone);
    expect(parseNotificationActionType('snooze'), NotificationActionType.snooze);
    expect(parseNotificationActionType('open'), NotificationActionType.open);
    expect(parseNotificationActionType('unknown'), isNull);
  });

  test('handler markDone completes task via use case', () async {
    final repo = FakeTaskRepository();
    final reminders = FakeReminderRepository();
    final notif = SpyNotificationService();
    final router = GoRouter(routes: []);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        reminderRepositoryProvider.overrideWithValue(reminders),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(FakeSettingsStore()),
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
        routerProvider.overrideWithValue(router),
      ],
    );
    addTearDown(container.dispose);

    await repo.create(const TaskDraft(title: 'Action task'));
    final taskId = repo.items.single.id;

    await NotificationActionHandler(
      completeTask: (id) => container.read(completeTaskUseCaseProvider).call(id),
      snooze: container.read(snoozeReminderUseCaseProvider),
      router: router,
    ).handle(taskId, NotificationActionType.markDone);

    expect(repo.items.single.status, TaskStatus.complete);
  });

  test('handler snooze schedules notification', () async {
    final repo = FakeTaskRepository();
    final notif = SpyNotificationService();

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        notificationServiceProvider.overrideWithValue(notif),
        routerProvider.overrideWithValue(GoRouter(routes: [])),
      ],
    );
    addTearDown(container.dispose);

    await repo.create(const TaskDraft(title: 'Snooze me'));
    final taskId = repo.items.single.id;

    await NotificationActionHandler(
      completeTask: (id) => container.read(completeTaskUseCaseProvider).call(id),
      snooze: container.read(snoozeReminderUseCaseProvider),
      router: container.read(routerProvider),
    ).handle(taskId, NotificationActionType.snooze);

    expect(notif.scheduledRequests, hasLength(1));
    expect(notif.scheduledRequests.single.taskId, taskId);
  });

  test('handler open navigates to task detail route', () async {
    final router = GoRouter(
      initialLocation: '/tasks',
      routes: [
        GoRoute(path: '/tasks', builder: (_, _) => const SizedBox()),
        GoRoute(
          path: '/task/:id',
          builder: (_, state) => Text(state.pathParameters['id']!),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [routerProvider.overrideWithValue(router)],
    );
    addTearDown(container.dispose);

    await NotificationActionHandler(
      completeTask: (_) async {},
      snooze: SnoozeReminderUseCase(
        FakeTaskRepository(),
        SpyNotificationService(),
      ),
      router: router,
    ).handle('abc-123', NotificationActionType.open);

    expect(router.routeInformationProvider.value.uri.path, '/task/abc-123');
  });
}
