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
  const CalendarPage({
    super.key,
    this.projectId,
    this.embedded = false,
    this.showGanttSegment = true,
    this.forceGantt = false,
  });

  /// When non-null the calendar is scoped to a single project; otherwise it
  /// shows all projects (global calendar, colored by project).
  final String? projectId;

  /// When true the page is hosted inside another scaffold (e.g. a project
  /// detail tab), so it omits its own [Scaffold] chrome.
  final bool embedded;

  /// Whether the view switcher includes the Gantt segment.
  final bool showGanttSegment;

  /// When true the page renders only the Gantt view (no view switcher), used
  /// by a project's dedicated Gantt tab.
  final bool forceGantt;

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    final body = hasScope
        ? _CalendarBody(
            projectId: projectId,
            showGanttSegment: showGanttSegment,
            forceGantt: forceGantt,
          )
        : const SizedBox.shrink();
    if (embedded) return body;
    return Scaffold(key: const Key('calendar-page'), body: body);
  }
}

class _CalendarBody extends ConsumerWidget {
  const _CalendarBody({
    this.projectId,
    this.showGanttSegment = true,
    this.forceGantt = false,
  });

  final String? projectId;
  final bool showGanttSegment;
  final bool forceGantt;

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

    final Widget body = forceGantt
        ? GanttView(onSelect: onSelect, projectId: projectId)
        : switch (view.type) {
            CalendarViewType.day => DayView(
              onSelect: onSelect,
              projectId: projectId,
            ),
            CalendarViewType.week => WeekView(
              onSelect: onSelect,
              projectId: projectId,
            ),
            CalendarViewType.month => MonthView(
              onSelect: onSelect,
              projectId: projectId,
            ),
            CalendarViewType.gantt => GanttView(
              onSelect: onSelect,
              projectId: projectId,
            ),
          };

    return SafeArea(
      child: Column(
        children: [
          _CalendarHeader(
            showSwitcher: !forceGantt,
            showGanttSegment: showGanttSegment,
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _CalendarHeader extends ConsumerWidget {
  const _CalendarHeader({
    this.showSwitcher = true,
    this.showGanttSegment = true,
  });

  final bool showSwitcher;
  final bool showGanttSegment;

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
          if (showSwitcher) ...[
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
                    if (showGanttSegment)
                      ButtonSegment(
                        value: CalendarViewType.gantt,
                        label: Text(l10n?.calendarGantt ?? 'Gantt'),
                        icon: const Icon(Icons.view_timeline),
                      ),
                  ],
                  selected: {
                    if (!showGanttSegment &&
                        view.type == CalendarViewType.gantt)
                      CalendarViewType.month
                    else
                      view.type,
                  },
                  onSelectionChanged: (selection) =>
                      notifier.switchView(selection.first),
                ),
              ),
            ),
          ],
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
