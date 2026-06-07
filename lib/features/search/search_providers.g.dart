// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams search results for the current [SearchController] query.

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

/// Streams search results for the current [SearchController] query.

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskView>>,
          List<TaskView>,
          Stream<List<TaskView>>
        >
    with $FutureModifier<List<TaskView>>, $StreamProvider<List<TaskView>> {
  /// Streams search results for the current [SearchController] query.
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskView>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskView>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'c55bbb48977b54b2d517db4d9ad44f31faade789';
