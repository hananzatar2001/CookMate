import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/favorites_recipes_screen.dart';

enum NotificationType {
  newRecipe,
  profileUpdate,
  reminder,
  featureUpdate,
  mealPlanner,
  system,
}

class AppNotification {
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

IconData getIconForType(NotificationType type) {
  switch (type) {
    case NotificationType.newRecipe:
      return Icons.food_bank;
    case NotificationType.profileUpdate:
      return Icons.account_circle;
    case NotificationType.reminder:
      return Icons.edit;
    case NotificationType.featureUpdate:
      return Icons.new_releases;
    case NotificationType.mealPlanner:
      return Icons.sticky_note_2;
    case NotificationType.system:
      return Icons.system_update;
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 0;

  List<AppNotification> newNotifications = [
    AppNotification(
      message: "New Recipe Alert! Try out our latest \"Vegan Burger\" recipe.",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.newRecipe,
    ),
    AppNotification(
      message: "Your profile was updated successfully. ✔️",
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.profileUpdate,
    ),
    AppNotification(
      message:
          "Don't forget to complete your profile for better recommendations! 🔍",
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.reminder,
    ),
  ];

  List<AppNotification> recentNotifications = [
    AppNotification(
      message: "New Feature Unlocked! Try our latest Meal Planner tool now. 📝",
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.mealPlanner,
    ),
  ];

  int get _unreadCount {
    return [
      ...newNotifications,
      ...recentNotifications,
    ].where((n) => !n.isRead).length;
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesRecipesScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text(
                  'Are you sure you want to delete this notification?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildNotificationCard(
    AppNotification notif,
    List<AppNotification> list,
  ) {
    final String formattedTime = DateFormat('hh:mm a').format(notif.time);
    final icon = getIconForType(notif.type);

    return Dismissible(
      key: ValueKey(notif.hashCode),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) {
        setState(() {
          list.remove(notif);
        });
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: notif.isRead ? Colors.white : const Color(0xFFF1EFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: notif.isRead ? Colors.grey : const Color(0xFFCCB1F6),
          ),
          title: Text(
            notif.message,
            style: TextStyle(
              color: const Color(0xFF333333),
              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          trailing: Text(
            formattedTime,
            style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
          ),
          onTap: () {
            setState(() {
              notif.isRead = true;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                color: const Color(0xFFCCB1F6),
              ),
              if (_unreadCount > 0)
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
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFCCB1F6)),
            onSelected: (String value) {
              if (value == 'mark_read') {
                setState(() {
                  for (var notif in [
                    ...newNotifications,
                    ...recentNotifications,
                  ]) {
                    notif.isRead = true;
                  }
                });
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'mark_read',
                    child: Text('Mark all as read'),
                  ),
                ],
          ),
        ],
        backgroundColor: const Color(0x80F8FEDA),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _refreshNotifications();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...newNotifications.map(
                      (notif) =>
                          _buildNotificationCard(notif, newNotifications),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...recentNotifications.map(
                      (notif) =>
                          _buildNotificationCard(notif, recentNotifications),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
