/*

import 'package:flutter/material.dart';
import '../../frontend/screens/shopping_list_screen.dart';
import '../../frontend/screens/meal_planning_screen.dart';
import '../../frontend/screens/calorie_tracking_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40),
          const SizedBox(height: 10),
          const Text('Name', textAlign: TextAlign.center),
          const Divider(),

          const ListTile(leading: Icon(Icons.settings), title: Text('Settings')),

          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Shopping List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Meal Planning'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MealPlanningScreen()),
              );
            },
          ),

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

          const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../frontend/screens/shopping_list_screen.dart';
import '../../frontend/screens/meal_planning_screen.dart';
import '../../frontend/screens/calorie_tracking_screen.dart';
import '../../frontend/screens/login_screen.dart'; // تأكد من المسار الصحيح

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // تسجيل الخروج من Firebase
    await FirebaseAuth.instance.signOut();

    // إزالة user_id من SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    // الانتقال إلى شاشة تسجيل الدخول
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40),
          const SizedBox(height: 10),
          const Text('Name', textAlign: TextAlign.center),
          const Divider(),

          const ListTile(leading: Icon(Icons.settings), title: Text('Settings')),

          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Shopping List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Meal Planning'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  MealPlanningScreen()),
              );
            },
          ),

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

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
