import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadRecipe(Recipe recipe) async {
    final recipeData = {
      'recipeId': recipe.recipeId,
      'user_id': recipe.user_id,
      'title': recipe.title,
      'steps': recipe.steps,
      'Ingredients': recipe.Ingredients.map((e) => e['name']).toList(),
      'type': recipe.type,
      'calories': recipe.calories,
      'Protein': recipe.protein,
      'Carbs': recipe.carbs,
      'Fats': recipe.fats,
      'image_url': recipe.image_url ?? '',
      'date': recipe.date?.toIso8601String() ?? '',
      'created_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Recipes').add(recipeData);
  }
}
