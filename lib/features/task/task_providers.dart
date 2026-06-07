import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../notification/reminder_scheduler_provider.dart';
import 'domain/complete_task_usecase.dart';
import 'domain/create_task_usecase.dart';
import 'domain/delete_task_usecase.dart';
import 'domain/recurrence_engine.dart';
import 'domain/reorder_tasks_usecase.dart';
import 'domain/toggle_subtask_usecase.dart';
import 'domain/uncomplete_task_usecase.dart';
import 'domain/update_task_usecase.dart';

/// Singleton recurrence engine (pure, no IO).
final recurrenceEngineProvider = Provider<RecurrenceEngine>(
  (ref) => const RecurrenceEngine(),
);

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>(
  (ref) => CreateTaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>(
  (ref) => UpdateTaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>(
  (ref) => CompleteTaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
    ref.watch(recurrenceEngineProvider),
  ),
);

final uncompleteTaskUseCaseProvider = Provider<UncompleteTaskUseCase>(
  (ref) => UncompleteTaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final toggleSubtaskUseCaseProvider = Provider<ToggleSubtaskUseCase>(
  (ref) => ToggleSubtaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(completeTaskUseCaseProvider),
  ),
);

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>(
  (ref) => DeleteTaskUseCase(
    ref.watch(taskRepositoryProvider),
    ref.watch(reminderSchedulerProvider),
  ),
);

final reorderTasksUseCaseProvider = Provider<ReorderTasksUseCase>(
  (ref) => ReorderTasksUseCase(ref.watch(taskRepositoryProvider)),
);
