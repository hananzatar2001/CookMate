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
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('Recipes')
        .where('type', isEqualTo: type)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Recipe(
        recipe_id: data['recipe_id'] ?? doc.id,
        user_id: data['user_id'] ?? '',
        title: data['title'] ?? '',
        steps: List<String>.from(data['steps'] ?? []),
        Ingredients: [],
        type: data['type'] ?? '',
        image_url: data['image_url'] ?? '',
        date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
        calories: data['calories'] ?? 0,
        protein: data['Protein'] ?? 0,
        carbs: data['Carbs'] ?? 0,
        fats: data['Fats'] ?? 0,
      );
    }).toList();
  }
}
