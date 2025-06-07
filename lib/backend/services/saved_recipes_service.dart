import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRecipeService {
  static Future<List<Map<String, dynamic>>> fetchSavedRecipes(
      String userId, String selectedCategory) async {
    final saveSnapshot = await FirebaseFirestore.instance
        .collection('SaveRecipes')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> recipes = [];

    for (var doc in saveSnapshot.docs) {
      if (!doc.data().containsKey('recipe')) continue;

      final data = doc['recipe'] as Map<String, dynamic>;
      final recipeType = data['type']?.toString() ?? '';

      if (selectedCategory == 'All' || recipeType == selectedCategory) {
        recipes.add({
          'title': data['title'] ?? '',
          'image_url': data['image_url'] ?? '',
        });
      }
    }

    return recipes;
  }
}
