import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/core/models/task_draft.dart';
import 'package:liveline/data/db/app_database.dart';
import 'package:liveline/data/repositories/drift_project_repository.dart';
import 'package:liveline/data/repositories/drift_reminder_repository.dart';
import 'package:liveline/data/repositories/drift_task_repository.dart';
import 'package:liveline/features/calendar/domain/gantt_drag_intent.dart';
import 'package:liveline/features/calendar/domain/gantt_interaction_controller.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late FakeProjectRepository projects;

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    projects = FakeProjectRepository();
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
        reminderRepositoryProvider.overrideWithValue(reminders),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(settings),
        projectRepositoryProvider.overrideWithValue(projects),
        clockProvider.overrideWith(
          (ref) =>
              () => DateTime.utc(2026, 6, 7),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  GanttInteractionController controller(ProviderContainer c) =>
      c.read(ganttInteractionControllerProvider.notifier);

  test('CreateDrag creates a task spanning the dragged range', () async {
    final container = makeContainer();
    await controller(container).apply(
      CreateDrag(
        start: DateTime.utc(2026, 6, 1),
        end: DateTime.utc(2026, 6, 3),
      ),
    );

    expect(repo.items, hasLength(1));
    expect(repo.items.first.startDate, DateTime.utc(2026, 6, 1));
    expect(repo.items.first.dueDate, DateTime.utc(2026, 6, 3));
  });

  test('MoveDrag shifts both start and due dates by the delta', () async {
    repo.seed([
      Task(
        id: 't1',
        title: 'Move me',
        startDate: DateTime.utc(2026, 6, 5),
        dueDate: DateTime.utc(2026, 6, 7),
      ),
    ]);
    final container = makeContainer();

    await controller(
      container,
    ).apply(const MoveDrag(taskId: 't1', delta: Duration(days: 2)));

    final updated = repo.items.firstWhere((t) => t.id == 't1');
    expect(updated.startDate, DateTime.utc(2026, 6, 7));
    expect(updated.dueDate, DateTime.utc(2026, 6, 9));
  });

  test('valid ResizeDrag(end) extends the due date', () async {
    repo.seed([
      Task(
        id: 't1',
        title: 'Resize me',
        startDate: DateTime.utc(2026, 6, 5),
        dueDate: DateTime.utc(2026, 6, 10),
      ),
    ]);
    final container = makeContainer();

    await controller(container).apply(
      ResizeDrag(
        taskId: 't1',
        edge: DragEdge.end,
        newDate: DateTime.utc(2026, 6, 15),
      ),
    );

    expect(repo.items.first.dueDate, DateTime.utc(2026, 6, 15));
  });

  test(
    'invalid ResizeDrag (due before start) does NOT write to the repo',
    () async {
      final original = Task(
        id: 't1',
        title: 'Keep me',
        startDate: DateTime.utc(2026, 6, 5),
        dueDate: DateTime.utc(2026, 6, 10),
      );
      repo.seed([original]);
      final container = makeContainer();

      await controller(container).apply(
        ResizeDrag(
          taskId: 't1',
          edge: DragEdge.end,
          newDate: DateTime.utc(2026, 6, 1), // before start → invalid
        ),
      );

      // Unchanged: snap-back, no persistence.
      expect(repo.items.first.dueDate, DateTime.utc(2026, 6, 10));
    },
  );

  test(
    'invalid ResizeDrag (start after due) does NOT write to the repo',
    () async {
      repo.seed([
        Task(
          id: 't1',
          title: 'Keep me',
          startDate: DateTime.utc(2026, 6, 5),
          dueDate: DateTime.utc(2026, 6, 10),
        ),
      ]);
      final container = makeContainer();

      await controller(container).apply(
        ResizeDrag(
          taskId: 't1',
          edge: DragEdge.start,
          newDate: DateTime.utc(2026, 6, 20), // after due → invalid
        ),
      );

      expect(repo.items.first.startDate, DateTime.utc(2026, 6, 5));
    },
  );

  test('MoveDrag persists with the real Drift task repository', () async {
    final db = newTestDb();
    addTearDown(db.close);
    final driftTasks = DriftTaskRepository(
      db,
      now: () => DateTime.utc(2026, 6, 7),
    );
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(driftTasks),
        reminderRepositoryProvider.overrideWithValue(
          DriftReminderRepository(db),
        ),
        notificationServiceProvider.overrideWithValue(notif),
        settingsStoreProvider.overrideWithValue(settings),
        projectRepositoryProvider.overrideWithValue(DriftProjectRepository(db)),
        clockProvider.overrideWith(
          (ref) =>
              () => DateTime.utc(2026, 6, 7),
        ),
      ],
    );
    addTearDown(container.dispose);

    final created = await driftTasks.create(
      TaskDraft(
        title: 'Real move',
        startDate: DateTime.utc(2026, 6, 5),
        dueDate: DateTime.utc(2026, 6, 7),
      ),
    );
    final task = created.valueOrNull!;

    await controller(
      container,
    ).apply(MoveDrag(taskId: task.id, delta: const Duration(days: 2)));

    final updated = (await driftTasks.findById(task.id)).valueOrNull!;
    expect(updated.startDate, DateTime.utc(2026, 6, 7));
    expect(updated.dueDate, DateTime.utc(2026, 6, 9));
  });
}
