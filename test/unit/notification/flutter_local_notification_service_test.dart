import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/models/notification_request.dart';
import 'package:plan_list/platform/notifications/windows_notification_service.dart';

void main() {
  late WindowsNotificationService service;

  setUp(() {
    service = WindowsNotificationService();
  });

  tearDown(() => service.dispose());

  test('schedule adds to pending list', () async {
    final when = DateTime.utc(2026, 6, 10, 9);
    await service.schedule(
      NotificationRequest(
        id: 42,
        taskId: 't1',
        title: 'Title',
        body: 'Body',
        scheduledAt: when,
      ),
    );

    expect(await service.pending(), [42]);
    expect(service.scheduledRequests, hasLength(1));
  });

  test('cancel removes from pending', () async {
    await service.schedule(
      NotificationRequest(
        id: 7,
        taskId: 't1',
        title: 'T',
        body: 'B',
        scheduledAt: DateTime.utc(2026, 6, 10),
      ),
    );
    await service.cancel(7);
    expect(await service.pending(), isEmpty);
    expect(service.cancelledIds, [7]);
  });

  test('cancelForTask clears task notifications', () async {
    await service.schedule(
      NotificationRequest(
        id: 1,
        taskId: 'task-a',
        title: 'T',
        body: 'B',
        scheduledAt: DateTime.utc(2026, 6, 10),
      ),
    );
    await service.cancelForTask('task-a');
    expect(await service.pending(), isEmpty);
    expect(service.cancelledTaskIds, ['task-a']);
  });
}
