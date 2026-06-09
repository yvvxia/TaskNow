import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../task/presentation/add_task_sheet.dart';
import '../../../task/task_providers.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';

/// Week view: 7 day columns, each a scrollable cell listing that day's tasks.
///
/// Tapping a column opens the day view for that day; right-clicking (or
/// long-pressing on touch) offers "Create task". Each column scrolls
/// independently so all tasks remain reachable when a day is busy.
class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.onSelect, this.projectId});

  final ValueChanged<String?> onSelect;
  final String? projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider(projectId));
    final origin = DateTime(
      view.visibleRange.start.year,
      view.visibleRange.start.month,
      view.visibleRange.start.day,
    );
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    void onCreateInDay(DateTime day) => showAddTaskSheet(
      context,
      onCreate: (draft) => ref.read(createTaskUseCaseProvider).call(draft),
      initialStart: day,
      initialDue: day,
      projectId: projectId,
    );
    void onOpenDay(DateTime day) =>
        ref.read(calendarViewStateProvider.notifier).openDay(day);

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _DayColumn(
                  day: origin.add(Duration(days: i)),
                  bars: bars
                      .where(
                        (b) => _overlapsDay(b, origin.add(Duration(days: i))),
                      )
                      .toList(),
                  isDesktop: isDesktop,
                  isLast: i == 6,
                  onSelect: onSelect,
                  onCreateInDay: onCreateInDay,
                  onOpenDay: onOpenDay,
                ),
              ),
          ],
        );
      },
    );
  }

  static bool _overlapsDay(TaskBar bar, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return bar.barStart.isBefore(dayEnd) && !bar.barEnd.isBefore(dayStart);
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.bars,
    required this.isDesktop,
    required this.isLast,
    required this.onSelect,
    required this.onCreateInDay,
    required this.onOpenDay,
  });

  final DateTime day;
  final List<TaskBar> bars;
  final bool isDesktop;
  final bool isLast;
  final ValueChanged<String?> onSelect;
  final ValueChanged<DateTime> onCreateInDay;
  final ValueChanged<DateTime> onOpenDay;

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final l10n = AppLocalizations.of(context);
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'create',
          child: Text(l10n?.calendarCreateTaskHere ?? 'Create task'),
        ),
        PopupMenuItem(
          value: 'open',
          child: Text(l10n?.calendarOpenDay ?? 'Open day'),
        ),
      ],
    );
    if (selected == 'create') {
      onCreateInDay(DateTime(day.year, day.month, day.day));
    } else if (selected == 'open') {
      onOpenDay(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final headerFmt = DateFormat('E\nd', l10n?.localeName);
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onOpenDay(day),
        onSecondaryTapDown: (d) => _showContextMenu(context, d.globalPosition),
        onLongPressStart: isDesktop
            ? null
            : (d) => _showContextMenu(context, d.globalPosition),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: isToday
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Text(
                headerFmt.format(day),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? scheme.primary : null,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: bars.isEmpty
                  ? const SizedBox.expand()
                  : ListView(
                      padding: const EdgeInsets.all(3),
                      children: [
                        for (final bar in bars)
                          _WeekChip(
                            bar: bar,
                            onTap: () => onSelect(bar.task.id),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({required this.bar, required this.onTap});

  final TaskBar bar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('week-bar-${bar.task.id}'),
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bar.isOverdue ? bar.color.withValues(alpha: 0.55) : bar.color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          bar.task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
