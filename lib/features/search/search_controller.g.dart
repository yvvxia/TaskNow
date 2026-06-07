// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the active [TaskQuery] for the search screen with debounced keyword
/// input.

@ProviderFor(SearchController)
final searchControllerProvider = SearchControllerProvider._();

/// Holds the active [TaskQuery] for the search screen with debounced keyword
/// input.
final class SearchControllerProvider
    extends $NotifierProvider<SearchController, TaskQuery> {
  /// Holds the active [TaskQuery] for the search screen with debounced keyword
  /// input.
  SearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchControllerHash();

  @$internal
  @override
  SearchController create() => SearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskQuery>(value),
    );
  }
}

String _$searchControllerHash() => r'066d232027d0bc79778bec630378673bbe87865b';

/// Holds the active [TaskQuery] for the search screen with debounced keyword
/// input.

abstract class _$SearchController extends $Notifier<TaskQuery> {
  TaskQuery build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskQuery, TaskQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskQuery, TaskQuery>,
              TaskQuery,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
