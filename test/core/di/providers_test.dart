import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/contracts/i_notification_service.dart';
import 'package:plan_list/core/contracts/i_project_repository.dart';
import 'package:plan_list/core/contracts/i_reminder_repository.dart';
import 'package:plan_list/core/contracts/i_settings_store.dart';
import 'package:plan_list/core/contracts/i_sync_engine.dart';
import 'package:plan_list/core/contracts/i_tag_repository.dart';
import 'package:plan_list/core/contracts/i_task_repository.dart';
import 'package:plan_list/core/di/providers.dart';

class _FakeTaskRepository implements ITaskRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeProjectRepository implements IProjectRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeTagRepository implements ITagRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeReminderRepository implements IReminderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeNotificationService implements INotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeSettingsStore implements ISettingsStore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeSyncEngine implements ISyncEngine {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Riverpod 3 wraps the error thrown during provider creation in a
/// `ProviderException`, so we assert on the underlying message instead of the
/// raw [UnimplementedError] type.
Matcher _throwsUnimplemented(String providerName) => throwsA(
      predicate<Object>(
        (e) =>
            e.toString().contains('UnimplementedError') &&
            e.toString().contains(providerName),
      ),
    );

void main() {
  test('infrastructure providers throw UnimplementedError until overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(taskRepositoryProvider),
        _throwsUnimplemented('taskRepositoryProvider'));
    expect(() => container.read(projectRepositoryProvider),
        _throwsUnimplemented('projectRepositoryProvider'));
    expect(() => container.read(tagRepositoryProvider),
        _throwsUnimplemented('tagRepositoryProvider'));
    expect(() => container.read(reminderRepositoryProvider),
        _throwsUnimplemented('reminderRepositoryProvider'));
    expect(() => container.read(notificationServiceProvider),
        _throwsUnimplemented('notificationServiceProvider'));
    expect(() => container.read(settingsStoreProvider),
        _throwsUnimplemented('settingsStoreProvider'));
    expect(() => container.read(syncEngineProvider),
        _throwsUnimplemented('syncEngineProvider'));
  });

  test('fake implementations replace the real providers via overrides', () {
    final taskRepo = _FakeTaskRepository();
    final projectRepo = _FakeProjectRepository();
    final tagRepo = _FakeTagRepository();
    final reminderRepo = _FakeReminderRepository();
    final notif = _FakeNotificationService();
    final settings = _FakeSettingsStore();
    final sync = _FakeSyncEngine();

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepo),
        projectRepositoryProvider.overrideWithValue(projectRepo),
        tagRepositoryProvider.overrideWithValue(tagRepo),
        reminderRepositoryProvider.overrideWithValue(reminderRepo),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(settings),
        syncEngineProvider.overrideWithValue(sync),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(taskRepositoryProvider), same(taskRepo));
    expect(container.read(projectRepositoryProvider), same(projectRepo));
    expect(container.read(tagRepositoryProvider), same(tagRepo));
    expect(container.read(reminderRepositoryProvider), same(reminderRepo));
    expect(container.read(notificationServiceProvider), same(notif));
    expect(container.read(settingsStoreProvider), same(settings));
    expect(container.read(syncEngineProvider), same(sync));
  });
}
