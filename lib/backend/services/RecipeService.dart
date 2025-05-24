import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final CollectionReference recipesCollection =
  FirebaseFirestore.instance.collection('Recipes');

  Future<void> uploadRecipe({
    required String userId,
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
    required String Type,
    String? description,
  }) async {
    final recipeData = {
      'user_id': FirebaseFirestore.instance.doc('User/$userId'),
      'recipe_id': FirebaseFirestore.instance.doc('Recipes/$recipeId'), // reference
      'title': title,
      'description': description ?? '', // optional description
      'calories': calories,
      'Protein': protein,
      'Carbs': carbs,
      'Fats': fats,
      'steps': steps,
      'Ingredients': ingredients,
      'image_url': imageUrl,
      'created_at': FieldValue.serverTimestamp(),
      'Type': Type,
    };

    await recipesCollection.doc(recipeId).set(recipeData);
  }
}