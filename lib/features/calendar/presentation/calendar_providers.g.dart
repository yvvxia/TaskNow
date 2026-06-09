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

String _$barColorModeHash() => r'aab10b6b0d273fd4be790440de26b3ab6a981882';

/// Map of project id → stored color string, used to color the global calendar
/// by project.

@ProviderFor(projectColors)
final projectColorsProvider = ProjectColorsProvider._();

/// Map of project id → stored color string, used to color the global calendar
/// by project.

final class ProjectColorsProvider
    extends
        $FunctionalProvider<
          Map<String, String?>,
          Map<String, String?>,
          Map<String, String?>
        >
    with $Provider<Map<String, String?>> {
  /// Map of project id → stored color string, used to color the global calendar
  /// by project.
  ProjectColorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectColorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectColorsHash();

  @$internal
  @override
  $ProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String?> create(Ref ref) {
    return projectColors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String?>>(value),
    );
  }
}

String _$projectColorsHash() => r'4e11a83199ba0eadcbad96ac8d370ed0716080a7';

/// Streams the laid-out task bars for the current visible range, optionally
/// scoped to a single [projectId] (null = all projects / global calendar).
///
/// When scoped to a project, bars are colored by priority; on the global
/// calendar they are colored by project hue with priority saturation.

@ProviderFor(visibleBars)
final visibleBarsProvider = VisibleBarsFamily._();

/// Streams the laid-out task bars for the current visible range, optionally
/// scoped to a single [projectId] (null = all projects / global calendar).
///
/// When scoped to a project, bars are colored by priority; on the global
/// calendar they are colored by project hue with priority saturation.

final class VisibleBarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskBar>>,
          List<TaskBar>,
          Stream<List<TaskBar>>
        >
    with $FutureModifier<List<TaskBar>>, $StreamProvider<List<TaskBar>> {
  /// Streams the laid-out task bars for the current visible range, optionally
  /// scoped to a single [projectId] (null = all projects / global calendar).
  ///
  /// When scoped to a project, bars are colored by priority; on the global
  /// calendar they are colored by project hue with priority saturation.
  VisibleBarsProvider._({
    required VisibleBarsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'visibleBarsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visibleBarsHash();

  @override
  String toString() {
    return r'visibleBarsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskBar>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskBar>> create(Ref ref) {
    final argument = this.argument as String?;
    return visibleBars(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VisibleBarsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visibleBarsHash() => r'0df2d0caecfd9d4962c7a7d89dc4b541c97bf12b';

/// Streams the laid-out task bars for the current visible range, optionally
/// scoped to a single [projectId] (null = all projects / global calendar).
///
/// When scoped to a project, bars are colored by priority; on the global
/// calendar they are colored by project hue with priority saturation.

final class VisibleBarsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskBar>>, String?> {
  VisibleBarsFamily._()
    : super(
        retry: null,
        name: r'visibleBarsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams the laid-out task bars for the current visible range, optionally
  /// scoped to a single [projectId] (null = all projects / global calendar).
  ///
  /// When scoped to a project, bars are colored by priority; on the global
  /// calendar they are colored by project hue with priority saturation.

  VisibleBarsProvider call(String? projectId) =>
      VisibleBarsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'visibleBarsProvider';
}

/// Streams one-task-per-row Gantt bars for the current visible range,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time.

@ProviderFor(ganttBars)
final ganttBarsProvider = GanttBarsFamily._();

/// Streams one-task-per-row Gantt bars for the current visible range,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time.

final class GanttBarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskBar>>,
          List<TaskBar>,
          Stream<List<TaskBar>>
        >
    with $FutureModifier<List<TaskBar>>, $StreamProvider<List<TaskBar>> {
  /// Streams one-task-per-row Gantt bars for the current visible range,
  /// optionally scoped to a single [projectId]. Rows are ordered by manual
  /// [Task.ganttOrder] then creation time.
  GanttBarsProvider._({
    required GanttBarsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'ganttBarsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ganttBarsHash();

  @override
  String toString() {
    return r'ganttBarsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskBar>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskBar>> create(Ref ref) {
    final argument = this.argument as String?;
    return ganttBars(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GanttBarsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ganttBarsHash() => r'164ec06d4cb786c3110b44562ae8c18abea800db';

/// Streams one-task-per-row Gantt bars for the current visible range,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time.

final class GanttBarsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskBar>>, String?> {
  GanttBarsFamily._()
    : super(
        retry: null,
        name: r'ganttBarsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams one-task-per-row Gantt bars for the current visible range,
  /// optionally scoped to a single [projectId]. Rows are ordered by manual
  /// [Task.ganttOrder] then creation time.

  GanttBarsProvider call(String? projectId) =>
      GanttBarsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'ganttBarsProvider';
}

/// Use case that persists Gantt-row reordering.

@ProviderFor(reorderGanttUseCase)
final reorderGanttUseCaseProvider = ReorderGanttUseCaseProvider._();

/// Use case that persists Gantt-row reordering.

final class ReorderGanttUseCaseProvider
    extends
        $FunctionalProvider<
          ReorderGanttUseCase,
          ReorderGanttUseCase,
          ReorderGanttUseCase
        >
    with $Provider<ReorderGanttUseCase> {
  /// Use case that persists Gantt-row reordering.
  ReorderGanttUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reorderGanttUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reorderGanttUseCaseHash();

  @$internal
  @override
  $ProviderElement<ReorderGanttUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReorderGanttUseCase create(Ref ref) {
    return reorderGanttUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReorderGanttUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReorderGanttUseCase>(value),
    );
  }
}

String _$reorderGanttUseCaseHash() =>
    r'd3db9f4ee1692e9468ce6650bf7ba1ee9a98af79';
