import '../errors/app_exception.dart';

/// Unified return type used by the data and domain layers so that callers
/// receive either a value [Ok] or a domain [AppException] [Err] instead of a
/// thrown exception. See `design/00-architecture-overview.md` §7.
sealed class Result<T> {
  const Result();

  /// Whether this result represents success.
  bool get isOk => this is Ok<T>;

  /// Whether this result represents failure.
  bool get isErr => this is Err<T>;

  /// The success value, or `null` when this is an [Err].
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  /// The failure, or `null` when this is an [Ok].
  AppException? get errorOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final error) => error,
      };

  /// Collapses both branches into a single value of type [R].
  R fold<R>(
    R Function(T value) onOk,
    R Function(AppException error) onErr,
  ) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final error) => onErr(error),
      };
}

/// Successful [Result] carrying a [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Failed [Result] carrying an [AppException] [error].
final class Err<T> extends Result<T> {
  const Err(this.error);

  final AppException error;
}
