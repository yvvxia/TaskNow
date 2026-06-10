import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:liveline/features/notification/application/reminder_scheduler.dart';
import 'package:liveline/features/notification/domain/reminder_calculator.dart';
import 'package:liveline/features/task/domain/reminder_template.dart';
import 'package:liveline/features/task/domain/set_task_reminders_usecase.dart';

import '../../fakes/fake_project_repository.dart';
import '../../fakes/fake_reminder_repository.dart';
import '../../fakes/fake_settings_store.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/spy_notification_service.dart';

void main() {
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late ReminderScheduler scheduler;
  late SetTaskRemindersUseCase useCase;

  setUp(() {
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    scheduler = ReminderScheduler(
      const ReminderCalculator(),
      reminders,
      notif,
      FakeSettingsStore(),
      FakeTaskRepository(),
      FakeProjectRepository(),
    );
    useCase = SetTaskRemindersUseCase(reminders, scheduler);
  });

  tearDown(() => notif.dispose());

  test('persists templates and schedules notifications', () async {
    final due = DateTime.now().toUtc().add(const Duration(days: 1));
    final task = Task(id: 't1', title: 'Due soon', dueDate: due);

    final result = await useCase.call(task, const [
      ReminderTemplate(type: ReminderType.beforeDue, offsetMin: 15),
    ]);

    expect(result, isA<Ok<void>>());
    final stored = await reminders.getByTask('t1');
    expect(stored.valueOrNull, hasLength(1));
    expect(stored.valueOrNull!.first.type, ReminderType.beforeDue);
    expect(stored.valueOrNull!.first.offsetMin, 15);
    expect(notif.scheduledRequests, isNotEmpty);
  });

  test('clears reminders when given an empty list', () async {
    final due = DateTime.now().toUtc().add(const Duration(days: 1));
    final task = Task(id: 't2', title: 'Clear', dueDate: due);

    await useCase.call(task, const [
      ReminderTemplate(type: ReminderType.beforeDue, offsetMin: 5),
    ]);
    await useCase.call(task, const []);

    final stored = await reminders.getByTask('t2');
    expect(stored.valueOrNull, isEmpty);
  });
}
