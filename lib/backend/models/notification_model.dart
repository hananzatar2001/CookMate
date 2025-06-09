import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String message;
  final DateTime time;
  final String type;
  final String recipeId;
  final String userId;
  bool isRead;  // غيرناها لتكون غير نهائية

  NotificationModel({
    required this.id,
    required this.message,
    required this.time,
    required this.type,
    required this.recipeId,
    required this.userId,
    required this.isRead,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return NotificationModel(
      id: doc.id,
      message: data['message'] ?? '',
      time: data['time'] != null
          ? (data['time'] as Timestamp).toDate()
          : DateTime.now(),
      type: data['type'] ?? '',
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'time': Timestamp.fromDate(time),
      'type': type,
      'recipeId': recipeId,
      'userId': userId,
      'isRead': isRead,
    };
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, message: $message, time: $time, type: $type, recipeId: $recipeId, userId: $userId, isRead: $isRead)';
  }
}
