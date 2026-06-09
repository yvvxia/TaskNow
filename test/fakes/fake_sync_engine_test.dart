import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/utils/result.dart';

import 'fake_sync_engine.dart';

void main() {
  late FakeSyncEngine engine;

  setUp(() => engine = FakeSyncEngine());
  tearDown(() => engine.dispose());

  test('push/pull return Ok and count invocations', () async {
    expect(await engine.push(), isA<Ok<void>>());
    expect(await engine.pull(), isA<Ok<void>>());
    await engine.push();
    expect(engine.pushCount, 2);
    expect(engine.pullCount, 1);
  });

  test('status starts idle and reflects emitted values', () async {
    expect(await engine.status.first, SyncStatus.idle);

    final seen = <SyncStatus>[];
    final sub = engine.status.listen(seen.add);
    await Future<void>.delayed(Duration.zero);
    engine.emitStatus(SyncStatus.syncing);
    engine.emitStatus(SyncStatus.success);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(
      seen,
      containsAllInOrder(<SyncStatus>[
        SyncStatus.idle,
        SyncStatus.syncing,
        SyncStatus.success,
      ]),
    );
  });
}
