import 'package:flutter/material.dart';
import '../../frontend/screens/shopping_list_screen.dart';
import '../../frontend/screens/meal_planning_screen.dart';

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
                MaterialPageRoute(builder: (context) => MealPlanningScreen()),
              );
            },
          ),
          const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}
