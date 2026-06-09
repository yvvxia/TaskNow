import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/contracts/i_project_repository.dart';
import 'package:liveline/core/contracts/i_reminder_repository.dart';
import 'package:liveline/core/contracts/i_tag_repository.dart';
import 'package:liveline/core/contracts/i_task_repository.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/data/data_providers.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_project_repository.dart';
import 'package:liveline/data/repositories/drift_reminder_repository.dart';
import 'package:liveline/data/repositories/drift_tag_repository.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';

void main() {
  test('appDatabaseProvider throws until overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(appDatabaseProvider),
      throwsA(
        predicate<Object>((e) => e.toString().contains('appDatabaseProvider')),
      ),
    );
  });

  test('driftDataLayerOverrides wires concrete Drift repositories', () {
    final db = newTestDb();
    addTearDown(db.close);

    final container = ProviderContainer(overrides: driftDataLayerOverrides(db));
    addTearDown(container.dispose);

    expect(container.read(appDatabaseProvider), same(db));
    expect(container.read(taskRepositoryProvider), isA<DriftTaskRepository>());
    expect(
      container.read(projectRepositoryProvider),
      isA<DriftProjectRepository>(),
    );
    expect(container.read(tagRepositoryProvider), isA<DriftTagRepository>());
    expect(
      container.read(reminderRepositoryProvider),
      isA<DriftReminderRepository>(),
    );

    // The concrete repositories satisfy their abstract contracts.
    expect(container.read(taskRepositoryProvider), isA<ITaskRepository>());
    expect(
      container.read(projectRepositoryProvider),
      isA<IProjectRepository>(),
    );
    expect(container.read(tagRepositoryProvider), isA<ITagRepository>());
    expect(
      container.read(reminderRepositoryProvider),
      isA<IReminderRepository>(),
    );
  });
}
