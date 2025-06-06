import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadRecipe(Recipe recipe) async {
    final recipeData = {
      'recipe_id': recipe.recipe_id,
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
      'date': recipe.date != null ? Timestamp.fromDate(recipe.date!) : null,
      'created_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Recipes').doc(recipe.recipe_id).set(recipeData);
  }

  Future<List<Recipe>> fetchRecipesByDateAndType(DateTime date, String type, String userId) async {
    final String selectedDate = date.toIso8601String().split('T').first;

    final querySnapshot = await _firestore
        .collection('Recipes')
        .where('type', isEqualTo: type)
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs.where((doc) {
      final docDate = (doc['date'] ?? '').toString().split('T').first;
      return docDate == selectedDate;
    }).map((doc) {
      return Recipe(
        recipe_id: doc['recipe_id'] ?? doc.id,
        user_id: doc['user_id'] ?? '',
        title: doc['title'] ?? '',
        steps: List<String>.from(doc['steps'] ?? []),
        Ingredients: [],
        type: doc['type'] ?? '',
        image_url: doc['image_url'] ?? '',
        date: DateTime.tryParse(doc['date'] ?? ''),
        calories: doc['calories'] ?? 0,
        protein: doc['Protein'] ?? 0,
        carbs: doc['Carbs'] ?? 0,
        fats: doc['Fats'] ?? 0,
      );
    }).toList();
  }
}
