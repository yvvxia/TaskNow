import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/recurrence_rule.dart';
import '../../../l10n/app_localizations.dart';

/// Widget for picking recurrence settings (frequency, interval, weekdays,
/// end date). Calls [onChanged] whenever the rule changes; passes [null] to
/// clear the rule.
class RecurrencePicker extends StatefulWidget {
  const RecurrencePicker({super.key, this.value, required this.onChanged});

  final RecurrenceRule? value;
  final ValueChanged<RecurrenceRule?> onChanged;

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceFrequency _frequency;
  late int _interval;
  late List<int> _byWeekday;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _frequency = widget.value?.frequency ?? RecurrenceFrequency.daily;
    _interval = widget.value?.interval ?? 1;
    _byWeekday = List<int>.from(widget.value?.byWeekday ?? []);
    _endDate = widget.value?.endDate;
  }

  void _emit() {
    widget.onChanged(
      RecurrenceRule(
        id: widget.value?.id ?? 'draft',
        frequency: _frequency,
        interval: _interval,
        byWeekday: _frequency == RecurrenceFrequency.weekly ? _byWeekday : [],
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = l10n?.localeName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frequency
        Row(
          children: [
            Text('${l10n?.recurrenceRepeats ?? 'Repeats'}:'),
            const SizedBox(width: 12),
            DropdownButton<RecurrenceFrequency>(
              value: _frequency,
              items: RecurrenceFrequency.values
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(_freqLabel(f, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _frequency = v);
                _emit();
              },
            ),
          ],
        ),

        // Interval
        Row(
          children: [
            Text('${l10n?.recurrenceEvery ?? 'Every'}:'),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: '$_interval',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(isDense: true),
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed > 0) {
                    _interval = parsed;
                    _emit();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(_unitLabel(_frequency, l10n)),
          ],
        ),

        // Weekday multi-select (weekly only)
        if (_frequency == RecurrenceFrequency.weekly)
          Wrap(
            spacing: 4,
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                FilterChip(
                  label: Text(_weekdayLabel(weekday, localeName)),
                  selected: _byWeekday.contains(weekday),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _byWeekday.add(weekday);
                        _byWeekday.sort();
                      } else {
                        _byWeekday.remove(weekday);
                      }
                    });
                    _emit();
                  },
                ),
            ],
          ),

        // End date
        Row(
          children: [
            Text('${l10n?.recurrenceEnds ?? 'Ends'}:'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _endDate = picked);
                  _emit();
                }
              },
              child: Text(
                _endDate == null
                    ? (l10n?.recurrenceNever ?? 'Never')
                    : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
            if (_endDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  setState(() => _endDate = null);
                  _emit();
                },
              ),
          ],
        ),
      ],
    );
  }

  static String _freqLabel(RecurrenceFrequency f, AppLocalizations? l10n) {
    switch (f) {
      case RecurrenceFrequency.daily:
        return l10n?.recurrenceDaily ?? 'Daily';
      case RecurrenceFrequency.weekly:
        return l10n?.recurrenceWeekly ?? 'Weekly';
      case RecurrenceFrequency.monthly:
        return l10n?.recurrenceMonthly ?? 'Monthly';
      case RecurrenceFrequency.custom:
        return l10n?.recurrenceCustom ?? 'Custom';
    }
  }

  static String _unitLabel(RecurrenceFrequency f, AppLocalizations? l10n) {
    switch (f) {
      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.custom:
        return l10n?.recurrenceUnitDays ?? 'day(s)';
      case RecurrenceFrequency.weekly:
        return l10n?.recurrenceUnitWeeks ?? 'week(s)';
      case RecurrenceFrequency.monthly:
        return l10n?.recurrenceUnitMonths ?? 'month(s)';
    }
  }

  /// Localized short weekday name for an ISO weekday (1 = Mon … 7 = Sun).
  /// 2024-01-01 was a Monday, so January [isoWeekday] falls on that weekday.
  static String _weekdayLabel(int isoWeekday, String? localeName) {
    return DateFormat.E(localeName).format(DateTime(2024, 1, isoWeekday));
  }
}
