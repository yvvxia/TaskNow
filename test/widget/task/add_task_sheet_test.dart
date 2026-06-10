import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/project.dart';
import 'package:liveline/core/models/task_draft.dart';
import 'package:liveline/features/task/presentation/add_task_sheet.dart';

import '../../fakes/fake_project_repository.dart';

void main() {
  late FakeProjectRepository projects;

  setUp(() {
    projects = FakeProjectRepository()
      ..seed([
        const Project(id: 'p1', name: 'Alpha'),
        const Project(id: 'p2', name: 'Beta'),
      ]);
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required Future<void> Function(TaskDraft draft) onCreate,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectRepositoryProvider.overrideWithValue(projects)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () =>
                      showAddTaskSheet(context, onCreate: onCreate),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('project picker opens a sheet and selects an existing project', (
    tester,
  ) async {
    TaskDraft? created;
    await pumpSheet(tester, onCreate: (d) async => created = d);

    // The picker defaults to the first project (Alpha).
    expect(find.text('Alpha'), findsOneWidget);

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    // Picker sheet lists both projects; choose Beta.
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Write report');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(created, isNotNull);
    expect(created!.title, 'Write report');
    expect(created!.projectId, 'p2');
  });

  testWidgets('picker offers a create-new-project action', (tester) async {
    TaskDraft? created;
    await pumpSheet(tester, onCreate: (d) async => created = d);

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();

    // The picker exposes a new-project entry.
    await tester.tap(find.text('New project'));
    await tester.pumpAndSettle();

    // The project-edit dialog's name field is the last TextField in the tree
    // (the add-task title field sits behind it).
    await tester.enterText(find.byType(TextField).last, 'Gamma');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The newly created project is now the selected one.
    expect(find.text('Gamma'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Task in gamma');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(created, isNotNull);
    final all = await projects.getAll();
    final newProject = all.valueOrNull!.firstWhere((p) => p.name == 'Gamma');
    expect(created!.projectId, newProject.id);
  });

  testWidgets('pre-applies tag ids from the tag view context', (tester) async {
    TaskDraft? created;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectRepositoryProvider.overrideWithValue(projects)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showAddTaskSheet(
                    context,
                    onCreate: (d) async => created = d,
                    tagIds: const ['tag-work'],
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Tagged task');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(created, isNotNull);
    expect(created!.tagIds, ['tag-work']);
    expect(created!.projectId, 'p1');
  });
}
