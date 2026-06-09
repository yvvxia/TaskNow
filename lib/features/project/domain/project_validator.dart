import '../../../core/errors/app_exception.dart';
import '../../../core/utils/result.dart';

/// Domain-layer validator for project input. Returns [Ok] when valid or
/// [Err(ValidationException)] on the first failure.
final class ProjectValidator {
  const ProjectValidator();

  Result<void> validateName(String name) {
    if (name.trim().isEmpty) {
      return const Err(
        ValidationException(
          code: 'emptyProjectName',
          messageKey: 'error.emptyProjectName',
        ),
      );
    }
    return const Ok(null);
  }
}
