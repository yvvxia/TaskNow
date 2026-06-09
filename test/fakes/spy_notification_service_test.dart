import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/models/notification_action.dart';
import 'package:liveline/core/models/notification_request.dart';

import 'spy_notification_service.dart';

NotificationRequest _req(int id, String taskId) => NotificationRequest(
  id: id,
  taskId: taskId,
  title: 'T$id',
  body: 'b',
  scheduledAt: DateTime.utc(2026, 6, 10, 9),
);

void main() {
  late SpyNotificationService spy;

  setUp(() => spy = SpyNotificationService());
  tearDown(() => spy.dispose());

  test('schedule records the request and marks it pending', () async {
    await spy.schedule(_req(1, 'task-1'));
    expect(spy.scheduled, hasLength(1));
    expect(await spy.pending(), [1]);
  });

  test('cancel removes a pending id', () async {
    await spy.schedule(_req(1, 'task-1'));
    await spy.cancel(1);
    expect(spy.cancelledIds, [1]);
    expect(await spy.pending(), isEmpty);
  });

  test(
    'cancelForTask records the id and drops its scheduled requests',
    () async {
      await spy.schedule(_req(1, 'task-1'));
      await spy.schedule(_req(2, 'task-2'));
      await spy.cancelForTask('task-1');

      expect(spy.cancelledTaskIds, ['task-1']);
      expect(spy.scheduled.map((r) => r.id), [2]);
      expect(await spy.pending(), [2]);
    },
  );

  test('emitAction pushes to onAction subscribers', () async {
    const action = NotificationAction(taskId: 'task-1', actionId: 'complete');
    final future = spy.onAction.first;
    spy.emitAction(action);
    expect(await future, action);
  });
}
