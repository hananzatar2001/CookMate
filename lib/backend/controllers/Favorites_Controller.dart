import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recipe {
  final String id;
  final String title;
  final String ingredients;
  final String imageUrl;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.imageUrl,
    this.isFavorite = true,
  });
}

class FavoriteItem {
  final String favoriteId;
  final Recipe recipe;

  FavoriteItem({
    required this.favoriteId,
    required this.recipe,
  });
}

class FavoritesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FavoriteItem> favoriteRecipes = [];

  Future<void> fetchFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      favoriteRecipes = [];
      return;
    }

    favoriteRecipes.clear();

    final snapshot = await _firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      final favoriteId = doc.id;
      final data = doc.data();

      final recipeRef = data['recipe_id'] as DocumentReference?;
      if (recipeRef == null) continue;

      final recipeSnap = await recipeRef.get();
      if (!recipeSnap.exists) continue;

      final recipeData = recipeSnap.data() as Map<String, dynamic>;

      final recipe = Recipe(
        id: recipeSnap.id,
        title: recipeData['title'] ?? 'No title',
        ingredients: (recipeData['ingredients'] as List<dynamic>?)
            ?.join(', ') ??
            'No ingredients',
        imageUrl: recipeData['image_url'] ?? 'https://via.placeholder.com/80',
      );

      favoriteRecipes.add(FavoriteItem(
        favoriteId: favoriteId,
        recipe: recipe,
      ));
    }
  }

  Future<void> deleteFavoriteById(String favoriteId) async {
    await _firestore.collection('Favorites').doc(favoriteId).delete();
    favoriteRecipes.removeWhere((fav) => fav.favoriteId == favoriteId);
  }
}
