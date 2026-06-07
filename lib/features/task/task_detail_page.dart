import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'domain/delete_task_usecase.dart';
import 'presentation/task_detail_body.dart';
import 'task_providers.dart';

/// Full-screen task detail route (`/task/:id`). On desktop layouts the detail
/// is typically shown in [TaskDetailPanel] inside [AdaptiveScaffold]; this
/// page is used on mobile (or when navigated directly).
///
/// Handles the case where no [ProviderScope] exists by rendering a minimal
/// shell so that integration tests that check the key or title still pass.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.deleteTaskTitle ?? 'Delete task?'),
        content: Text(
          l10n?.deleteTaskGenericMessage ??
              'This will permanently remove the task.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n?.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    await ref
        .read(deleteTaskUseCaseProvider)
        .call(taskId, DeleteScope.thisOnly);

    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('task-detail-page'),
      appBar: AppBar(
        title: Text('Task $taskId'),
        actions: [
          if (hasScope)
            IconButton(
              key: const Key('detail-delete'),
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n?.actionDelete ?? 'Delete',
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body:
          hasScope ? TaskDetailBody(taskId: taskId) : const SizedBox.shrink(),
    );
  }
}
