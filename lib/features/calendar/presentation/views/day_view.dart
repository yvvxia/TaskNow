import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/task_bar.dart';
import '../calendar_providers.dart';
import '../calendar_view_state_notifier.dart';

/// Day view: a 24-hour vertical axis. Tasks are projected onto the day by the
/// time-of-day of their start/due; spans are clipped to the day. Tasks pinned
/// to midnight render in the top "all-day" band.
class DayView extends ConsumerWidget {
  const DayView({super.key, required this.onSelect});

  final ValueChanged<String?> onSelect;

  static const double hourHeight = 48;
  static const double gutter = 56;
  static const double allDayHeight = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewStateProvider);
    final barsAsync = ref.watch(visibleBarsProvider);
    final day = DateTime(view.anchor.year, view.anchor.month, view.anchor.day);
    final nextDay = day.add(const Duration(days: 1));

    return barsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)?.calendarLoadError(e.toString()) ??
              'Error: $e',
        ),
      ),
      data: (bars) {
        final dayBars = bars
            .where((b) =>
                b.barStart.isBefore(nextDay) && !b.barEnd.isBefore(day))
            .toList();
        final allDay = dayBars.where((b) => _isAllDay(b, day)).toList();
        final timed = dayBars.where((b) => !_isAllDay(b, day)).toList();
        final scheme = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allDay.isNotEmpty)
              SizedBox(
                height: allDayHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  children: [
                    for (final b in allDay)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _Chip(bar: b, onTap: () => onSelect(b.task.id)),
                      ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 24 * hourHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HourGridPainter(
                            hourHeight: hourHeight,
                            gutter: gutter,
                            lineColor: scheme.outlineVariant,
                            labelStyle: Theme.of(context).textTheme.labelSmall ??
                                const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      for (final b in timed) _timedBlock(context, b, day),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isAllDay(TaskBar bar, DateTime day) {
    final s = bar.barStart;
    final startsBeforeDay = s.isBefore(day);
    final atMidnight = s.hour == 0 && s.minute == 0;
    return startsBeforeDay || atMidnight;
  }

  Widget _timedBlock(BuildContext context, TaskBar bar, DateTime day) {
    final startMin = bar.barStart.isBefore(day)
        ? 0
        : bar.barStart.hour * 60 + bar.barStart.minute;
    final endMin = bar.barEnd.hour * 60 + bar.barEnd.minute;
    final top = startMin / 60 * hourHeight;
    final height = ((endMin - startMin) / 60 * hourHeight).clamp(24.0, 24 * hourHeight);

    return Positioned(
      left: gutter + 4,
      right: 8,
      top: top,
      height: height,
      child: GestureDetector(
        onTap: () => onSelect(bar.task.id),
        child: Container(
          key: Key('day-block-${bar.task.id}'),
          decoration: BoxDecoration(
            color: bar.color,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.topLeft,
          child: Text(
            bar.task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.bar, required this.onTap});

  final TaskBar bar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('day-allday-${bar.task.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bar.color,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          bar.task.title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _HourGridPainter extends CustomPainter {
  _HourGridPainter({
    required this.hourHeight,
    required this.gutter,
    required this.lineColor,
    required this.labelStyle,
  });

  final double hourHeight;
  final double gutter;
  final Color lineColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var h = 0; h < 24; h++) {
      final y = h * hourHeight;
      canvas.drawLine(Offset(gutter, y), Offset(size.width, y), line);
      final tp = TextPainter(
        text: TextSpan(
          text: '${h.toString().padLeft(2, '0')}:00',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(8, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _HourGridPainter oldDelegate) =>
      oldDelegate.hourHeight != hourHeight ||
      oldDelegate.lineColor != lineColor;
}
