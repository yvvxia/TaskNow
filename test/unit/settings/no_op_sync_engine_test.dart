import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/enums.dart';
import 'package:liveline/core/utils/result.dart';
import 'package:liveline/platform/sync/no_op_sync_engine.dart';

void main() {
  group('NoOpSyncEngine', () {
    late NoOpSyncEngine engine;

    setUp(() => engine = const NoOpSyncEngine());

    test('push() returns Ok', () async {
      final result = await engine.push();
      expect(result.isOk, isTrue);
    });

    test('pull() returns Ok', () async {
      final result = await engine.pull();
      expect(result.isOk, isTrue);
    });

    test('status emits SyncStatus.idle', () async {
      final status = await engine.status.first;
      expect(status, SyncStatus.idle);
    });

    test('push() and pull() return Ok type', () async {
      final push = await engine.push();
      final pull = await engine.pull();
      expect(push, isA<Ok<void>>());
      expect(pull, isA<Ok<void>>());
    });

    test('status stream can be listened multiple times', () async {
      final first = await engine.status.first;
      final second = await engine.status.first;
      expect(first, SyncStatus.idle);
      expect(second, SyncStatus.idle);
    });
  });
}
