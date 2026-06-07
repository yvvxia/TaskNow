import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/enums/enums.dart';
import 'package:plan_list/core/models/task.dart';
import 'package:plan_list/features/task/presentation/task_tile.dart';
import 'package:plan_list/features/task/presentation/task_view.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: SizedBox(width: 360, child: child),
      ),
    );

TaskView makeView(Task task, {DateTime? now}) =>
    TaskView.from(task, now ?? DateTime.utc(2026, 6, 7));

void main() {
  group('TaskTile goldens', () {
    testWidgets('normal state', (tester) async {
      final view = makeView(
        Task(
          id: '1',
          title: 'Buy groceries',
          priority: Priority.medium,
          dueDate: DateTime.utc(2026, 6, 15),
        ),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskTile),
        matchesGoldenFile('goldens/task_tile_normal.png'),
      );
    });

    testWidgets('completed state', (tester) async {
      final view = makeView(
        Task(
          id: '2',
          title: 'Walk the dog',
          status: TaskStatus.complete,
          priority: Priority.low,
          completedAt: DateTime.utc(2026, 6, 7),
        ),
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskTile),
        matchesGoldenFile('goldens/task_tile_completed.png'),
      );
    });

    testWidgets('overdue state', (tester) async {
      final overdueClock = DateTime.utc(2026, 6, 15);
      final view = makeView(
        Task(
          id: '3',
          title: 'Submit report',
          priority: Priority.high,
          dueDate: DateTime.utc(2026, 6, 10),
        ),
        now: overdueClock,
      );
      await tester.pumpWidget(wrap(TaskTile(task: view)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TaskTile),
        matchesGoldenFile('goldens/task_tile_overdue.png'),
      );
    });
  });
}
