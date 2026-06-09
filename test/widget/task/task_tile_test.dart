import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/task/presentation/task_tile.dart';
import 'package:plan_list/features/task/presentation/task_view.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

TaskView makeView(Task task, {DateTime? now}) =>
    TaskView.from(task, now ?? DateTime.utc(2026, 6, 7));

void main() {
  group('TaskTile – normal state', () {
    testWidgets('renders checkbox and title', (tester) async {
      final view = makeView(const Task(id: '1', title: 'Buy milk'));
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      expect(find.byKey(const Key('checkbox-1')), findsOneWidget);
      expect(find.text('Buy milk'), findsOneWidget);
    });

    testWidgets('checkbox is unchecked for incomplete task', (tester) async {
      final view = makeView(const Task(id: '1', title: 'T'));
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      final cb = tester.widget<Checkbox>(find.byKey(const Key('checkbox-1')));
      expect(cb.value, isFalse);
    });

    testWidgets('shows priority dot', (tester) async {
      final view = makeView(
        const Task(id: '1', title: 'P', priority: Priority.high),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      // Container with circle decoration is rendered in trailing.
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows date range label when dueDate present', (tester) async {
      final view = makeView(
        Task(id: '1', title: 'T', dueDate: DateTime.utc(2026, 6, 15)),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      expect(find.textContaining('6/15'), findsOneWidget);
    });
  });

  group('TaskTile – completed state', () {
    testWidgets('title has strikethrough decoration', (tester) async {
      final view = makeView(
        const Task(id: '1', title: 'Done', status: TaskStatus.complete),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      final titleWidget = tester.widget<Text>(find.text('Done'));
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('checkbox is checked', (tester) async {
      final view = makeView(
        const Task(id: '1', title: 'Done', status: TaskStatus.complete),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      final cb = tester.widget<Checkbox>(find.byKey(const Key('checkbox-1')));
      expect(cb.value, isTrue);
    });
  });

  group('TaskTile – overdue state', () {
    testWidgets('date shown in red', (tester) async {
      final now = DateTime.utc(2026, 6, 15);
      final view = makeView(
        Task(id: '1', title: 'Late', dueDate: DateTime.utc(2026, 6, 10)),
        now: now,
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      // Find the subtitle Text widget and check its color.
      final texts = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListTile), matching: find.byType(Text)),
      );

      final dateTexts = texts
          .where((t) => t.style?.color == Colors.red)
          .toList();
      expect(dateTexts, isNotEmpty);
    });

    testWidgets('title is NOT struck through for overdue', (tester) async {
      final now = DateTime.utc(2026, 6, 15);
      final view = makeView(
        Task(id: '1', title: 'Overdue', dueDate: DateTime.utc(2026, 6, 10)),
        now: now,
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      final titleWidget = tester.widget<Text>(find.text('Overdue'));
      expect(titleWidget.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });

  group('TaskTile – interaction', () {
    testWidgets('tapping checkbox calls onComplete', (tester) async {
      var called = false;
      final view = makeView(const Task(id: '1', title: 'T'));
      await tester.pumpWidget(
        wrap(TaskTile(task: view, onComplete: () => called = true)),
      );

      await tester.tap(find.byKey(const Key('checkbox-1')));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('tapping tile calls onTap', (tester) async {
      var tapped = false;
      final view = makeView(const Task(id: '1', title: 'T'));
      await tester.pumpWidget(
        wrap(TaskTile(task: view, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
