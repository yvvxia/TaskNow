import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/models/task_draft.dart';
import 'package:plan_list/core/utils/result.dart';
import 'package:plan_list/features/notification/application/reminder_scheduler.dart';
import 'package:plan_list/features/notification/domain/reminder_calculator.dart';
import 'package:plan_list/features/task/domain/create_task_usecase.dart';

import '../../helpers/fake_settings_store.dart';
import '../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository repo;
  late FakeReminderRepository reminders;
  late SpyNotificationService notif;
  late FakeSettingsStore settings;
  late CreateTaskUseCase useCase;

  setUp(() {
    repo = FakeTaskRepository();
    reminders = FakeReminderRepository();
    notif = SpyNotificationService();
    settings = FakeSettingsStore();
    final scheduler = ReminderScheduler(
      const ReminderCalculator(),
      reminders,
      notif,
      settings,
      repo,
      FakeProjectRepository(),
    );
    useCase = CreateTaskUseCase(repo, scheduler);
  });

  tearDown(() {
    repo.dispose();
    notif.dispose();
    settings.dispose();
  });

  test('empty title → ValidationException with code emptyTitle', () async {
    final result = await useCase(const TaskDraft(title: ''));
    expect(result.isErr, isTrue);
    final err = result.errorOrNull as ValidationException;
    expect(err.code, 'emptyTitle');
  });

  test('whitespace-only title → ValidationException', () async {
    final result = await useCase(const TaskDraft(title: '   '));
    expect(result.isErr, isTrue);
    expect(result.errorOrNull, isA<ValidationException>());
  });

  test('dueDate before startDate → ValidationException', () async {
    final result = await useCase(
      TaskDraft(
        title: 'Bad dates',
        startDate: DateTime.utc(2026, 6, 10),
        dueDate: DateTime.utc(2026, 6, 5),
      ),
    );
    expect(result.isErr, isTrue);
    final err = result.errorOrNull as ValidationException;
    expect(err.code, 'dueBeforeStart');
  });

  test('valid draft creates task in repository', () async {
    final result = await useCase(const TaskDraft(title: 'Buy groceries'));
    expect(result.isOk, isTrue);
    expect(repo.items, hasLength(1));
    expect(repo.items.first.title, 'Buy groceries');
  });

  test('valid draft returns Ok(Task)', () async {
    final result = await useCase(const TaskDraft(title: 'Walk dog'));
    expect(result, isA<Ok>());
    expect(result.valueOrNull?.title, 'Walk dog');
  });

  test('startDate == dueDate is valid (boundary)', () async {
    final date = DateTime.utc(2026, 6, 7);
    final result = await useCase(
      TaskDraft(title: 'Same day', startDate: date, dueDate: date),
    );
    expect(result.isOk, isTrue);
  });

  test('startDate < dueDate is valid', () async {
    final result = await useCase(
      TaskDraft(
        title: 'Ranged',
        startDate: DateTime.utc(2026, 6, 5),
        dueDate: DateTime.utc(2026, 6, 10),
      ),
    );
    expect(result.isOk, isTrue);
  });
}
