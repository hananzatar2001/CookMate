import 'package:flutter/material.dart';
import 'package:cookmate/backend/controllers/notifications_controller.dart';
import 'package:cookmate/backend/models/notification_model.dart';

class NotificationBell extends StatefulWidget {
  final String userId;
  final VoidCallback? onTap;  //

  const NotificationBell({Key? key, required this.userId, this.onTap}) : super(key: key);

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationsController _controller = NotificationsController();

  @override
  void initState() {
    super.initState();
    _controller.fetchNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<NotificationModel>>(
      valueListenable: _controller.notifications,
      builder: (context, notifications, _) {
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: widget.onTap,
              color: Colors.black,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
