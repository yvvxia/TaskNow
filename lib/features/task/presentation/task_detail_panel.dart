import 'package:flutter/material.dart';

import 'task_detail_body.dart';

/// Desktop right-panel that shows the detail of the selected task. When no
/// task is selected it shows a placeholder.
class TaskDetailPanel extends StatelessWidget {
  const TaskDetailPanel({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context) {
    if (taskId == null) {
      return const Center(child: Text('Select a task'));
    }
    return TaskDetailBody(taskId: taskId!);
  }
}
