// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-backed list notifier. Streams [TaskView] items for a given
/// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
///
/// Batch-select state (long-press → multi-select) is tracked via
/// [selectedIds]; an empty set means no selection mode is active.
///
/// Kept alive so navigating between shell destinations does not dispose and
/// re-subscribe the underlying database stream (which caused an empty-list
/// flash and perceptible jank on every tab switch).

@ProviderFor(TaskListNotifier)
final taskListProvider = TaskListNotifierFamily._();

/// Riverpod-backed list notifier. Streams [TaskView] items for a given
/// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
///
/// Batch-select state (long-press → multi-select) is tracked via
/// [selectedIds]; an empty set means no selection mode is active.
///
/// Kept alive so navigating between shell destinations does not dispose and
/// re-subscribe the underlying database stream (which caused an empty-list
/// flash and perceptible jank on every tab switch).
final class TaskListNotifierProvider
    extends $StreamNotifierProvider<TaskListNotifier, List<TaskView>> {
  /// Riverpod-backed list notifier. Streams [TaskView] items for a given
  /// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
  ///
  /// Batch-select state (long-press → multi-select) is tracked via
  /// [selectedIds]; an empty set means no selection mode is active.
  ///
  /// Kept alive so navigating between shell destinations does not dispose and
  /// re-subscribe the underlying database stream (which caused an empty-list
  /// flash and perceptible jank on every tab switch).
  TaskListNotifierProvider._({
    required TaskListNotifierFamily super.from,
    required TaskListScope super.argument,
  }) : super(
         retry: null,
         name: r'taskListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskListNotifierHash();

  @override
  String toString() {
    return r'taskListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskListNotifier create() => TaskListNotifier();

  @override
  bool operator ==(Object other) {
    return other is TaskListNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListNotifierHash() => r'e1597ec69ed7719afc18754ceadd1bde43027d7d';

/// Riverpod-backed list notifier. Streams [TaskView] items for a given
/// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
///
/// Batch-select state (long-press → multi-select) is tracked via
/// [selectedIds]; an empty set means no selection mode is active.
///
/// Kept alive so navigating between shell destinations does not dispose and
/// re-subscribe the underlying database stream (which caused an empty-list
/// flash and perceptible jank on every tab switch).

final class TaskListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskListNotifier,
          AsyncValue<List<TaskView>>,
          List<TaskView>,
          Stream<List<TaskView>>,
          TaskListScope
        > {
  TaskListNotifierFamily._()
    : super(
        retry: null,
        name: r'taskListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Riverpod-backed list notifier. Streams [TaskView] items for a given
  /// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
  ///
  /// Batch-select state (long-press → multi-select) is tracked via
  /// [selectedIds]; an empty set means no selection mode is active.
  ///
  /// Kept alive so navigating between shell destinations does not dispose and
  /// re-subscribe the underlying database stream (which caused an empty-list
  /// flash and perceptible jank on every tab switch).

  TaskListNotifierProvider call(TaskListScope scope) =>
      TaskListNotifierProvider._(argument: scope, from: this);

  @override
  String toString() => r'taskListProvider';
}

/// Riverpod-backed list notifier. Streams [TaskView] items for a given
/// [TaskListScope]. Exposes [complete], [toggleSubtask], and [delete] actions.
///
/// Batch-select state (long-press → multi-select) is tracked via
/// [selectedIds]; an empty set means no selection mode is active.
///
/// Kept alive so navigating between shell destinations does not dispose and
/// re-subscribe the underlying database stream (which caused an empty-list
/// flash and perceptible jank on every tab switch).

abstract class _$TaskListNotifier extends $StreamNotifier<List<TaskView>> {
  late final _$args = ref.$arg as TaskListScope;
  TaskListScope get scope => _$args;

  Stream<List<TaskView>> build(TaskListScope scope);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TaskView>>, List<TaskView>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TaskView>>, List<TaskView>>,
              AsyncValue<List<TaskView>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
