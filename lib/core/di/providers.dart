import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../contracts/i_notification_service.dart';
import '../contracts/i_project_repository.dart';
import '../contracts/i_reminder_repository.dart';
import '../contracts/i_settings_store.dart';
import '../contracts/i_sync_engine.dart';
import '../contracts/i_tag_repository.dart';
import '../contracts/i_task_repository.dart';

/// Infrastructure providers. Each throws [UnimplementedError] until it is
/// overridden in `main()` (or in tests) with a concrete implementation. This
/// is the dependency-inversion seam described in
/// `design/00-architecture-overview.md` §3.1 / §8.

Never _unimplemented(String name) =>
    throw UnimplementedError('Override $name in main() before use.');

final taskRepositoryProvider = Provider<ITaskRepository>(
  (ref) => _unimplemented('taskRepositoryProvider'),
);

final projectRepositoryProvider = Provider<IProjectRepository>(
  (ref) => _unimplemented('projectRepositoryProvider'),
);

final tagRepositoryProvider = Provider<ITagRepository>(
  (ref) => _unimplemented('tagRepositoryProvider'),
);

final reminderRepositoryProvider = Provider<IReminderRepository>(
  (ref) => _unimplemented('reminderRepositoryProvider'),
);

final notificationServiceProvider = Provider<INotificationService>(
  (ref) => _unimplemented('notificationServiceProvider'),
);

final settingsStoreProvider = Provider<ISettingsStore>(
  (ref) => _unimplemented('settingsStoreProvider'),
);

final syncEngineProvider = Provider<ISyncEngine>(
  (ref) => _unimplemented('syncEngineProvider'),
);
