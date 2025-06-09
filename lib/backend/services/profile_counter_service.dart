
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCounterService {
  static Future<Map<String, int>> fetchProfileCounts(String userId) async {
    final firestore = FirebaseFirestore.instance;

    final recipesQuery = await firestore
        .collection('Recipes')
        .where('user_id', isEqualTo: userId)
        .get();

    final savedQuery = await firestore
        .collection('SaveRecipes')
        .where('userId', isEqualTo: userId)
        .get();

    final favoritesQuery = await firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: userId)
        .get();

    final savedIds = <String>{};
    final favoriteIds = <String>{};

    for (var doc in savedQuery.docs) {
      final data = doc.data();
      if (data.containsKey('recipe_id')) {
        final ref = data['recipe_id'] as DocumentReference;
        savedIds.add(ref.id);
      } else if (data.containsKey('recipe')) {
        final map = data['recipe'] as Map<String, dynamic>;
        savedIds.add(map['id'].toString());
      }
    }

    for (var doc in favoritesQuery.docs) {
      final data = doc.data();
      if (data.containsKey('recipe_id')) {
        final ref = data['recipe_id'] as DocumentReference;
        favoriteIds.add(ref.id);
      }
    }

    return {
      'recipes': recipesQuery.docs.length,
      'saved': savedIds.length,
      'favorites': favoriteIds.length,
    };
  }
}