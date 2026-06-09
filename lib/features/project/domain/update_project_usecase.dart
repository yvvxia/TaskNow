import '../../../core/contracts/i_project_repository.dart';
import '../../../core/models/project.dart';
import '../../../core/utils/result.dart';
import 'project_validator.dart';

/// Updates an existing project (rename / recolor) after validating its name.
final class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._projects);

  final IProjectRepository _projects;

  Future<Result<Project>> call(Project project) async {
    final validation = const ProjectValidator().validateName(project.name);
    if (validation case Err(:final error)) return Err(error);
    return _projects.update(project.copyWith(name: project.name.trim()));
  }
}
