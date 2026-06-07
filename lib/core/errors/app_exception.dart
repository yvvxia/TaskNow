/// Root of the domain exception hierarchy. Data and domain layers wrap failures
/// as [AppException]s inside a [Result] rather than throwing raw exceptions.
/// Each exception carries a stable [code] and an i18n [messageKey] that the
/// presentation layer maps to a localized message.
/// See `design/00-architecture-overview.md` §7.
sealed class AppException implements Exception {
  const AppException(this.code, this.messageKey);

  /// Stable, machine-readable error code.
  final String code;

  /// i18n key resolved to a localized, user-facing message.
  final String messageKey;

  @override
  String toString() => '$runtimeType(code: $code, messageKey: $messageKey)';
}

/// Raised when user input or a domain invariant fails validation
/// (e.g. due date before start date).
final class ValidationException extends AppException {
  const ValidationException({
    String code = 'validation',
    String messageKey = 'error.validation',
  }) : super(code, messageKey);
}

/// Raised when a requested entity cannot be found.
final class NotFoundException extends AppException {
  const NotFoundException({
    String code = 'not_found',
    String messageKey = 'error.notFound',
  }) : super(code, messageKey);
}

/// Raised when a persistence (database/storage) operation fails.
final class PersistenceException extends AppException {
  const PersistenceException({
    String code = 'persistence',
    String messageKey = 'error.persistence',
  }) : super(code, messageKey);
}

/// Raised when a required platform permission is denied
/// (e.g. exact alarm permission on Android 12+).
final class PermissionException extends AppException {
  const PermissionException({
    String code = 'permission',
    String messageKey = 'error.permission',
  }) : super(code, messageKey);
}
