import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRecipeService {
  static Future<List<Map<String, dynamic>>> fetchSavedRecipes(
      String userId, String selectedCategory) async {
    try {
      final saveSnapshot = await FirebaseFirestore.instance
          .collection('SaveRecipes')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> recipes = [];

      for (var doc in saveSnapshot.docs) {
        final data = doc.data();
        print("🔥 found: $data");

        if (!data.containsKey('title') || !data.containsKey('type')) continue;

        final recipeType = data['type']?.toString() ?? '';

        if (selectedCategory == 'All' || recipeType == selectedCategory) {
          recipes.add({
            'id': data['id'],
            'title': data['title'] ?? '',
            'image_url': data['image_url'] ?? '',
            'type': recipeType,
          });
        }
      }

      return recipes;
    } catch (e, stackTrace) {

      return [];
    }
  }

}
