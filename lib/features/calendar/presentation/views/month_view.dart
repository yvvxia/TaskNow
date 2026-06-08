import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';

/// Month grid view. Each day cell shows up to a height-dependent number of
/// short task bars; remaining tasks collapse into a "+k more" affordance
/// (design §4).
class MonthView extends ConsumerWidget {
  const MonthView({super.key, required this.onSelect});

  final ValueChanged<String?> onSelect;

  static const double _dayLabelHeight = 18;
  static const double _chipHeight = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider);

    final month = DateTime(view.anchor.year, view.anchor.month);
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final gridStart = DateTime(
      firstOfMonth.year,
      firstOfMonth.month,
      firstOfMonth.day - (firstOfMonth.weekday - DateTime.monday),
    );
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lastOfMonth = DateTime(month.year, month.month, daysInMonth);
    final totalDays = lastOfMonth.difference(gridStart).inDays + 1;
    final weeks = (totalDays / 7).ceil();
    final cellCount = weeks * 7;

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WeekdayHeader(localeName: AppLocalizations.of(context)?.localeName),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                ),
                itemCount: cellCount,
                itemBuilder: (context, index) {
                  final day = DateTime(
                    gridStart.year,
                    gridStart.month,
                    gridStart.day + index,
                  );
                  final inMonth = day.month == month.month;
                  final dayBars =
                      bars.where((b) => _overlapsDay(b, day)).toList();
                  return _DayCell(
                    day: day,
                    inMonth: inMonth,
                    bars: dayBars,
                    onSelect: onSelect,
                  );
                },
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({this.localeName});

  final String? localeName;

  @override
  Widget build(BuildContext context) {
    final monday = DateTime.utc(2026, 1, 5);
    final fmt = DateFormat.E(localeName);
    final labels = [
      for (var i = 0; i < 7; i++) fmt.format(monday.add(Duration(days: i))),
    ];
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.bars,
    required this.onSelect,
  });

  final DateTime day;
  final bool inMonth;
  final List<TaskBar> bars;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
        color: inMonth ? null : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available =
              constraints.maxHeight - MonthView._dayLabelHeight;
          final capacity = (available / MonthView._chipHeight).floor();
          final fits = capacity.clamp(0, bars.length);
          // Reserve a row for "+k more" when not everything fits.
          final showMore = bars.length > fits;
          final shown = showMore ? (fits - 1).clamp(0, bars.length) : fits;
          final hidden = bars.length - shown;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MonthView._dayLabelHeight,
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight:
                            inMonth ? FontWeight.bold : FontWeight.normal,
                        color: inMonth ? null : scheme.onSurfaceVariant,
                      ),
                ),
              ),
              for (final bar in bars.take(shown))
                _MiniBar(bar: bar, onTap: () => onSelect(bar.task.id)),
              if (showMore && hidden > 0)
                Text(
                  AppLocalizations.of(context)?.calendarMoreTasks(hidden) ??
                      '+$hidden more',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.bar, required this.onTap});

  final TaskBar bar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('month-bar-${bar.task.id}'),
        height: MonthView._chipHeight - 3,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bar.isOverdue ? bar.color.withValues(alpha: 0.55) : bar.color,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          bar.task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 9),
        ),
      ),
    );
  }
}

/// Formats the month label, e.g. "June 2026". Exposed for the header.
String monthLabel(DateTime anchor, [String? localeName]) =>
    DateFormat.yMMMM(localeName).format(anchor);
