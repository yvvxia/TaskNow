import '../enums/enums.dart';
import '../models/project.dart';
import '../utils/result.dart';

/// Project repository contract.
abstract interface class IProjectRepository {
  Future<Result<List<Project>>> getAll();

  Future<Result<Project>> create(String name, {String? color});

  Future<Result<Project>> update(Project project);

  Future<Result<void>> delete(String id, {required ProjectDeleteMode mode});

  Stream<List<Project>> watchAll();
}
