import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // مهم لإظهار الوقت بالتنسيق المناسب
import 'package:cookmate/backend/controllers/notifications_controller.dart';
import 'package:cookmate/backend/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  final String userId;

  const NotificationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationsController _controller = NotificationsController();

  @override
  void initState() {
    super.initState();
    _controller.fetchNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _controller.error,
            builder: (context, error, _) {
              if (error != null) {
                return Center(child: Text('Error: $error'));
              }

              return ValueListenableBuilder<List<NotificationModel>>(
                valueListenable: _controller.notifications,
                builder: (context, notifications, _) {
                  if (notifications.isEmpty) {
                    return const Center(child: Text('No notifications found'));
                  }

                  final newNotifications = notifications.where((n) => !n.isRead).toList();
                  final oldNotifications = notifications.where((n) => n.isRead).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (newNotifications.isNotEmpty) ...[
                        const Text('New', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...newNotifications.map((n) => _buildNotificationCard(n)),
                        const SizedBox(height: 24),
                      ],
                      if (oldNotifications.isNotEmpty) ...[
                        const Text('Recently', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...oldNotifications.map((n) => _buildNotificationCard(n)),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'recipeUpload':
        return Icons.cloud_upload;
      case 'profileUpdate':
        return Icons.person;
      case 'reminder':
        return Icons.alarm;
      case 'feature':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final formattedTime = DateFormat.jm().format(notification.time); // تنسيق الوقت مثل 5:30 PM

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await _controller.markAsRead(notification.id);
          notification.isRead = true;
          _controller.notifications.notifyListeners(); // لتحديث الواجهة
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.grey.shade200 : const Color(0xFFEDE1FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              child: Icon(_getIconForType(notification.type), color: Colors.white),
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                notification.message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
