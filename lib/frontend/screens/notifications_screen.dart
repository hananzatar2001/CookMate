import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites_recipes_screen.dart';

enum NotificationType {
  newRecipe,
  profileUpdate,
  reminder,
  featureUpdate,
  mealPlanner,
  system,
}

class AppNotification {
  final String id;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      message: data['message'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      type: _notificationTypeFromString(data['type']),
      isRead: data['isRead'] ?? false,
    );
  }

  static NotificationType _notificationTypeFromString(String? type) {
    switch (type) {
      case 'newRecipe':
        return NotificationType.newRecipe;
      case 'profileUpdate':
        return NotificationType.profileUpdate;
      case 'reminder':
        return NotificationType.reminder;
      case 'featureUpdate':
        return NotificationType.featureUpdate;
      case 'mealPlanner':
        return NotificationType.mealPlanner;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
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

  Future<List<AppNotification>> fetchNotifications() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Notifications')
        .orderBy('time', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => AppNotification.fromFirestore(doc))
        .toList();
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this notification?'),
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

  void _markAllAsRead(List<AppNotification> notifications) {
    for (var notif in notifications) {
      if (!notif.isRead) {
        FirebaseFirestore.instance
            .collection('Notifications')
            .doc(notif.id)
            .update({'isRead': true});
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {});
  }

  Widget _buildNotificationCard(AppNotification notif, List<AppNotification> list) {
    final String formattedTime = DateFormat('hh:mm a').format(notif.time);
    final icon = getIconForType(notif.type);

    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) async {
        await FirebaseFirestore.instance
            .collection('Notifications')
            .doc(notif.id)
            .delete();

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
            if (!notif.isRead) {
              FirebaseFirestore.instance
                  .collection('Notifications')
                  .doc(notif.id)
                  .update({'isRead': true});
              setState(() {
                notif.isRead = true;
              });
            }
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
        backgroundColor: const Color(0x80F8FEDA),
        actions: [
          FutureBuilder<List<AppNotification>>(
            future: fetchNotifications(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final unreadCount =
                    snapshot.data!.where((n) => !n.isRead).length;
                return IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications, color: Colors.black87),
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => _markAllAsRead(snapshot.data!),
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Noo notifications'));
          }

          final notifications = snapshot.data!;
          final newNotifications = notifications
              .where((n) =>
              n.time.isAfter(DateTime.now().subtract(const Duration(days: 1))))
              .toList();
          final recentNotifications = notifications
              .where((n) =>
              n.time.isBefore(DateTime.now().subtract(const Duration(days: 1))))
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
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
                        ...newNotifications
                            .map((notif) => _buildNotificationCard(
                            notif, newNotifications))
                            .toList(),
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
                        ...recentNotifications
                            .map((notif) => _buildNotificationCard(
                            notif, recentNotifications))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
