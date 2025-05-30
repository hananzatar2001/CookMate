import 'package:flutter/material.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/notification_bell.dart';
import '../../frontend/widgets/RecipeTypeSelector.dart';

class MealPlanningScreen extends StatefulWidget {
  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  final List<String> meals = ["Salad with eggs", "Salad with eggs", "Salad with eggs"];

  final List<String> recipeTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  List<bool> selectedTypes = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Meal Planning"),
        actions: [
          NotificationBell(unreadCount: 3),
        ],
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2026),
            onDateChanged: (date) {
              // Handle selected date if needed
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RecipeTypeSelector(
              recipeTypes: recipeTypes,
              selectedIndex: selectedTypes.indexWhere((e) => e),
              onChanged: (index) {
                setState(() {
                  for (int i = 0; i < selectedTypes.length; i++) {
                    selectedTypes[i] = i == index;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (_, i) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                    title: Text(meals[i]),
                    subtitle: const Text("294 kcal - 100g"),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // Handle favorite toggle
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
