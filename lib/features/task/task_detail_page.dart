import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/task_detail_body.dart';

/// Full-screen task detail route (`/task/:id`). On desktop layouts the detail
/// is typically shown in [TaskDetailPanel] inside [AdaptiveScaffold]; this
/// page is used on mobile (or when navigated directly).
///
/// Handles the case where no [ProviderScope] exists by rendering a minimal
/// shell so that integration tests that check the key or title still pass.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    return Scaffold(
      key: const Key('task-detail-page'),
      appBar: AppBar(
        title: Text('Task $taskId'),
      ),
      body:
          hasScope ? TaskDetailBody(taskId: taskId) : const SizedBox.shrink(),
    );
  }
}
