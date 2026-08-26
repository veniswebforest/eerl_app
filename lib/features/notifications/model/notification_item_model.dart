enum AppNotificationType {
  offline,
  transferRejected,
  receiptPrinted,
  collectionSubmitted,
  expenseRejected,
  syncCompleted,
}

enum NotificationGroup { today, earlier }

class NotificationItemModel {
  const NotificationItemModel({
    required this.type,
    required this.group,
    required this.timeKey,
  });

  final AppNotificationType type;
  final NotificationGroup group;
  final String timeKey;
}
