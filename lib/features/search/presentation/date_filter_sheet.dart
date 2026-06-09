import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../../core/enums/status_filter.dart';
import '../../../core/models/date_filter.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet for picking a date filter preset or custom range.
class DateFilterSheet extends StatelessWidget {
  const DateFilterSheet({super.key, required this.now, this.onSelected});

  final DateTime now;
  final ValueChanged<DateFilter?>? onSelected;

  static Future<DateFilter?> show(
    BuildContext context, {
    required DateTime now,
  }) {
    return showModalBottomSheet<DateFilter?>(
      context: context,
      builder: (context) => DateFilterSheet(now: now),
    );
  }

  DateTime _startOfDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  DateTime _endOfDay(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, 23, 59, 59, 999);

  DateTimeRange _thisWeek() {
    final weekday = now.weekday;
    final start = _startOfDay(now.subtract(Duration(days: weekday - 1)));
    final end = _endOfDay(start.add(const Duration(days: 6)));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _thisMonth() {
    final start = DateTime.utc(now.year, now.month, 1);
    final end = DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59, 999);
    return DateTimeRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('date-filter-today'),
            leading: const Icon(Icons.today),
            title: Text(l10n?.searchDateToday ?? 'Today'),
            onTap: () => Navigator.pop(context, DateFilter.on(now)),
          ),
          ListTile(
            key: const Key('date-filter-week'),
            leading: const Icon(Icons.date_range),
            title: Text(l10n?.searchDateThisWeek ?? 'This week'),
            onTap: () => Navigator.pop(context, DateFilter.range(_thisWeek())),
          ),
          ListTile(
            key: const Key('date-filter-month'),
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n?.searchDateThisMonth ?? 'This month'),
            onTap: () => Navigator.pop(context, DateFilter.range(_thisMonth())),
          ),
          ListTile(
            key: const Key('date-filter-custom'),
            leading: const Icon(Icons.edit_calendar),
            title: Text(l10n?.searchDateCustomRange ?? 'Custom range'),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.utc(2020),
                lastDate: DateTime.utc(2035),
              );
              if (context.mounted && range != null) {
                Navigator.pop(
                  context,
                  DateFilter.range(
                    DateTimeRange(
                      start: _startOfDay(range.start),
                      end: _endOfDay(range.end),
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            key: const Key('date-filter-clear'),
            leading: const Icon(Icons.clear),
            title: Text(l10n?.searchDateClearFilter ?? 'Clear date filter'),
            onTap: () => Navigator.pop(context, null),
          ),
        ],
      ),
    );
  }
}

/// Label for the active [DateFilter] chip.
String dateFilterLabel(
  DateFilter? filter,
  DateTime now, [
  AppLocalizations? l10n,
]) {
  if (filter == null) return l10n?.searchDateFilter ?? 'Date';
  return switch (filter) {
    DateOn(:final day) when _sameDay(day, now) =>
      l10n?.searchDateToday ?? 'Today',
    DateOn(:final day) => '${day.month}/${day.day}',
    DateRange(:final range) =>
      '${range.start.month}/${range.start.day}'
          '–${range.end.month}/${range.end.day}',
    DateOverlap(:final range) =>
      l10n?.searchDateOverlap(
            '${range.start.month}/${range.start.day}'
            '–${range.end.month}/${range.end.day}',
          ) ??
          'Overlap '
              '${range.start.month}/${range.start.day}'
              '–${range.end.month}/${range.end.day}',
  };
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Label for a [StatusFilter] chip.
String statusFilterLabel(StatusFilter status, [AppLocalizations? l10n]) {
  return switch (status) {
    StatusFilter.all => l10n?.searchStatusAll ?? 'All',
    StatusFilter.incomplete => l10n?.searchStatusIncomplete ?? 'Incomplete',
    StatusFilter.complete => l10n?.searchStatusDone ?? 'Done',
    StatusFilter.overdue => l10n?.searchStatusOverdue ?? 'Overdue',
  };
}

/// Label for a [Priority] chip.
String priorityLabel(Priority priority, [AppLocalizations? l10n]) {
  return switch (priority) {
    Priority.high => l10n?.searchPriorityHigh ?? 'High',
    Priority.medium => l10n?.searchPriorityMedium ?? 'Medium',
    Priority.low => l10n?.searchPriorityLow ?? 'Low',
  };
}
