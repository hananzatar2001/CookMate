import 'package:flutter/material.dart';
import '../widgets/NavigationBar.dart';
import '../widgets/saved_page_category_filter.dart';
import '../widgets/saved_page_recipe_card.dart';

class SavedRecipesScreen extends StatelessWidget {
  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner'];

  final List<Map<String, String>> recipes = [
    {
      'title': 'Shakshoka',
      'ingredients': 'egg, tomato, onion, oil',
    },
    // ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 63),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.black),
                Icon(Icons.notifications_none, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              "My recipes",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 25),
          SavedPageCategoryFilter(categories: categories),



          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  title: recipe['title']!,
                  ingredients: recipe['ingredients']!,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
