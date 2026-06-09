import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/task.dart';
import 'package:liveline/core/theme/semantic_colors.dart';
import 'package:liveline/features/task/presentation/task_tile.dart';
import 'package:liveline/features/task/presentation/task_view.dart';

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

    testWidgets('shows priority badge', (tester) async {
      final view = makeView(
        const Task(id: '1', title: 'P', priority: Priority.high),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      expect(find.text('High'), findsOneWidget);
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
    testWidgets('shows overdue badge and red date', (tester) async {
      final now = DateTime.utc(2026, 6, 15);
      final view = makeView(
        Task(id: '1', title: 'Late', dueDate: DateTime.utc(2026, 6, 10)),
        now: now,
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      expect(find.text('Overdue'), findsOneWidget);
      final dateText = tester.widget<Text>(find.textContaining('6/10'));
      expect(
        dateText.style?.color,
        SemanticColors.colorForPriority(Priority.high),
      );
    });

    testWidgets('title is NOT struck through for overdue', (tester) async {
      final now = DateTime.utc(2026, 6, 15);
      final view = makeView(
        Task(id: '1', title: 'Overdue', dueDate: DateTime.utc(2026, 6, 10)),
        now: now,
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));

      final titleWidgets = tester.widgetList<Text>(find.text('Overdue'));
      expect(
        titleWidgets.any(
          (t) => t.style?.decoration != TextDecoration.lineThrough,
        ),
        isTrue,
      );
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

    testWidgets('tapping row calls onTap', (tester) async {
      var tapped = false;
      final view = makeView(const Task(id: '1', title: 'T'));
      await tester.pumpWidget(
        wrap(TaskTile(task: view, onTap: () => tapped = true)),
      );

      await tester.tap(find.text('T'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
