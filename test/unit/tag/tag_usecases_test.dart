import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/features/tag/domain/create_tag_usecase.dart';
import 'package:liveline/features/tag/domain/tag_validator.dart';

import '../../fakes/fake_tag_repository.dart';

void main() {
  group('TagValidator', () {
    const validator = TagValidator();

    test('rejects empty / whitespace names', () {
      expect(validator.validateName('').isErr, isTrue);
      expect(validator.validateName('   ').isErr, isTrue);
      expect(validator.validateName('').errorOrNull?.code, 'emptyTagName');
    });

    test('accepts a non-empty name', () {
      expect(validator.validateName('Urgent').isOk, isTrue);
    });
  });

  group('CreateTagUseCase', () {
    late FakeTagRepository repo;
    setUp(() => repo = FakeTagRepository());

    test('creates a trimmed tag on a valid name', () async {
      final result = await CreateTagUseCase(repo)(
        '  Urgent  ',
        color: '#FF0000',
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.name, 'Urgent');
      final all = (await repo.getAll()).valueOrNull!;
      expect(all.single.name, 'Urgent');
      expect(all.single.color, '#FF0000');
    });

    test('fails validation without touching the repository', () async {
      final result = await CreateTagUseCase(repo)('   ');

      expect(result.isErr, isTrue);
      expect((await repo.getAll()).valueOrNull, isEmpty);
    });
  });
}
