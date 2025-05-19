import 'package:flutter/material.dart';
import 'package:cook_mate/frontend/widgets/notification_bell.dart';

class Recipe {
  final String title;
  final String ingredients;
  bool isFavorite;
  final String imageUrl;

  Recipe({
    required this.title,
    required this.ingredients,
    this.isFavorite = true,
    required this.imageUrl,
  });
}

class FavoritesRecipesScreen extends StatefulWidget {
  const FavoritesRecipesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesRecipesScreenState createState() => _FavoritesRecipesScreenState();
}

class _FavoritesRecipesScreenState extends State<FavoritesRecipesScreen> {
  final List<Recipe> favoriteRecipes = [
    Recipe(
      title: 'Shakshoka',
      ingredients: 'egg, tomato, onion, oil',
      imageUrl: 'https://via.placeholder.com/80',
    ),
    Recipe(
      title: 'Vegan Burger',
      ingredients: 'vegan patty, lettuce, tomato, buns',
      imageUrl: 'https://via.placeholder.com/80',
    ),
    Recipe(
      title: 'Pasta Primavera',
      ingredients: 'pasta, mixed vegetables, olive oil, garlic',
      imageUrl: 'https://via.placeholder.com/80',
    ),
    Recipe(
      title: 'Chocolate Cake',
      ingredients: 'chocolate, flour, sugar, eggs',
      imageUrl: 'https://via.placeholder.com/80',
    ),
    Recipe(
      title: 'Grilled Chicken Salad',
      ingredients: 'chicken, lettuce, cucumber, tomato, dressing',
      imageUrl: 'https://via.placeholder.com/80',
    ),
    Recipe(
      title: 'Quinoa Bowl',
      ingredients: 'quinoa, chickpeas, avocado, spinach, lemon',
      imageUrl: 'https://via.placeholder.com/80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorites Recipes',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          NotificationBell(unreadCount: 3),
        ],
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text(
          'No favorite recipes yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return GestureDetector(
            onTap: () {
              _showRecipeDetails(context, recipe);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.ingredients,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _confirmDeleteFavorite(index);
                      // أو بدك فقط تعمل toggle بدل حذف:
                      // setState(() {
                      //   recipe.isFavorite = !recipe.isFavorite;
                      // });
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'Share':
                          _shareRecipe(recipe);
                          break;
                        case 'Delete':
                          _confirmDeleteFavorite(index);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'Share',
                          child: Text('Share'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(recipe.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(recipe.imageUrl),
              const SizedBox(height: 8),
              Text('Ingredients: ${recipe.ingredients}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _shareRecipe(Recipe recipe) {
    print('Sharing recipe: ${recipe.title}');
    // يمكنك استخدام مكتبة share_plus هنا
  }

  void _confirmDeleteFavorite(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to remove this recipe from favorites?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  favoriteRecipes.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe removed from favorites')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}