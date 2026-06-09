import 'package:flutter/material.dart';

import '../../../core/enums/enums.dart';
import '../../../core/models/recurrence_rule.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frequency
        Row(
          children: [
            const Text('Repeats:'),
            const SizedBox(width: 12),
            DropdownButton<RecurrenceFrequency>(
              value: _frequency,
              items: RecurrenceFrequency.values
                  .map(
                    (f) =>
                        DropdownMenuItem(value: f, child: Text(_freqLabel(f))),
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
            const Text('Every:'),
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
            Text(_unitLabel(_frequency)),
          ],
        ),

        // Weekday multi-select (weekly only)
        if (_frequency == RecurrenceFrequency.weekly)
          Wrap(
            spacing: 4,
            children: [
              for (final entry in _weekdays.entries)
                FilterChip(
                  label: Text(entry.value),
                  selected: _byWeekday.contains(entry.key),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _byWeekday.add(entry.key);
                        _byWeekday.sort();
                      } else {
                        _byWeekday.remove(entry.key);
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
            const Text('Ends:'),
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
                    ? 'Never'
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

  static String _freqLabel(RecurrenceFrequency f) {
    switch (f) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.custom:
        return 'Custom';
    }
  }

  static String _unitLabel(RecurrenceFrequency f) {
    switch (f) {
      case RecurrenceFrequency.daily:
        return 'day(s)';
      case RecurrenceFrequency.weekly:
        return 'week(s)';
      case RecurrenceFrequency.monthly:
        return 'month(s)';
      case RecurrenceFrequency.custom:
        return 'day(s)';
    }
  }

  static const Map<int, String> _weekdays = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
}
