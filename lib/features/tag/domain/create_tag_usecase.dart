import '../../../core/contracts/i_tag_repository.dart';
import '../../../core/models/tag.dart';
import '../../../core/utils/result.dart';
import 'tag_validator.dart';

/// Creates a new tag after validating its name.
final class CreateTagUseCase {
  const CreateTagUseCase(this._tags);

  final ITagRepository _tags;

  Future<Result<Tag>> call(String name, {String? color}) async {
    final validation = const TagValidator().validateName(name);
    if (validation case Err(:final error)) return Err(error);
    return _tags.create(name.trim(), color: color);
  }
}
