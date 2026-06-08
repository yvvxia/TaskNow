import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/enums/enums.dart';
import '../../core/widgets/adaptive_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../task/presentation/task_detail_body.dart';
import 'presentation/calendar_view_state_notifier.dart';
import 'presentation/views/day_view.dart';
import 'presentation/views/gantt_view.dart';
import 'presentation/views/month_view.dart';
import 'presentation/views/week_view.dart';

/// Calendar & Gantt screen. Hosts the shared window navigation (view tabs,
/// prev/next, today) and swaps between the day/week/month/Gantt renderers.
///
/// Guards against a missing [ProviderScope] (legacy router tests) by rendering
/// a minimal shell that still carries the `calendar-page` key.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    return Scaffold(
      key: const Key('calendar-page'),
      body: hasScope ? const _CalendarBody() : const SizedBox.shrink(),
    );
  }
}

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody();

  void _onSelect(BuildContext context, WidgetRef ref, String? id) {
    ref.read(calendarViewStateProvider.notifier).selectTask(id);
    if (id == null) return;

    final wide = MediaQuery.of(context).size.width >= kExpandedBreakpoint;
    if (wide) {
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
            child: TaskDetailBody(taskId: id),
          ),
        ),
      );
    } else {
      final router = GoRouter.maybeOf(context);
      if (router != null) context.go('/task/$id');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    void onSelect(String? id) => _onSelect(context, ref, id);

    final Widget body = switch (view.type) {
      CalendarViewType.day => DayView(onSelect: onSelect),
      CalendarViewType.week => WeekView(onSelect: onSelect),
      CalendarViewType.month => MonthView(onSelect: onSelect),
      CalendarViewType.gantt => GanttView(onSelect: onSelect),
    };

    return SafeArea(
      child: Column(
        children: [
          const _CalendarHeader(),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _CalendarHeader extends ConsumerWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final notifier = ref.read(calendarViewStateProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                key: const Key('calendar-prev'),
                icon: const Icon(Icons.chevron_left),
                tooltip: l10n?.calendarPrevious ?? 'Previous',
                onPressed: notifier.prev,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _label(
                      view.type,
                      view.anchor,
                      view.visibleRange,
                      l10n?.localeName,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              TextButton(
                key: const Key('calendar-today'),
                onPressed: notifier.goToToday,
                child: Text(l10n?.calendarToday ?? 'Today'),
              ),
              IconButton(
                key: const Key('calendar-next'),
                icon: const Icon(Icons.chevron_right),
                tooltip: l10n?.calendarNext ?? 'Next',
                onPressed: notifier.next,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<CalendarViewType>(
                segments: [
                  ButtonSegment(
                    value: CalendarViewType.day,
                    label: Text(l10n?.calendarDay ?? 'Day'),
                    icon: const Icon(Icons.calendar_view_day),
                  ),
                  ButtonSegment(
                    value: CalendarViewType.week,
                    label: Text(l10n?.calendarWeek ?? 'Week'),
                    icon: const Icon(Icons.calendar_view_week),
                  ),
                  ButtonSegment(
                    value: CalendarViewType.month,
                    label: Text(l10n?.calendarMonth ?? 'Month'),
                    icon: const Icon(Icons.calendar_view_month),
                  ),
                  ButtonSegment(
                    value: CalendarViewType.gantt,
                    label: Text(l10n?.calendarGantt ?? 'Gantt'),
                    icon: const Icon(Icons.view_timeline),
                  ),
                ],
                selected: {view.type},
                onSelectionChanged: (selection) =>
                    notifier.switchView(selection.first),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(
    CalendarViewType type,
    DateTime anchor,
    DateTimeRange range,
    String? localeName,
  ) {
    switch (type) {
      case CalendarViewType.day:
        return DateFormat.yMMMEd(localeName).format(anchor);
      case CalendarViewType.month:
        return DateFormat.yMMMM(localeName).format(anchor);
      case CalendarViewType.week:
      case CalendarViewType.gantt:
        final fmt = DateFormat.MMMd(localeName);
        return '${fmt.format(range.start)} – ${fmt.format(range.end)}';
    }
  }
}
