import '../enums/enums.dart';
import '../utils/result.dart';

/// Sync engine contract. Reserved for Phase 2; no implementation in Phase 1.
abstract interface class ISyncEngine {
  Future<Result<void>> push();

  Future<Result<void>> pull();

  Stream<SyncStatus> get status;
}
