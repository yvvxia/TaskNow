import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_view_state_notifier.dart';
import 'layout_breakpoints.dart';
import 'shell_providers.dart';

/// Opens task detail in the right panel on expanded desktop, or navigates
/// full-screen on compact/medium layouts.
void openTaskDetail(BuildContext context, WidgetRef ref, String taskId) {
  final wide = MediaQuery.of(context).size.width >= kExpandedBreakpoint;
  ref.read(calendarViewStateProvider.notifier).selectTask(taskId);
  if (wide) {
    ref.read(selectedTaskIdProvider.notifier).state = taskId;
  } else {
    context.go('/task/$taskId');
  }
}

/// Clears the desktop detail panel selection.
void clearTaskDetailSelection(WidgetRef ref) {
  ref.read(selectedTaskIdProvider.notifier).state = null;
  ref.read(calendarViewStateProvider.notifier).selectTask(null);
}
