import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/clock.dart';
import '../../data/data_providers.dart';
import '../../data/db/task_query_compiler.dart';
import '../../data/mappers/task_mapper.dart';
import '../../data/mappers/time_mapper.dart';
import '../task/presentation/task_view.dart';
import 'search_controller.dart';

part 'search_providers.g.dart';

/// Streams search results for the current [SearchController] query.
@riverpod
Stream<List<TaskView>> searchResults(Ref ref) async* {
  final query = ref.watch(searchControllerProvider);
  final db = ref.watch(appDatabaseProvider);
  final now = ref.watch(clockProvider)();
  final compiler = TaskQueryCompiler(db);
  final dao = db.taskDao;

  await for (final rows in compiler.watch(query, nowMs: now.msUtc)) {
    final views = <TaskView>[];
    for (final row in rows) {
      final tagIds = await dao.tagIdsFor(row.id);
      final task = TaskMapper.toEntity(row, tagIds: tagIds);
      views.add(TaskView.from(task, now));
    }
    yield views;
  }
}
