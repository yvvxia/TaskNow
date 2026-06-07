// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationActionStream)
final notificationActionStreamProvider = NotificationActionStreamProvider._();

final class NotificationActionStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationAction>,
          NotificationAction,
          Stream<NotificationAction>
        >
    with
        $FutureModifier<NotificationAction>,
        $StreamProvider<NotificationAction> {
  NotificationActionStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationActionStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationActionStreamHash();

  @$internal
  @override
  $StreamProviderElement<NotificationAction> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationAction> create(Ref ref) {
    return notificationActionStream(ref);
  }
}

String _$notificationActionStreamHash() =>
    r'bca5bdfd52b7fcd6ee15b8302e867cab0f21946f';
