// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active bar-color strategy. Defaults to [BarColorMode.priority]; a future
/// settings field can drive this without touching consumers.

@ProviderFor(barColorMode)
final barColorModeProvider = BarColorModeProvider._();

/// Active bar-color strategy. Defaults to [BarColorMode.priority]; a future
/// settings field can drive this without touching consumers.

final class BarColorModeProvider
    extends $FunctionalProvider<BarColorMode, BarColorMode, BarColorMode>
    with $Provider<BarColorMode> {
  /// Active bar-color strategy. Defaults to [BarColorMode.priority]; a future
  /// settings field can drive this without touching consumers.
  BarColorModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barColorModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barColorModeHash();

  @$internal
  @override
  $ProviderElement<BarColorMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BarColorMode create(Ref ref) {
    return barColorMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarColorMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarColorMode>(value),
    );
  }
}

String _$barColorModeHash() => r'41ae508da1ae79c12513bb1fdff5c868323796a3';

/// Streams the laid-out task bars for the current visible range. Watches the
/// calendar window and re-queries via [TaskQuery.rangeOverlap] so only tasks
/// intersecting the window are loaded.

@ProviderFor(visibleBars)
final visibleBarsProvider = VisibleBarsProvider._();

/// Streams the laid-out task bars for the current visible range. Watches the
/// calendar window and re-queries via [TaskQuery.rangeOverlap] so only tasks
/// intersecting the window are loaded.

final class VisibleBarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskBar>>,
          List<TaskBar>,
          Stream<List<TaskBar>>
        >
    with $FutureModifier<List<TaskBar>>, $StreamProvider<List<TaskBar>> {
  /// Streams the laid-out task bars for the current visible range. Watches the
  /// calendar window and re-queries via [TaskQuery.rangeOverlap] so only tasks
  /// intersecting the window are loaded.
  VisibleBarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleBarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleBarsHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskBar>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskBar>> create(Ref ref) {
    return visibleBars(ref);
  }
}

String _$visibleBarsHash() => r'488649384bd8557eb0199f16ad58150986e5bd97';
