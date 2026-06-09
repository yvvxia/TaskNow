import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/models/project.dart';
import 'package:liveline/features/project/domain/create_project_usecase.dart';
import 'package:liveline/features/project/domain/delete_project_usecase.dart';
import 'package:liveline/features/project/domain/project_validator.dart';
import 'package:liveline/features/project/domain/update_project_usecase.dart';

import '../../fakes/fake_project_repository.dart';

void main() {
  group('ProjectValidator', () {
    const validator = ProjectValidator();

    test('rejects empty / whitespace names', () {
      expect(validator.validateName('').isErr, isTrue);
      expect(validator.validateName('   ').isErr, isTrue);
      expect(validator.validateName('').errorOrNull?.code, 'emptyProjectName');
    });

    test('accepts a non-empty name', () {
      expect(validator.validateName('Work').isOk, isTrue);
    });
  });

  group('CreateProjectUseCase', () {
    late FakeProjectRepository repo;
    setUp(() => repo = FakeProjectRepository());

    test('creates a trimmed project on a valid name', () async {
      final result = await CreateProjectUseCase(repo)(
        '  Work  ',
        color: '#FF0000',
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.name, 'Work');
      final all = (await repo.getAll()).valueOrNull!;
      expect(all.single.name, 'Work');
      expect(all.single.color, '#FF0000');
    });

    test('fails validation without touching the repository', () async {
      final result = await CreateProjectUseCase(repo)('   ');

      expect(result.isErr, isTrue);
      expect((await repo.getAll()).valueOrNull, isEmpty);
    });
  });

  group('UpdateProjectUseCase', () {
    late FakeProjectRepository repo;
    setUp(() => repo = FakeProjectRepository());

    test('renames an existing project (trimmed)', () async {
      repo.seed([const Project(id: 'p1', name: 'Old')]);

      final result = await UpdateProjectUseCase(repo)(
        const Project(id: 'p1', name: '  New  '),
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.name, 'New');
      expect((await repo.getAll()).valueOrNull!.single.name, 'New');
    });

    test('rejects an empty rename', () async {
      repo.seed([const Project(id: 'p1', name: 'Old')]);

      final result = await UpdateProjectUseCase(repo)(
        const Project(id: 'p1', name: ''),
      );

      expect(result.isErr, isTrue);
      expect((await repo.getAll()).valueOrNull!.single.name, 'Old');
    });
  });

  group('DeleteProjectUseCase', () {
    test('delegates deletion to the repository', () async {
      final repo = FakeProjectRepository()
        ..seed([const Project(id: 'p1', name: 'Gone')]);

      final result = await DeleteProjectUseCase(repo)(
        'p1',
        mode: ProjectDeleteMode.moveToInbox,
      );

      expect(result.isOk, isTrue);
      expect((await repo.getAll()).valueOrNull, isEmpty);
    });
  });
}
