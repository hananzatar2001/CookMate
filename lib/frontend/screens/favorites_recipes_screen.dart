import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/frontend/screens/notifications_screen.dart';
import 'package:cookmate/frontend/widgets/notification_bell.dart';

import '../widgets/NavigationBar.dart';
import 'home_page_screen.dart'; // عدل المسار حسب موقع ملفك

class FavoritesRecipesScreen extends StatefulWidget {
  const FavoritesRecipesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesRecipesScreenState createState() => _FavoritesRecipesScreenState();
}

class _FavoritesRecipesScreenState extends State<FavoritesRecipesScreen> {
  String? user_id;
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');

    if (storedUserId != null) {
      setState(() {
        user_id = storedUserId;
      });
      await loadFavorites();
    } else {
      setState(() {
        user_id = null;
        isLoading = false;
      });
    }
  }

  Future<void> loadFavorites() async {
    if (user_id == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final favSnapshot = await FirebaseFirestore.instance
          .collection('Favorites')
          .where('user_id', isEqualTo: user_id)
          .get();

      List<Map<String, dynamic>> tempRecipes = [];

      for (var favDoc in favSnapshot.docs) {
        final data = favDoc.data() as Map<String, dynamic>;

        // recipe_id هنا من نوع DocumentReference
        final DocumentReference recipeRef = data['recipe_id'];

        final recipeDoc = await recipeRef.get();

        if (recipeDoc.exists) {
          final recipeData = recipeDoc.data()! as Map<String, dynamic>;

          // نحافظ على الرفيرنس نفسه في recipe_id لكن نحولها لنص ID للعرض
          recipeData['favorite_id'] = favDoc.id;
          recipeData['recipe_ref'] = recipeRef;  // لو حبيت تخزن الرفيرنس لاستخدام مستقبلي
          recipeData['recipe_id'] = recipeDoc.id; // نستخدم id نصي فقط للعرض

          tempRecipes.add(recipeData);
        }
      }

      setState(() {
        favoriteRecipes = tempRecipes;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },

        ),
        title: const Text(
          'Favorites Recipes',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (user_id != null)
            NotificationBell(
              userId: user_id!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(userId: user_id!),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to see notifications')),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user_id == null
          ? const Center(child: Text('Please log in first.'))
          : favoriteRecipes.isEmpty
          ? const Center(child: Text('No favorite recipes yet!'))
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
                      child: recipe['image_url'] != null && recipe['image_url'] != ''
                          ? Image.network(
                        recipe['image_url'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
                        },
                      )
                          : const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (recipe['ingredients'] as List<dynamic>?)?.join(', ') ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      _confirmDeleteFavorite(index);
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
                      return const [
                        PopupMenuItem<String>(
                          value: 'Share',
                          child: Text('Share'),
                        ),
                        PopupMenuItem<String>(
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),

      backgroundColor: Colors.white,
    );
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(recipe['title'] ?? ''),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipe['image_url'] != null && recipe['image_url'] != ''
                    ? Image.network(recipe['image_url'])
                    : const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Ingredients: ${(recipe['ingredients'] as List<dynamic>?)?.join(', ') ?? ''}'),
                const SizedBox(height: 8),
                Text('Carbs: ${recipe['Carbs'] ?? 'N/A'}'),
                Text('Fats: ${recipe['Fats'] ?? 'N/A'}'),
                Text('Protein: ${recipe['Protein'] ?? 'N/A'}'),
                Text('Calories: ${recipe['calories'] ?? 'N/A'}'),
              ],
            ),
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

  void _shareRecipe(Map<String, dynamic> recipe) {
    print('Sharing recipe: ${recipe['title']}');
    // أضف كود المشاركة الفعلي إن أردت
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final favoriteId = favoriteRecipes[index]['favorite_id'];
                await FirebaseFirestore.instance.collection('Favorites').doc(favoriteId).delete();

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
