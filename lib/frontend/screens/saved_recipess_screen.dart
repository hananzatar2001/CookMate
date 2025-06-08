import 'package:flutter/material.dart';
import '../widgets/NavigationBar.dart';
import '../widgets/saved_page_recipe_card.dart';
import '../widgets/saved_page_category_filter.dart';
import '../../backend/services/saved_recipes_service.dart';
import '../widgets/notification_bell.dart';

class SavedRecipesScreen extends StatefulWidget {
  final String userId;

  const SavedRecipesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CustomBackButton(navigateTo: const ()),

                NotificationBell(
                  unreadCount: 5,
                  onTap: () {
                    print("Tapped notification bell");
                  },
                ),
              ],
            ),
          ),




          const Center(
            child: Text(
              "My Recipes",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SavedPageCategoryFilter(
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: SavedRecipeService.fetchSavedRecipes(
                  widget.userId, selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No saved recipes found."));
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Column(
                      children: [
                        RecipeCard(
                          title: recipe['title'] ?? 'No title',
                          imageUrl: recipe['image_url'] ?? '',
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },

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
