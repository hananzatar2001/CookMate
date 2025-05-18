import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  Future<void> uploadRecipe({
    required String userId,
    required String recipeId,
    required String title,
    required List<String> steps,
    required List<String> ingredients,
    required String recipeType,
    String description = '',
    String? imageUrl,
    String videoUrl = '',
    int calories = 0,
    int protein = 0,
    int carbs = 0,
    int fats = 0,
  }) async {
    final data = {
      'user_id': userId,
      'recipe_id': recipeId,
      'title': title,
      'description': description,
      'calories': calories,
      'Protein': protein,
      'Carbs': carbs,
      'Fats': fats,
      'steps': steps,
      'Ingredients': ingredients,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'recipe_type': recipeType,
      'created_at': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('Recipes').add(data);
  }
}
