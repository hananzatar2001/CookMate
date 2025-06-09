import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationsController {
  // Singleton instance
  static final NotificationsController _instance = NotificationsController._internal();

  factory NotificationsController() {
    return _instance;
  }

  NotificationsController._internal();

  final ValueNotifier<List<NotificationModel>> notifications = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> fetchNotifications(String userId) async {
    if (userId.isEmpty) {
      error.value = 'User ID is empty';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Notifications')
          .where('userId', isEqualTo: userId)
          .get();

      notifications.value =
          snapshot.docs.map((doc) => NotificationModel.fromDocument(doc)).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Notifications')
          .doc(notificationId)
          .update({'isRead': true});

      final updatedList = [...notifications.value];
      final index = updatedList.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final oldNotification = updatedList[index];
        final updatedNotification = NotificationModel(
          id: oldNotification.id,
          userId: oldNotification.userId,
          message: oldNotification.message,
          type: oldNotification.type,
          recipeId: oldNotification.recipeId,
          time: oldNotification.time,
          isRead: true,
        );
        updatedList[index] = updatedNotification;
        notifications.value = updatedList;
      }
    } catch (e) {
      error.value = 'Failed to mark notification as read: $e';
      print('NotificationsController: Error in markAsRead: $e');
    }
  }
}
