import '../../../core/enums/enums.dart';

/// User-selected reminder template before trigger-time calculation.
class ReminderTemplate {
  const ReminderTemplate({required this.type, this.offsetMin});

  final ReminderType type;
  final int? offsetMin;

  @override
  bool operator ==(Object other) =>
      other is ReminderTemplate &&
      other.type == type &&
      other.offsetMin == offsetMin;

  @override
  int get hashCode => Object.hash(type, offsetMin);
}
