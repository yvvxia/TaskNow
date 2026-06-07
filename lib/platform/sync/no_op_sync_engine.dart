import '../../core/contracts/i_sync_engine.dart';
import '../../core/enums/enums.dart';
import '../../core/utils/result.dart';

/// Phase-1 no-op implementation of [ISyncEngine].
///
/// Every operation succeeds immediately and the status stream never leaves
/// [SyncStatus.idle]. Phase 2 will replace this with a real backend adapter
/// without touching any business logic (design §6).
class NoOpSyncEngine implements ISyncEngine {
  const NoOpSyncEngine();

  @override
  Future<Result<void>> push() async => const Ok(null);

  @override
  Future<Result<void>> pull() async => const Ok(null);

  @override
  Stream<SyncStatus> get status => Stream.value(SyncStatus.idle);
}
