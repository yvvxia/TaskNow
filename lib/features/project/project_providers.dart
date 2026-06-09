import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/project.dart';
import 'domain/create_project_usecase.dart';
import 'domain/delete_project_usecase.dart';
import 'domain/update_project_usecase.dart';

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>(
  (ref) => CreateProjectUseCase(ref.watch(projectRepositoryProvider)),
);

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>(
  (ref) => UpdateProjectUseCase(ref.watch(projectRepositoryProvider)),
);

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>(
  (ref) => DeleteProjectUseCase(ref.watch(projectRepositoryProvider)),
);

/// Live list of all (non-deleted) projects, ordered by sort order.
final projectListProvider = StreamProvider<List<Project>>(
  (ref) => ref.watch(projectRepositoryProvider).watchAll(),
);

/// A single project resolved by id from [projectListProvider]. Returns null
/// while the list is loading or when the id is unknown.
final projectByIdProvider = Provider.family<Project?, String>((ref, id) {
  final projects = ref.watch(projectListProvider).asData?.value ?? const [];
  for (final p in projects) {
    if (p.id == id) return p;
  }
  return null;
});
