import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCounterService {
  static Future<Map<String, int>> fetchProfileCounts(String userId) async {
    final firestore = FirebaseFirestore.instance;


    final allRecipes = await firestore.collection('Recipes').get();
    final userRecipes = allRecipes.docs.where((doc) {
      final uid = doc.data()['user_id'];
      if (uid is String) return uid == userId;
      if (uid is DocumentReference) return uid.id == userId;
      return false;
    }).toList();


    final savedQuery = await firestore
        .collection('SaveRecipes')
        .where('userId', isEqualTo: userId)
        .get();

    final savedIds = <String>{};
    for (var doc in savedQuery.docs) {
      final data = doc.data();
      if (data.containsKey('id')) {
        savedIds.add(data['id'].toString());
      }
    }


    final favoritesQuery = await firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: userId)
        .get();

    final favoriteIds = <String>{};
    for (var doc in favoritesQuery.docs) {
      final data = doc.data();
      final recipeField = data['recipe_id'];
      if (recipeField is DocumentReference) {
        favoriteIds.add(recipeField.id);
      } else if (recipeField is String && recipeField.contains('/')) {
        favoriteIds.add(recipeField.split('/').last);
      }
    }

    return {
      'recipes': userRecipes.length,
      'saved': savedIds.length,
      'favorites': favoriteIds.length,
    };
  }
}
