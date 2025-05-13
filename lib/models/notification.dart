import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String message;
  final DateTime time;
  final String type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      time:
          (json['time'] is Timestamp)
              ? (json['time'] as Timestamp).toDate()
              : DateTime.parse(json['time']),
      type: json['type'] ?? 'system',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'time': time.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }
}
