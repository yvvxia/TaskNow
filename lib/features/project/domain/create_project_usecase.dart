import '../../../core/contracts/i_project_repository.dart';
import '../../../core/models/project.dart';
import '../../../core/utils/result.dart';
import 'project_validator.dart';

/// Creates a new project after validating its name.
final class CreateProjectUseCase {
  const CreateProjectUseCase(this._projects);

  final IProjectRepository _projects;

  Future<Result<Project>> call(String name, {String? color}) async {
    final validation = const ProjectValidator().validateName(name);
    if (validation case Err(:final error)) return Err(error);
    return _projects.create(name.trim(), color: color);
  }
}
