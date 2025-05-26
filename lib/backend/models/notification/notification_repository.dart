import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/database_config.dart';
import 'notification.dart';
import 'notification_user.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  Future<List<AppNotification>> loadNotifications() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppNotification.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<NotificationUser?> loadNotificationUser(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.NOTIFICATION_USERS_COLLECTION)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return NotificationUser.fromJson(data);
      } else {
        return NotificationUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading notification users: $e');
      rethrow;
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      await _firestore
          .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Error adding notification: $e');
      rethrow;
    }
  }

  Future<void> updateNotificationUser(NotificationUser notificationUser) async {
    try {
      await _firestore
          .collection(DatabaseConfig.NOTIFICATION_USERS_COLLECTION)
          .doc(notificationUser.id)
          .set(notificationUser.toJson());
    } catch (e) {
      debugPrint('Error updating notification user: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _firestore
          .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
          .doc(id)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(
    List<AppNotification> notifications,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var notification in notifications) {
        batch.update(
          _firestore
              .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
              .doc(notification.id),
          {'isRead': true},
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  Future<void> removeNotification(String id) async {
    try {
      await _firestore
          .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error removing notification: $e');
      rethrow;
    }
  }

  List<AppNotification> getUnreadNotifications(
    List<AppNotification> notifications,
    NotificationUser? notificationUser,
  ) {
    if (notificationUser != null && notifications.isNotEmpty) {
      final unreadIds = notificationUser.unreadNotificationIds;
      return notifications
          .where((notification) => unreadIds.contains(notification.id))
          .toList();
    }
    return notifications.where((notif) => !notif.isRead).toList();
  }
}
