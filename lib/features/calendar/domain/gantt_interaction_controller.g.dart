// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gantt_interaction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies [GanttDragIntent]s against the task repository via the module-02
/// create/update use cases. Invalid intents (`start > due`) are dropped so the
/// UI snaps the bar back without persisting anything.

@ProviderFor(GanttInteractionController)
final ganttInteractionControllerProvider =
    GanttInteractionControllerProvider._();

/// Applies [GanttDragIntent]s against the task repository via the module-02
/// create/update use cases. Invalid intents (`start > due`) are dropped so the
/// UI snaps the bar back without persisting anything.
final class GanttInteractionControllerProvider
    extends $NotifierProvider<GanttInteractionController, void> {
  /// Applies [GanttDragIntent]s against the task repository via the module-02
  /// create/update use cases. Invalid intents (`start > due`) are dropped so the
  /// UI snaps the bar back without persisting anything.
  GanttInteractionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ganttInteractionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ganttInteractionControllerHash();

  @$internal
  @override
  GanttInteractionController create() => GanttInteractionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$ganttInteractionControllerHash() =>
    r'b6b564e4f202b4a9794deaf7b56893b59deb3fe2';

/// Applies [GanttDragIntent]s against the task repository via the module-02
/// create/update use cases. Invalid intents (`start > due`) are dropped so the
/// UI snaps the bar back without persisting anything.

abstract class _$GanttInteractionController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
