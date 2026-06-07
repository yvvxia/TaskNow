import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../core/di/providers.dart';
import 'db/app_database.dart';
import 'repositories/drift_project_repository.dart';
import 'repositories/drift_reminder_repository.dart';
import 'repositories/drift_tag_repository.dart';
import 'repositories/drift_task_repository.dart';

/// Provides the singleton [AppDatabase]. Throws until overridden in `main()`
/// (or tests) with a concrete database — see
/// `design/00-architecture-overview.md` §8. Kept in the data layer because it
/// references the concrete [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'Override appDatabaseProvider in main() before use.',
  ),
);

/// Builds the Riverpod overrides that wire the Drift data layer onto the
/// abstract repository providers declared in `core/di`. Pass the result to a
/// [ProviderScope] in `main()`:
///
/// ```dart
/// final db = AppDatabase(openConnection());
/// runApp(ProviderScope(overrides: driftDataLayerOverrides(db), child: ...));
/// ```
List<Override> driftDataLayerOverrides(AppDatabase db) => <Override>[
      appDatabaseProvider.overrideWithValue(db),
      taskRepositoryProvider.overrideWithValue(DriftTaskRepository(db)),
      projectRepositoryProvider.overrideWithValue(DriftProjectRepository(db)),
      tagRepositoryProvider.overrideWithValue(DriftTagRepository(db)),
      reminderRepositoryProvider.overrideWithValue(DriftReminderRepository(db)),
    ];
