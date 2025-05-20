import 'package:flutter/material.dart';
import '../pages/notifications_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;
  final int notificationCount;
  final bool showEditIcon;

  final String editSnackbarMessage;

  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onEditPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showMenuButton = false,
    this.notificationCount = 0,
    this.showEditIcon = false,

    this.editSnackbarMessage = 'Edit mode activated',
    this.onBackPressed,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
              : showMenuButton
              ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed:
                    onMenuPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menu accessed'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
              )
              : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        if (showEditIcon)
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.black),
            onPressed:
                onEditPressed ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editSnackbarMessage),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
          )
        else
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed:
                    onNotificationPressed ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
