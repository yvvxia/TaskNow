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

String _$visibleBarsHash() => r'1b526c20447163daffcb272f0a97f9f94fb1a6fd';

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

/// Streams one-task-per-row Gantt bars for all dated tasks in scope,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time. The horizontal axis is derived from
/// the task date span in [GanttView], not from [calendarViewStateProvider].

@ProviderFor(ganttBars)
final ganttBarsProvider = GanttBarsFamily._();

/// Streams one-task-per-row Gantt bars for all dated tasks in scope,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time. The horizontal axis is derived from
/// the task date span in [GanttView], not from [calendarViewStateProvider].

final class GanttBarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskBar>>,
          List<TaskBar>,
          Stream<List<TaskBar>>
        >
    with $FutureModifier<List<TaskBar>>, $StreamProvider<List<TaskBar>> {
  /// Streams one-task-per-row Gantt bars for all dated tasks in scope,
  /// optionally scoped to a single [projectId]. Rows are ordered by manual
  /// [Task.ganttOrder] then creation time. The horizontal axis is derived from
  /// the task date span in [GanttView], not from [calendarViewStateProvider].
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

String _$ganttBarsHash() => r'37f1e367e3f54fdab84b178c46a6e52228df550a';

/// Streams one-task-per-row Gantt bars for all dated tasks in scope,
/// optionally scoped to a single [projectId]. Rows are ordered by manual
/// [Task.ganttOrder] then creation time. The horizontal axis is derived from
/// the task date span in [GanttView], not from [calendarViewStateProvider].

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

  /// Streams one-task-per-row Gantt bars for all dated tasks in scope,
  /// optionally scoped to a single [projectId]. Rows are ordered by manual
  /// [Task.ganttOrder] then creation time. The horizontal axis is derived from
  /// the task date span in [GanttView], not from [calendarViewStateProvider].

  GanttBarsProvider call(String? projectId) =>
      GanttBarsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'ganttBarsProvider';
}

/// Streams undated ("unscheduled") tasks — those with neither a start nor a
/// due date — for the quick-arrange panel. Excludes completed tasks.

@ProviderFor(unscheduledTasks)
final unscheduledTasksProvider = UnscheduledTasksFamily._();

/// Streams undated ("unscheduled") tasks — those with neither a start nor a
/// due date — for the quick-arrange panel. Excludes completed tasks.

final class UnscheduledTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Streams undated ("unscheduled") tasks — those with neither a start nor a
  /// due date — for the quick-arrange panel. Excludes completed tasks.
  UnscheduledTasksProvider._({
    required UnscheduledTasksFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'unscheduledTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unscheduledTasksHash();

  @override
  String toString() {
    return r'unscheduledTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as String?;
    return unscheduledTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnscheduledTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unscheduledTasksHash() => r'0eddd15dfd3c9fe260d32935e6bbc27ff49509d6';

/// Streams undated ("unscheduled") tasks — those with neither a start nor a
/// due date — for the quick-arrange panel. Excludes completed tasks.

final class UnscheduledTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, String?> {
  UnscheduledTasksFamily._()
    : super(
        retry: null,
        name: r'unscheduledTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams undated ("unscheduled") tasks — those with neither a start nor a
  /// due date — for the quick-arrange panel. Excludes completed tasks.

  UnscheduledTasksProvider call(String? projectId) =>
      UnscheduledTasksProvider._(argument: projectId, from: this);

  @override
  String toString() => r'unscheduledTasksProvider';
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
