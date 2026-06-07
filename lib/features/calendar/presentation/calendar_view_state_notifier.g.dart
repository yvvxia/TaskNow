// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_view_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the shared calendar window: view type, anchor date, derived visible
/// range, and the currently selected task. Switching the view preserves the
/// [CalendarViewState.anchor] so the time window stays consistent (design §7).

@ProviderFor(CalendarViewStateNotifier)
final calendarViewStateProvider = CalendarViewStateNotifierProvider._();

/// Owns the shared calendar window: view type, anchor date, derived visible
/// range, and the currently selected task. Switching the view preserves the
/// [CalendarViewState.anchor] so the time window stays consistent (design §7).
final class CalendarViewStateNotifierProvider
    extends $NotifierProvider<CalendarViewStateNotifier, CalendarViewState> {
  /// Owns the shared calendar window: view type, anchor date, derived visible
  /// range, and the currently selected task. Switching the view preserves the
  /// [CalendarViewState.anchor] so the time window stays consistent (design §7).
  CalendarViewStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarViewStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarViewStateNotifierHash();

  @$internal
  @override
  CalendarViewStateNotifier create() => CalendarViewStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarViewState>(value),
    );
  }
}

String _$calendarViewStateNotifierHash() =>
    r'f5559177466b51f35298942060d03e8a8fcbb386';

/// Owns the shared calendar window: view type, anchor date, derived visible
/// range, and the currently selected task. Switching the view preserves the
/// [CalendarViewState.anchor] so the time window stays consistent (design §7).

abstract class _$CalendarViewStateNotifier
    extends $Notifier<CalendarViewState> {
  CalendarViewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarViewState, CalendarViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarViewState, CalendarViewState>,
              CalendarViewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
