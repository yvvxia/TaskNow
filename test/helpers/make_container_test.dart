import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/di/clock.dart';
import 'package:plan_list/core/di/providers.dart';
import 'package:plan_list/features/task/task_providers.dart';

import '../fakes/fake_task_repository.dart';
import '../fakes/make_container.dart';
import '../fakes/spy_notification_service.dart';

void main() {
  test('makeContainer wires every infrastructure provider with a fake', () {
    final container = makeContainer();
    addTearDown(container.dispose);

    // None of these throw UnimplementedError because all are overridden.
    expect(container.read(taskRepositoryProvider), isNotNull);
    expect(container.read(reminderRepositoryProvider), isNotNull);
    expect(container.read(notificationServiceProvider), isNotNull);
    expect(container.read(settingsStoreProvider), isNotNull);
    expect(container.read(projectRepositoryProvider), isNotNull);
    expect(container.read(tagRepositoryProvider), isNotNull);
    expect(container.read(syncEngineProvider), isNotNull);
  });

  test('clock defaults to kTestNow and is overridable', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    expect(container.read(clockProvider)(), kTestNow);

    final custom = DateTime.utc(2030, 1, 1);
    final container2 = makeContainer(now: custom);
    addTearDown(container2.dispose);
    expect(container2.read(clockProvider)(), custom);
  });

  test('injected fakes are the same instances the container resolves', () {
    final tasks = FakeTaskRepository();
    final notif = SpyNotificationService();
    final container = makeContainer(tasks: tasks, notif: notif);
    addTearDown(container.dispose);
    addTearDown(tasks.dispose);
    addTearDown(notif.dispose);

    expect(identical(container.read(taskRepositoryProvider), tasks), isTrue);
    expect(
      identical(container.read(notificationServiceProvider), notif),
      isTrue,
    );
  });

  test('downstream use-case providers resolve against the fakes', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    // Building this exercises the full reminderScheduler dependency graph.
    expect(container.read(createTaskUseCaseProvider), isNotNull);
    expect(container.read(completeTaskUseCaseProvider), isNotNull);
  });
}
