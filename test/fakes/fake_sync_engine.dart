import 'dart:async';

import 'package:liveline/core/contracts/i_sync_engine.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/utils/result.dart';

/// No-op [ISyncEngine] that records how many times [push]/[pull] ran and lets
/// tests drive the [status] stream. Mirrors the production `NoOpSyncEngine`
/// but adds call-counting + a controllable status stream for assertions.
class FakeSyncEngine implements ISyncEngine {
  int pushCount = 0;
  int pullCount = 0;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _lastStatus = SyncStatus.idle;

  @override
  Future<Result<void>> push() async {
    pushCount++;
    return const Ok(null);
  }

  @override
  Future<Result<void>> pull() async {
    pullCount++;
    return const Ok(null);
  }

  /// Emits [status] to listeners and remembers it as the latest value.
  void emitStatus(SyncStatus status) {
    _lastStatus = status;
    _statusController.add(status);
  }

  @override
  Stream<SyncStatus> get status async* {
    yield _lastStatus;
    yield* _statusController.stream;
  }

  void dispose() => _statusController.close();
}
