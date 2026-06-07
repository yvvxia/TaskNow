/// User actions available on a task notification.
enum NotificationActionType {
  markDone,
  snooze,
  open,
}

/// Maps platform [NotificationAction.actionId] strings to [NotificationActionType].
NotificationActionType? parseNotificationActionType(String actionId) {
  switch (actionId) {
    case 'markDone':
    case 'done':
      return NotificationActionType.markDone;
    case 'snooze':
      return NotificationActionType.snooze;
    case 'open':
      return NotificationActionType.open;
    default:
      return null;
  }
}
