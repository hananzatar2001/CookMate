import 'package:flutter/material.dart';
import '../../backend/services/DrawerService.dart';
import '../../backend/services/logout-service.dart';
import '../../frontend/screens/shopping_list_screen.dart';
import '../../frontend/screens/meal_planning_screen.dart';
import '../../frontend/screens/calorie_tracking_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String name = 'Loading...';
  String? imageUrl;

  final DrawerService drawerService = DrawerService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await drawerService.fetchUserData();
    if (data != null) {
      setState(() {
        name = data['name'] ?? 'Unknown User';
        imageUrl = data['profile_picture'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 10),
                Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('shopping list'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingListScreen()),
              );
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Meal Planning'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MealPlanningScreen()),
              );
            },
          ),
          //
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('Calorie Tracker'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalorieTrackingScreen()),
              );
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => LogoutService.logout(context),
          ),

        ],
      ),
    );
  }
}
