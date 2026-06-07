/// UTC-millisecond <-> [DateTime] conversion helpers.
///
/// The database stores all timestamps as UTC epoch milliseconds (INTEGER) per
/// the global convention in `design/00-architecture-overview.md` §9. Entities
/// always expose UTC [DateTime]s.
library;

/// Converts a UTC-ms integer to a UTC [DateTime].
DateTime dateTimeFromUtcMs(int ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

/// Converts a nullable UTC-ms integer to a nullable UTC [DateTime].
DateTime? dateTimeFromUtcMsOrNull(int? ms) =>
    ms == null ? null : dateTimeFromUtcMs(ms);

extension DateTimeMsX on DateTime {
  /// This instant as UTC epoch milliseconds.
  int get msUtc => toUtc().millisecondsSinceEpoch;
}

extension NullableDateTimeMsX on DateTime? {
  /// This instant as UTC epoch milliseconds, or `null` when the receiver is
  /// `null`.
  int? get msUtcOrNull => this?.msUtc;
}
