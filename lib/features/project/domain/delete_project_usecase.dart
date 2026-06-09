import '../../../core/contracts/i_project_repository.dart';
import '../../../core/enums/enums.dart';
import '../../../core/utils/result.dart';

/// Deletes a project, either removing its tasks or moving them to the inbox.
final class DeleteProjectUseCase {
  const DeleteProjectUseCase(this._projects);

  final IProjectRepository _projects;

  Future<Result<void>> call(String id, {required ProjectDeleteMode mode}) {
    return _projects.delete(id, mode: mode);
  }
}
