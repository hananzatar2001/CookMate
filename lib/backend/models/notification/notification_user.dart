class NotificationRecord {
  final String notificationId;
  bool isRead;

  NotificationRecord({required this.notificationId, this.isRead = false});

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      notificationId: json['notificationId'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'notificationId': notificationId, 'isRead': isRead};
  }
}

class NotificationUser {
  final String id;
  final String userId;
  final List<NotificationRecord> records;

  NotificationUser({
    required this.id,
    required this.userId,
    required this.records,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'],
      userId: json['userId'],
      records:
          (json['records'] as List?)
              ?.map(
                (record) =>
                    NotificationRecord.fromJson(record as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  NotificationUser addNotification(String notificationId) {
    if (records.any((record) => record.notificationId == notificationId)) {
      return this;
    }

    final updatedRecords = List<NotificationRecord>.from(records)
      ..add(NotificationRecord(notificationId: notificationId));

    return NotificationUser(id: id, userId: userId, records: updatedRecords);
  }

  NotificationUser markAsRead(String notificationId) {
    final updatedRecords =
        records.map((record) {
          if (record.notificationId == notificationId) {
            return NotificationRecord(
              notificationId: record.notificationId,
              isRead: true,
            );
          }
          return record;
        }).toList();

    return NotificationUser(id: id, userId: userId, records: updatedRecords);
  }

  NotificationUser markAllAsRead() {
    final updatedRecords =
        records
            .map(
              (record) => NotificationRecord(
                notificationId: record.notificationId,
                isRead: true,
              ),
            )
            .toList();

    return NotificationUser(id: id, userId: userId, records: updatedRecords);
  }

  List<String> get unreadNotificationIds {
    return records
        .where((record) => !record.isRead)
        .map((record) => record.notificationId)
        .toList();
  }
}
