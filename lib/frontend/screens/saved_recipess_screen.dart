import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../backend/services/saved_recipes_service.dart';
import '../screens/recipe_details.dart';
import '../widgets/NavigationBar.dart';
import '../widgets/notification_bell.dart';
import '../widgets/saved_page_category_filter.dart';

class SavedRecipesScreen extends StatefulWidget {
  final String userId;

  const SavedRecipesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    print("🚀 SavedRecipesScreen loaded with userId: ${widget.userId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
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
              future: SavedRecipeService.fetchSavedRecipes(widget.userId, selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No saved recipes found."));
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          recipe['image_url'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                        ),
                        title: Text(recipe['title'] ?? ''),
                        subtitle: Text(recipe['type'] ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailsPage(
                                recipe: {
                                  'id': recipe['id'],
                                  'title': recipe['title'],
                                  'image_url': recipe['image_url'],
                                },
                              ),
                            ),
                          );
                        },
                      ),
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
