import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// Provides the current-time function. Defaults to [DateTime.now] but can be
/// overridden in tests to inject a fixed clock for deterministic time logic.
@riverpod
DateTime Function() clock(Ref ref) => DateTime.now;
