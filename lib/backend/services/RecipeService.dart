import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final CollectionReference recipesCollection =
  FirebaseFirestore.instance.collection('Recipes');

  Future<void> uploadRecipe({
    required String user_id,
    required String recipeId,
    required String title,
    required List<String> steps,
    required List<String> ingredients,
    required String recipeType,
    required String? imageUrl,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) async {
    final recipeData = {
      'user_id': user_id,
      'recipeId': recipeId,
      'title': title,
      'steps': steps,
      'ingredients': ingredients,
      'recipeType': recipeType,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await recipesCollection.doc(recipeId).set(recipeData);
  }
}
