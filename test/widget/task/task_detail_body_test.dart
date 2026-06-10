import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/subtask.dart';
import 'package:liveline/core/models/tag.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/features/task/presentation/task_detail_body.dart';

import '../../fakes/fake_project_repository.dart';
import '../../fakes/fake_reminder_repository.dart';
import '../../fakes/fake_settings_store.dart';
import '../../fakes/fake_tag_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/spy_notification_service.dart';

void main() {
  late FakeTaskRepository tasks;
  late FakeTagRepository tags;

  setUp(() {
    tasks = FakeTaskRepository()
      ..seed([
        const Task(
          id: 't1',
          title: 'Alpha',
          notes: '# Hello\n\n**bold**',
          tagIds: ['tag1'],
          subtasks: [Subtask(id: 's1', title: 'Sub one')],
        ),
      ]);
    tags = FakeTagRepository()
      ..seed([const Tag(id: 'tag1', name: 'Work')]);
  });

  Widget wrap({double height = 700}) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(tasks),
        tagRepositoryProvider.overrideWithValue(tags),
        reminderRepositoryProvider.overrideWithValue(FakeReminderRepository()),
        notificationServiceProvider.overrideWithValue(SpyNotificationService()),
        settingsStoreProvider.overrideWithValue(FakeSettingsStore()),
        projectRepositoryProvider.overrideWithValue(FakeProjectRepository()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: height,
            child: const TaskDetailBody(taskId: 't1'),
          ),
        ),
      ),
    );
  }

  testWidgets('shows note editor and preview toggle', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notes-editor')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notes-preview')), findsOneWidget);
  });

  testWidgets('shows compact toolbar with dates, priority, and more menu',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detail-dates-button')), findsOneWidget);
    expect(find.byKey(const Key('detail-priority')), findsOneWidget);
    expect(find.byKey(const Key('detail-more-menu')), findsOneWidget);
  });

  testWidgets('more menu contains recurrence, reminders, info, and delete',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('detail-more-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Recurrence'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
    expect(find.byKey(const Key('detail-delete')), findsOneWidget);
  });

  testWidgets('delete via more menu confirms then removes the task',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('detail-more-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('detail-delete')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(tasks.items.any((t) => t.id == 't1'), isFalse);
  });

  testWidgets('delete can be cancelled', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('detail-more-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('detail-delete')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(tasks.items.any((t) => t.id == 't1'), isTrue);
  });

  testWidgets('shows assigned tag chip and add-tag control', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tag-chip-tag1')), findsOneWidget);
    expect(find.byKey(const Key('detail-add-tag')), findsOneWidget);
  });

  testWidgets('subtasks render and can be added', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('subtask-s1')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('add-subtask-field')), 'New sub');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final updated = tasks.items.firstWhere((t) => t.id == 't1');
    expect(updated.subtasks.map((s) => s.title), contains('New sub'));
  });
}
