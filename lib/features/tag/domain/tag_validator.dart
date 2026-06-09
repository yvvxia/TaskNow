import '../../../core/errors/app_exception.dart';
import '../../../core/utils/result.dart';

/// Domain-layer validator for tag input. Returns [Ok] when valid or
/// [Err(ValidationException)] on the first failure.
final class TagValidator {
  const TagValidator();

  Result<void> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Err(
        ValidationException(
          code: 'emptyTagName',
          messageKey: 'error.emptyTagName',
        ),
      );
    }
    return const Ok(null);
  }
}
